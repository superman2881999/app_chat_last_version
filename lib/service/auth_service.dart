import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_chat_last_version/helper/helper_functions.dart';
import 'package:flutter_app_chat_last_version/models/user_model.dart';

import 'database.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  // create user object based on FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user){
    return user !=null ? User(uid: user.uid) : null;
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email,String password) async{
    try{
        AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
        FirebaseUser firebaseUser = result.user;
        return _userFromFirebaseUser(firebaseUser);
    }catch(e){
        print(e.toString());
        return null;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(String fullName, String email, String password,String urlAvt,String token) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      // Create a new document for the user with uid
      await DatabaseService(uid: user.uid).updateUserData(fullName, email, password,user.uid,urlAvt,token);
      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
  //sign out
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInSharedPreference(false);
      await HelperFunctions.saveUserEmailSharedPreference('');
      await HelperFunctions.saveUserNameSharedPreference('');
      await HelperFunctions.saveTokenSharedPreference('');

      return await _auth.signOut().whenComplete(() async {
        print("Logged out");
        await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
          print("Logged in: $value");
        });
        await HelperFunctions.getUserEmailSharedPreference().then((value) {
          print("Email: $value");
        });
        await HelperFunctions.getUserNameSharedPreference().then((value) {
          print("Full Name: $value");
        });
      });
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
  static Future resetPass(String email) async {
    try{
      return await _auth.sendPasswordResetEmail(email: email);
    }catch(e){
      print(e.toString());
    }
  }
  // Future signOut() async {
  //   try{
  //     return await _auth.signOut();
  //   }catch(e){
  //     print(e.toString());
  //   }
  // }
}