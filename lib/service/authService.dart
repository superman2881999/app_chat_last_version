import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app_chat_last_version/modals/User.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User _userfromFirebaseUser(FirebaseUser user){
    return user !=null ? User(userId: user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email,String password) async{
    try{
        AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
        FirebaseUser firebaseUser = result.user;
        return _userfromFirebaseUser(firebaseUser);
    }catch(e){
print(e.toString());
    }
  }
  Future signUpWithEmailAndPassword(String email, String password) async {

    try{
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userfromFirebaseUser(user);
    }catch(e){
      print(e.toString());
    }
  }
  Future resetPass(String email) async {
    try{
      return await _auth.sendPasswordResetEmail(email: email);
    }catch(e){
      print(e.toString());
    }
  }
  Future signOut() async {
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
    }
  }
}