import 'dart:convert';

import 'dart:io';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_app_chat_last_version/helper/constant.dart';
import 'package:flutter_app_chat_last_version/models/sticker_model.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/views/message_location.dart';
import 'package:flutter_app_chat_last_version/views/take_picture_single.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:geolocator/geolocator.dart';

import 'add_members.dart';
import 'message_sticker.dart';
import 'message_tile_image.dart';
import 'message_tile.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({this.nameRoomChat, this.id});
  final String nameRoomChat;
  final String id;
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  DatabaseService databaseService = new DatabaseService();
  TextEditingController message = new TextEditingController();
  Stream chatMessageStream;
  CameraDescription firstCamera;
  bool isShowSticker;
  FirebaseUser user;
  List<String> locationDes;
  FocusNode focusNode = new FocusNode();
 static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  QuerySnapshot querySnapshot;
  String token;

    FirebaseMessaging firebaseMessaging = FirebaseMessaging();

    Future<bool> sendFcmMessage(String title, String message) async {
    await databaseService.getUser(widget.nameRoomChat).then((value) async{
       setState(() {
         querySnapshot = value;
         token = querySnapshot.documents[0].data["token"];
       });
     });
     try {
       var url = 'https://fcm.googleapis.com/fcm/send';
       var header = {
         "Content-Type": "application/json",
         "Authorization":
         "key=AAAAlkezjgc:APA91bFl6BvMDMz1IJb75TanPjYgm92Y2_MOXxqxZSdKn5QzDMgg6xvG6oYMYj4hdBXghvBSlb4df8-R2otIq5ZH_tCLvZZunoloBmnvRdBFQPVdkRKUjNZ_mKX6-7paVN14Zq37Yr8Z",
       };
      var request = {
         'notification': {'title': title, 'body': message},
         'data': {
           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
           'type': 'Comment'
         },
         'to': '$token'
       };

       var client = new Client();
       var response =
       await client.post(url, headers: header, body: json.encode(request));
       print(response.body);
       return true;
     } catch (e) {
       print(e);
       return false;
     }
   }

  Widget chatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  String isCheck = "https://firebasestorage.googleapis.com/";
                  String isSticker = "sticker_packs/";

                  while (index < snapshot.data.documents.length - 1) {
                    if (snapshot.data.documents[index].data["message"]
                        .toString()
                        .contains(isCheck)) {
                      return MessageTileImage(
                        checkSender: snapshot
                                    .data.documents[index + 1].data["sendBy"] ==
                                snapshot.data.documents[index].data["sendBy"]
                            ? false
                            : true,
                        sendBy: snapshot.data.documents[index].data["sendBy"]
                                .toString()
                                .substring(0, 1)
                                .toUpperCase() +
                            snapshot.data.documents[index].data["sendBy"]
                                .toString()
                                .substring(1),
                        message: snapshot.data.documents[index].data["message"],
                        sendByMe:
                            snapshot.data.documents[index].data["sendBy"] ==
                                Constants.myName,
                      );
                    } else if (snapshot.data.documents[index].data["message"]
                        .toString()
                        .contains(isSticker)) {
                      return MessageSticker(
                        checkSender: snapshot
                                    .data.documents[index + 1].data["sendBy"] ==
                                snapshot.data.documents[index].data["sendBy"]
                            ? false
                            : true,
                        sendBy: snapshot.data.documents[index].data["sendBy"]
                                .toString()
                                .substring(0, 1)
                                .toUpperCase() +
                            snapshot.data.documents[index].data["sendBy"]
                                .toString()
                                .substring(1),
                        sendByMe:
                            snapshot.data.documents[index].data["sendBy"] ==
                                Constants.myName,
                        message: snapshot.data.documents[index].data["message"],
                      );
                    } else if (snapshot.data.documents[index].data["message"]
                        .toString()
                        .contains("Send my location to mina*")) {
                      locationDes = snapshot.data.documents[index].data["message"]
                          .toString().split("*");
                      return MessageLocation(
                        locationDes: locationDes,
                        checkSender: snapshot
                                    .data.documents[index + 1].data["sendBy"] ==
                                snapshot.data.documents[index].data["sendBy"]
                            ? false
                            : true,
                        sendBy: snapshot.data.documents[index].data["sendBy"]
                                .toString()
                                .substring(0, 1)
                                .toUpperCase() +
                            snapshot.data.documents[index].data["sendBy"]
                                .toString()
                                .substring(1),
                        sendByMe:
                            snapshot.data.documents[index].data["sendBy"] ==
                                Constants.myName,
                        message: snapshot.data.documents[index].data["message"],
                      );
                    }
                    return MessageTile(
                        checkSender: snapshot
                                    .data.documents[index + 1].data["sendBy"] ==
                                snapshot.data.documents[index].data["sendBy"]
                            ? false
                            : true,
                        sendBy: snapshot.data.documents[index].data["sendBy"]
                                .toString()
                                .substring(0, 1)
                                .toUpperCase() +
                            snapshot.data.documents[index].data["sendBy"]
                                .toString()
                                .substring(1),
                        message: snapshot.data.documents[index].data["message"],
                        sendByMe:
                            snapshot.data.documents[index].data["sendBy"] ==
                                Constants.myName);
                  }
                  if (snapshot.data.documents.length == 1) {
                    if (snapshot
                        .data
                        .documents[snapshot.data.documents.length - 1]
                        .data["message"]
                        .toString()
                        .contains(isCheck)) {
                      return MessageTileImage(
                        checkSender: true,
                        sendBy: snapshot
                                .data
                                .documents[snapshot.data.documents.length - 1]
                                .data["sendBy"]
                                .toString()
                                .substring(0, 1)
                                .toUpperCase() +
                            snapshot
                                .data
                                .documents[snapshot.data.documents.length - 1]
                                .data["sendBy"]
                                .toString()
                                .substring(1),
                        message: snapshot
                            .data
                            .documents[snapshot.data.documents.length - 1]
                            .data["message"],
                        sendByMe: snapshot
                                .data
                                .documents[snapshot.data.documents.length - 1]
                                .data["sendBy"] ==
                            Constants.myName,
                      );
                    } else if (snapshot
                        .data
                        .documents[snapshot.data.documents.length - 1]
                        .data["message"]
                        .toString()
                        .contains(isSticker)) {
                      return MessageSticker(
                        checkSender: true,
                        sendBy: snapshot
                                .data
                                .documents[snapshot.data.documents.length - 1]
                                .data["sendBy"]
                                .toString()
                                .substring(0, 1)
                                .toUpperCase() +
                            snapshot
                                .data
                                .documents[snapshot.data.documents.length - 1]
                                .data["sendBy"]
                                .toString()
                                .substring(1),
                        sendByMe: snapshot
                                .data
                                .documents[snapshot.data.documents.length - 1]
                                .data["sendBy"] ==
                            Constants.myName,
                        message: snapshot
                            .data
                            .documents[snapshot.data.documents.length - 1]
                            .data["message"],
                      );
                    } else if (snapshot.data.documents[index].data["message"]
                        .toString()
                        .contains("Send my location to mina*")) {
                      locationDes = snapshot.data.documents[index].data["message"]
                          .toString().split("*");
                      return MessageLocation(
                        locationDes: locationDes,
                        checkSender: snapshot
                                    .data.documents[index + 1].data["sendBy"] ==
                                snapshot.data.documents[index].data["sendBy"]
                            ? false
                            : true,
                        sendBy: snapshot.data.documents[index].data["sendBy"]
                                .toString()
                                .substring(0, 1)
                                .toUpperCase() +
                            snapshot.data.documents[index].data["sendBy"]
                                .toString()
                                .substring(1),
                        sendByMe:
                            snapshot.data.documents[index].data["sendBy"] ==
                                Constants.myName,
                        message: snapshot.data.documents[index].data["message"],
                      );
                    }
                    return MessageTile(
                        checkSender: true,
                        sendBy: snapshot
                                .data
                                .documents[snapshot.data.documents.length - 1]
                                .data["sendBy"]
                                .toString()
                                .substring(0, 1)
                                .toUpperCase() +
                            snapshot
                                .data
                                .documents[snapshot.data.documents.length - 1]
                                .data["sendBy"]
                                .toString()
                                .substring(1),
                        message: snapshot
                            .data
                            .documents[snapshot.data.documents.length - 1]
                            .data["message"],
                        sendByMe: snapshot
                                .data
                                .documents[snapshot.data.documents.length - 1]
                                .data["sendBy"] ==
                            Constants.myName);
                  }
                  if (snapshot
                      .data
                      .documents[snapshot.data.documents.length - 1]
                      .data["message"]
                      .toString()
                      .contains(isCheck)) {
                    return MessageTileImage(
                      checkSender: true,
                      sendBy: snapshot
                              .data
                              .documents[snapshot.data.documents.length - 1]
                              .data["sendBy"]
                              .toString()
                              .substring(0, 1)
                              .toUpperCase() +
                          snapshot
                              .data
                              .documents[snapshot.data.documents.length - 1]
                              .data["sendBy"]
                              .toString()
                              .substring(1),
                      message: snapshot
                          .data
                          .documents[snapshot.data.documents.length - 1]
                          .data["message"],
                      sendByMe: snapshot
                              .data
                              .documents[snapshot.data.documents.length - 1]
                              .data["sendBy"] ==
                          Constants.myName,
                    );
                  } else if (snapshot
                      .data
                      .documents[snapshot.data.documents.length - 1]
                      .data["message"]
                      .toString()
                      .contains(isSticker)) {
                    return MessageSticker(
                      checkSender: true,
                      sendBy: snapshot
                              .data
                              .documents[snapshot.data.documents.length - 1]
                              .data["sendBy"]
                              .toString()
                              .substring(0, 1)
                              .toUpperCase() +
                          snapshot
                              .data
                              .documents[snapshot.data.documents.length - 1]
                              .data["sendBy"]
                              .toString()
                              .substring(1),
                      sendByMe: snapshot
                              .data
                              .documents[snapshot.data.documents.length - 1]
                              .data["sendBy"] ==
                          Constants.myName,
                      message: snapshot
                          .data
                          .documents[snapshot.data.documents.length - 1]
                          .data["message"],
                    );
                  } else if (snapshot.data.documents[index].data["message"]
                      .toString()
                      .contains("Send my location to mina*")) {
                    locationDes = snapshot.data.documents[index].data["message"]
                        .toString().split("*");
                    return MessageLocation(
                      locationDes: locationDes,
                      checkSender:
                          snapshot.data.documents[index + 1].data["sendBy"] ==
                                  snapshot.data.documents[index].data["sendBy"]
                              ? false
                              : true,
                      sendBy: snapshot.data.documents[index].data["sendBy"]
                              .toString()
                              .substring(0, 1)
                              .toUpperCase() +
                          snapshot.data.documents[index].data["sendBy"]
                              .toString()
                              .substring(1),
                      sendByMe: snapshot.data.documents[index].data["sendBy"] ==
                          Constants.myName,
                      message: snapshot.data.documents[index].data["message"],
                    );
                  }
                  return MessageTile(
                      checkSender: true,
                      sendBy: snapshot
                              .data
                              .documents[snapshot.data.documents.length - 1]
                              .data["sendBy"]
                              .toString()
                              .substring(0, 1)
                              .toUpperCase() +
                          snapshot
                              .data
                              .documents[snapshot.data.documents.length - 1]
                              .data["sendBy"]
                              .toString()
                              .substring(1),
                      message: snapshot
                          .data
                          .documents[snapshot.data.documents.length - 1]
                          .data["message"],
                      sendByMe: snapshot
                              .data
                              .documents[snapshot.data.documents.length - 1]
                              .data["sendBy"] ==
                          Constants.myName);
                })
            : Container(
                child: Center(child: new CircularProgressIndicator()),
              );
      },
    );
  }

  sendMessage() {
    if (message.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": message.text,
        "sendBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      sendFcmMessage(Constants.myName,message.text);
      databaseService.sendMessage(widget.id, messageMap);
      message.text = "";
    }
  }

  //get current location
  Position location;
  Future<void> getUserLocation() async {
    await Geolocator.getCurrentPosition().then((value) {
      location = value;
    });
  }
 static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    print(message.toString());
    if (message.containsKey('data')) {
      Constants.showNotificationWithDefaultSound(
          flutterLocalNotificationsPlugin,
          message['notification']['title'],
          message['notification']['body']);
    }
  }

  @override
  void initState() {
    flutterLocalNotificationsPlugin = Constants.initNotify();
    if (Platform.isIOS) {
      firebaseMessaging.requestNotificationPermissions(IosNotificationSettings());
    }
    firebaseMessaging.configure(
      onBackgroundMessage: myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        Constants.showNotificationWithDefaultSound(
            flutterLocalNotificationsPlugin,
            message['notification']['title'],
            message['notification']['body']);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        Constants.showNotificationWithDefaultSound(
            flutterLocalNotificationsPlugin,
            message['notification']['title'],
            message['notification']['body']);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        Constants.showNotificationWithDefaultSound(
            flutterLocalNotificationsPlugin,
            message['notification']['title'],
            message['notification']['body']);
      },
    );
    databaseService.getConversation(widget.id).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    getUserLocation();
    getUser();
    getCamera();
    focusNode.addListener(onFocusChange);
    isShowSticker = false;
    _loadStickers();
    super.initState();
  }

  Future<void> getCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    firstCamera = cameras.first;
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  List stickerList = new List();
  void _loadStickers() async {
    String data =
        await rootBundle.loadString("sticker_packs/sticker_packs.json");
    final response = json.decode(data);
    List tempList = new List();

    for (int i = 0; i < response['sticker_packs'].length; i++) {
      tempList.add(response['sticker_packs'][i]);
    }
    setState(() {
      stickerList.addAll(tempList);
    });
  }

  List<Tab> listTab(int length) {
    List<Tab> lists = new List<Tab>();
    lists.clear();
    for (int i = 0; i < length; i++) {
      lists.add(Tab(
          child:
              Image.asset("sticker_packs/${i + 1}/1.png", fit: BoxFit.fill)));
    }
    return lists;
  }

  List<Container> listGridView(int length) {
    List<Container> lists = new List<Container>();
    lists.clear();
    for (int i = 0; i < length; i++) {
      StickerModal stickerModal = StickerModal.fromJson(stickerList[i]);
      lists.add(Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(5.0),
        height: 210.0,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white, width: 0.5)),
            color: Colors.white70),
        child: GridView.builder(
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1,
          ),
          itemCount: stickerModal.StickerPack.length - 1,
          itemBuilder: (context, index) {
            var stickerImg =
                "sticker_packs/${i + 1}/${stickerModal.StickerPack[index + 1].image_file}";
            return GestureDetector(
              onTap: () {
                Map<String, dynamic> messageMap = {
                  "message": stickerImg,
                  "sendBy": Constants.myName,
                  "time": DateTime.now().millisecondsSinceEpoch
                };
                databaseService.sendMessage(widget.id, messageMap);
              },
              child: Image.asset(stickerImg, fit: BoxFit.fill),
            );
          },
        ),
      ));
    }
    return lists;
  }

  Widget buildSticker() {
    return Material(
      color: Colors.white70,
      child: DefaultTabController(
        length: stickerList.length,
        child: Column(
          children: [
            TabBar(
                tabs: stickerList.length == 0
                    ? CircularProgressIndicator()
                    : listTab(stickerList.length)),
            Expanded(
              child: TabBarView(
                children: stickerList.length == 0
                    ? CircularProgressIndicator()
                    : listGridView(stickerList.length),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String> uploadFiles(File _image) async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("ImagesChat/${Path.basename(_image.path)}");
    StorageUploadTask uploadTask = ref.putFile(_image);
    await uploadTask.onComplete;
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();
    return url;
  }

  getUser() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    setState(() {
      user = firebaseUser;
    });
  }

  Future<void> _showDialogShareLocation(
      {BuildContext buildContext, String id, Position location}) async {
    return showDialog<void>(
      context: buildContext,
      builder: (context) {
        return AlertDialog(
          title: Text("Chia sẻ vị trí"),
          content: Text("Bạn có muốn chia sẻ vị trí cho mọi người không ? "),
          shape: new RoundedRectangleBorder(
              side: new BorderSide(color: Color(0xFFFFF9C4), width: 2.0),
              borderRadius: BorderRadius.circular(5.0)),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Không")),
            FlatButton(
                onPressed: () {
                  Map<String, dynamic> messageMap = {
                    "message":
                        "Send my location to mina*${location.latitude}*${location.longitude}",
                    "sendBy": Constants.myName,
                    "time": DateTime.now().millisecondsSinceEpoch
                  };
                  databaseService.sendMessage(id, messageMap);
                  Navigator.of(context).pop();
                },
                child: Text("Có"))
          ],
        );
      },
    );
  }
  @override
  void dispose() {
   message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      getUserLocation();
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nameRoomChat),
        actions: [
          IconButton(
              icon: Icon(Icons.location_on),
              tooltip: "Gửi địa chỉ của mình",
              onPressed: () {
                _showDialogShareLocation(
                    location: location, buildContext: context, id: widget.id);
              }),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: chatMessageList()),
            (isShowSticker ? Expanded(child: buildSticker()) : Container()),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(gradient: gradient()),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.photo_camera, color: Colors.white70),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TakePictureScreen(
                                  single: widget.id,
                                  camera: firstCamera,
                                  chatRoomId: widget.nameRoomChat,
                                ),
                              ));
                        }),
                    IconButton(
                        icon:
                            Icon(Icons.insert_emoticon, color: Colors.white70),
                        onPressed: () {
                          getSticker();
                        }),
                    IconButton(
                        icon: Icon(Icons.photo, color: Colors.white70),
                        onPressed: () async {
                          // ignore: deprecated_member_use
                          final file = await ImagePicker.pickImage(
                              source: ImageSource.gallery);
                          if (file == null)
                            return CircularProgressIndicator();
                          else {
                            setState(() {
                              uploadFiles(file).then((value) {
                                if (value != null) {
                                  Map<String, dynamic> messageMap = {
                                    "message": value,
                                    "sendBy": Constants.myName,
                                    "time":
                                        DateTime.now().millisecondsSinceEpoch
                                  };
                                  sendFcmMessage(Constants.myName,"${Constants.myName} đã gửi một sticker");
                                  databaseService.sendMessage(
                                      widget.id, messageMap);
                                } else
                                  CircularProgressIndicator();
                              });
                            });
                          }
                        }),
                    Expanded(
                      child: TextField(
                        controller: message,
                        style: TextStyle(color: Colors.white70),
                        decoration: InputDecoration.collapsed(
                            hintText: "Tin nhắn ...",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (message.text != "") {
                          sendMessage();
                        } else
                          CircularProgressIndicator();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            gradient: gradient2(),
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          padding: EdgeInsets.all(12.0),
                          child: Center(
                              child: Icon(
                            Icons.send,
                            color: Colors.white70,
                          ))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
