import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/screens/CompleteProfilePage.dart';
import 'package:chat_app/screens/HomePage.dart';
import 'package:chat_app/screens/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'models/FirebaseHelper.dart';

var uuid = Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;

  if(currentUser != null) {
    // Logged In
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
    if(thisUserModel != null) {
      runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    }
    else {
      runApp(MyApp());
    }
  }
  else {
    // Not logged in
    runApp(MyApp());
  }
}

// when use not loggedIn

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
     home:  LoginPage(),
    );
  }
}

// When user loggedIn
class MyAppLoggedIn extends StatelessWidget {
   final UserModel? userModel;
   final User? firebaseUser;

  const MyAppLoggedIn({this.userModel, this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  HomePage(userModel: userModel , firebaseUser: firebaseUser),
    );
  }
 }


