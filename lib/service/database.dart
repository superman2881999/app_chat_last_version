import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_chat_last_version/helper/constant.dart';
import 'package:flutter_app_chat_last_version/models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  // Collection reference
   final  CollectionReference userCollection =
      Firestore.instance.collection('users');
   final CollectionReference groupCollection =
      Firestore.instance.collection('groups');
   final CollectionReference singleCollection =
      Firestore.instance.collection('single');

  searchUserByName(String nameUser) async {
    return await userCollection
        .where("fullName", isEqualTo: nameUser)
        .getDocuments();
  }

  searchGroupByNameGroup(String nameGroup) async {
    return await groupCollection
        .where("groupName", isEqualTo: nameGroup)
        .getDocuments();
  }

  // update userdata
  Future updateUserData(String fullName, String email, String password,
      String uid, String urlAvt,String token) async {
    String passwordHash = sha256.convert(utf8.encode(password)).toString();
    return await userCollection.document(uid).setData({
      'fullName': fullName,
      'email': email,
      'uid': uid,
      'password': passwordHash,
      'groups': [],
      'single': [],
      'profilePic': '',
      'token':token,
      'urlAvt': urlAvt,
    });
  }
  Future updateToken({String userId,String token}) async {
    await userCollection
        .document(userId)
        .updateData({'token': token});
  }

   getUser(String nameUser) async {
    return await userCollection
        .where("fullName", isEqualTo: nameUser)
        .getDocuments();
  }

  // get user data
  getUserData(String email) async {
    return await userCollection.where('email', isEqualTo: email).getDocuments();
  }

  getUsers() async {
    return await userCollection.getDocuments();
  }

  //Tạo phòng chat riêng từ search
  Future createChatSingle(String userName, String uidPersonOther, String urlAvt,
      String urlAvtOther) async {
    DocumentReference userDocRef = userCollection.document(uid);
    DocumentReference userDocRefOther = userCollection.document(uidPersonOther);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    List<dynamic> single = await userDocSnapshot.data['single'];

    if (!single.contains(uidPersonOther + '_' + userName)) {
      DocumentReference singleDocRef = await singleCollection.add({
        'nameChatSingle': userName + "_" + Constants.myName,
        'singleIcon': '',
        'members': [],
        //'messages': ,
        'singleId': '',
        'recentMessage': '',
        'recentMessageSender': '',
        'urlAvt': '$urlAvtOther' +
            "*" +
            '$userName'
                '@$urlAvt' +
            "*" +
            '${Constants.myName}'
      });

      await userDocRef.updateData({
        'single': FieldValue.arrayUnion([uidPersonOther + '_' + userName])
      });

      await userDocRefOther.updateData({
        'single': FieldValue.arrayUnion([uid + '_' + Constants.myName])
      });

      await singleDocRef.updateData({
        'members': FieldValue.arrayUnion(
            [uid + '_' + Constants.myName, uidPersonOther + '_' + userName]),
        'singleId': singleDocRef.documentID
      });
    }
  }

  // create group
  Future createGroup(String userName, String groupName) async {
    DocumentReference groupDocRef = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': "images/Avt_Default.jpg",
      'admin': userName,
      'members': [],
      //'messages': ,
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': ''
    });

    await groupDocRef.updateData({
      'members': FieldValue.arrayUnion([uid + '_' + userName]),
      'groupId': groupDocRef.documentID
    });

    DocumentReference userDocRef = userCollection.document(uid);
    return await userDocRef.updateData({
      'groups':
          FieldValue.arrayUnion([groupDocRef.documentID + '_' + groupName])
    });
  }

  Future updateIconGroup({String groupId, String groupIcon}) async {
    await groupCollection
        .document(groupId)
        .updateData({'groupIcon': groupIcon});
  }

  Future updateAvtUser({String uid, String urlAvt}) async {
    await userCollection.document(uid).updateData({'urlAvt': urlAvt});
  }

  Future updateUrlAvtSingle({String uid, String urlAvt}) async {
    await singleCollection.document(uid).updateData({'urlAvt': urlAvt});
  }

  Future addMember(String groupId, String groupName, User userModel) async {
    DocumentReference userDocRef = userCollection.document(userModel.uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    DocumentReference groupDocRef = groupCollection.document(groupId);
    List<dynamic> groups = await userDocSnapshot.data['groups'];

    if (!groups.contains(groupId + '_' + groupName)) {
      await userDocRef.updateData({
        'groups': FieldValue.arrayUnion([groupId + '_' + groupName])
      });

      await groupDocRef.updateData({
        'members':
            FieldValue.arrayUnion([userModel.uid + '_' + userModel.fullName])
      });
    }
  }

  getSingleByNameSingle(String nameChatSingle) async {
    return await singleCollection
        .where('nameChatSingle', isEqualTo: nameChatSingle)
        .getDocuments();
  }

  Future getGroupByNameGroup(String nameGroup) async {
    QuerySnapshot snapshot = await groupCollection
        .where('groupName', isEqualTo: nameGroup)
        .getDocuments();
    return snapshot;
  }

  // send message
  sendMessage(String singleId, chatMessageData) {
    singleCollection
        .document(singleId)
        .collection('messages')
        .add(chatMessageData);

    if (chatMessageData['message']
        .toString()
        .contains("https://firebasestorage.googleapis.com/")) {
      singleCollection.document(singleId).updateData({
        'recentMessage': chatMessageData['sendBy'] + " sent a picture",
        'recentMessageSender': chatMessageData['sendBy'],
        'recentMessageTime': chatMessageData['time'].toString(),
      });
    } else if (chatMessageData['message']
        .toString()
        .contains("sticker_packs/")) {
      singleCollection.document(singleId).updateData({
        'recentMessage': chatMessageData['sendBy'] + " sent a sticker",
        'recentMessageSender': chatMessageData['sendBy'],
        'recentMessageTime': chatMessageData['time'].toString(),
      });
    } else {
      singleCollection.document(singleId).updateData({
        'recentMessage': chatMessageData['message'],
        'recentMessageSender': chatMessageData['sendBy'],
        'recentMessageTime': chatMessageData['time'].toString(),
      });
    }
  }

  sendMessageGroup(String groupId, chatMessageData) {
    groupCollection
        .document(groupId)
        .collection('messages')
        .add(chatMessageData);

    if (chatMessageData['message']
        .toString()
        .contains("https://firebasestorage.googleapis.com/")) {
      groupCollection.document(groupId).updateData({
        'recentMessage': chatMessageData['sendBy'] + " sent a picture",
        'recentMessageSender': chatMessageData['sendBy'],
        'recentMessageTime': chatMessageData['time'].toString(),
      });
    } else if (chatMessageData['message']
        .toString()
        .contains("sticker_packs/")) {
      groupCollection.document(groupId).updateData({
        'recentMessage': chatMessageData['sendBy'] + " sent a sticker",
        'recentMessageSender': chatMessageData['sendBy'],
        'recentMessageTime': chatMessageData['time'].toString(),
      });
    } else {
      groupCollection.document(groupId).updateData({
        'recentMessage': chatMessageData['message'],
        'recentMessageSender': chatMessageData['sendBy'],
        'recentMessageTime': chatMessageData['time'].toString(),
      });
    }
  }

  getConversation(String singleId) async {
    return singleCollection
        .document(singleId)
        .collection("messages")
        .orderBy('time', descending: true)
        .snapshots();
  }

  getConversationGroup(String groupId) async {
    return groupCollection
        .document(groupId)
        .collection("messages")
        .orderBy('time', descending: true)
        .snapshots();
  }

  getChatRooms(String userName) async {
    return singleCollection
        .where("members", arrayContains: userName)
        .snapshots();
  }

  getAmountSingle(String userName) async {
    return singleCollection
        .where("members", arrayContains: userName)
        .getDocuments();
  }

  getChatRoomsGroup(String userName) async {
    return groupCollection
        .where("members", arrayContains: userName)
        .snapshots();
  }

  getAmountGroup(String userName) async {
    return groupCollection
        .where("members", arrayContains: userName)
        .getDocuments();
  }

  getAllSingle(String userName) async {
    return singleCollection
        .where("members", arrayContains: userName)
        .getDocuments();
  }

  // get user groups
  getUserGroups(String userName) async {
    return groupCollection
        .where("members", arrayContains: userName)
        .snapshots();
  }

  //biểu đồ
  getLengthOfConversation(String chatRoomId) {
    return singleCollection
        .document(chatRoomId)
        .collection("messages")
        .getDocuments();
  }

  //biểu đồ
  getLengthOfGroupConversation(String chatRoomId) {
    return groupCollection
        .document(chatRoomId)
        .collection("messages")
        .getDocuments();
  }
}
