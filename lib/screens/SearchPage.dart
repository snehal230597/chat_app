import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/screens/ChatRoomPage.dart';
import 'package:chat_app/screens/Timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/ChatRoomModel.dart';

class SearchPage extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  const SearchPage({required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel!.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      //Fetch the exiting one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
      ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
      print('Chatroom already created!');
    } else {
      // Create a new one
      ChatRoomModel newChatroom =
      ChatRoomModel(chatroomid: uuid.v1(), lastMessage: "", participants: {
        widget.userModel!.uid.toString(): true,
        targetUser.uid.toString(): true,
      });
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());
      chatRoom = newChatroom;
      print("New Chat Room Created!");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                ),
              ),
            ),
            CupertinoButton(
                child: Text('Search'),
                onPressed: () {
                  setState(() {});
                  //  Navigator.of(context).push(MaterialPageRoute(builder: (_) => OtpTimer()));
                },
                color: Colors.blue),
            SizedBox(height: 20),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: searchController.text)
                  .where("email", isNotEqualTo: widget.userModel!.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                    if (dataSnapshot.docs.length > 0) {
                      Map<String, dynamic> userMap =
                      dataSnapshot.docs[0].data() as Map<String, dynamic>;

                      UserModel searchedUser = UserModel.fromMap(userMap);

                      return ListTile(
                        onTap: () async {
                          ChatRoomModel? chatroomModel =
                          await getChatroomModel(searchedUser);
                          if (chatroomModel != null) {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChatRoomPage(
                                      targetUser: searchedUser,
                                      firebaseUser: widget.firebaseUser,
                                      userModel: widget.userModel,
                                      chatroom: chatroomModel,
                                    ),
                              ),
                            );
                          }
                        },
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                              'https://media-exp1.licdn.com/dms/image/C4E0BAQEcEIwYTY_JdQ/company-logo_200_200/0/1601442866716?e=2147483647&v=beta&t=q9kDoJ6sxsWD_85DTOriV_LEi87eLeR2wP0O2hi9n7s'),
                          backgroundColor: Colors.grey[500],
                        ),
                        title: Text(searchedUser.fullname!),
                        subtitle: Text(searchedUser.email!),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      );
                    } else {
                      return Text("No results found!");
                    }
                  } else if (snapshot.hasError) {
                    return Text("An error occured!");
                  } else {
                    return Text("No results found!");
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
