import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  getUserByUserName(String nameUser) async {
    return await Firestore.instance
        .collection("users")
        .where("name", isEqualTo: nameUser)
        .getDocuments();
  }

  getUserByUserEmail(String userEmail) async {
    return await Firestore.instance
        .collection("users")
        .where("email", isEqualTo: userEmail)
        .getDocuments();
  }

  uploadUserInfo(userMap) {
    Firestore.instance.collection("users").add(userMap);
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .setData(chatRoomMap)
        .catchError((onError) {
      print(onError.toString());
    });
  }
  uploadToken(String uid, String email,String fcmToken) {
    Firestore.instance
        .collection("Tokens")
        .document(uid)
        .setData({
        "email": email,
        "fcmToken": fcmToken
    });
  }
  uploadNotification(String documentID,String message,String email){
    Firestore.instance.collection("Tokens").document(documentID).collection("notifications").add({
      "message": message,
      "title": email,
      "date": FieldValue.serverTimestamp()
    });
  }

  addConversation(String chatRoomId, messageMap) {
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .add(messageMap);
  }

  getConversation(String chatRoomId) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy('time', descending: true)
        .snapshots();
  }
  getLengthOfConversation(String chatRoomId) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .getDocuments();
  }

  Stream<QuerySnapshot> getMessageLastOfChat ({ @required String chatRoomId}) {
    return Firestore.instance
        .collection("ChatRoom").document(chatRoomId)
        .collection("chats")
        .orderBy('time', descending: true)
        .snapshots();
  }

  getChatRooms(String userName) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: userName)
        .snapshots();
  }
}
