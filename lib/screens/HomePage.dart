import 'package:chat_app/models/ChatRoomModel.dart';
import 'package:chat_app/models/UIHelper.dart';
import 'package:chat_app/screens/ChatRoomPage.dart';
import 'package:chat_app/screens/LoginPage.dart';
import 'package:chat_app/screens/SearchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/FirebaseHelper.dart';
import '../models/UserModel.dart';

class HomePage extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  HomePage({required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Chat App'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => LoginPage(),
                ),
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         // UIHelper.showLoadingDialog(context, "Loading...");
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SearchPage(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser),
            ),
          );
        },
        child: Icon(Icons.search),
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("participants.${widget.userModel!.uid}", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatroomSnapshot =
                      snapshot.data as QuerySnapshot;
                  return ListView.builder(
                    itemCount: chatroomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatroomSnapshot.docs[index].data()
                              as Map<String, dynamic>);
                      Map<String, dynamic>? participants =
                          chatRoomModel.participants;
                      List<String> participantKeys =
                          participants!.keys.toList();
                      participantKeys.remove(widget.userModel!.uid);

                      return FutureBuilder(
                        future:
                            FirebaseHelper.getUserModelById(participantKeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData.data != null) {
                              UserModel targetUser = userData.data as UserModel;

                              return ListTile(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatRoomPage(
                                          targetUser: targetUser,
                                          chatroom: chatRoomModel,
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                      'https://media-exp1.licdn.com/dms/image/C4E0BAQEcEIwYTY_JdQ/company-logo_200_200/0/1601442866716?e=2147483647&v=beta&t=q9kDoJ6sxsWD_85DTOriV_LEi87eLeR2wP0O2hi9n7s'),
                                ),
                                title: Text(targetUser.fullname.toString()),
                                subtitle: (chatRoomModel.lastMessage
                                            .toString() !=
                                        "")
                                    ? Text(chatRoomModel.lastMessage.toString())
                                    : Text(
                                        'Say hi to your friend!',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                    ),
                  );
                } else {
                  return Center(child: Text('No Chats'));
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
