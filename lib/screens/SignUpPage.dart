import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/screens/CompleteProfilePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/UIHelper.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if (email == "" || password == "" || cPassword == "") {
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the field");
    } else if (password != cPassword) {
      UIHelper.showAlertDialog(context, "Password MisMatch", "The Passwords you entered do not match!");
    } else {
      sigUp(email, password);
    }
  }

  void sigUp(String email, String password) async {
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Creting  new account...");
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "An Error Occoured!", ex.message.toString());
      print(ex.code.toString());
    }
    ;

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then(
        (value) {
          print("New User Created!");
           Navigator.popUntil(context, (route) => route.isFirst);
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => CompleteProfilePage(
                userModel: newUser,
                firebaseUser: credential!.user!,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Alredy have an accout?',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(width: 5),
              Text(
                'Login',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 240),
                child: Text(
                  'Chat App',
                  style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email Address"),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  obscureText: true,
                  controller: cPasswordController,
                  decoration: InputDecoration(labelText: "Confirm Password"),
                ),
              ),
              SizedBox(height: 80),
              CupertinoButton(
                  child: Text('Sign up'),
                  onPressed: () {
                    checkValues();
                  },
                  color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
