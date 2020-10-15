import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_app_chat_last_version/helper/constans.dart';
import 'package:flutter_app_chat_last_version/modals/StickerModal.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';
import 'package:flutter_app_chat_last_version/service/TakePicture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

import 'MessageSticker.dart';
import 'MessageTileImage.dart';

class ConversationScreen extends StatefulWidget {
  String chatRoomId;
  ConversationScreen({this.chatRoomId});
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

  final FocusNode focusNode = new FocusNode();

  Widget ChatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  String isCheck = "https://firebasestorage.googleapis.com/";
                  String isSticker = "sticker_packs/";
                  if (snapshot.data.documents[index].data["message"]
                      .toString()
                      .contains(isCheck)) {
                    return MessageTileImage(
                      message: snapshot.data.documents[index].data["message"],
                      sendByMe: snapshot.data.documents[index].data["sendBy"] ==
                          Constants.myName,
                    );
                  } else if (snapshot.data.documents[index].data["message"]
                      .toString()
                      .contains(isSticker)) {
                    return MessageSticker(
                      sendByMe: snapshot.data.documents[index].data["sendBy"] ==
                          Constants.myName,
                      message: snapshot.data.documents[index].data["message"],
                    );
                  }
                  return MessageTile(
                      message: snapshot.data.documents[index].data["message"],
                      sendByMe: snapshot.data.documents[index].data["sendBy"] ==
                          Constants.myName);
                },
              )
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
      databaseService.addConversation(widget.chatRoomId, messageMap);
      message.text = "";
    }
  }

  @override
  void initState() {
    // TODO: implement
    databaseService.getConversation(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
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
                databaseService.addConversation(widget.chatRoomId, messageMap);
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
  
  handleInput(String message) {
    databaseService.uploadNotification(widget.chatRoomId, message, user.email);
  }

  @override
  Widget build(BuildContext context) {
    List<String> username = widget.chatRoomId.split("_");
    return Scaffold(
      appBar: AppBar(
        title: Text(username[0]),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: ChatMessageList()),
            (isShowSticker ? Expanded(child: buildSticker()) : Container()),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(gradient: gradient()),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.photo_camera, color: Colors.white70),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TakePictureScreen(
                                  camera: firstCamera,
                                  chatRoomId: widget.chatRoomId,
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
                          final file = await ImagePicker.pickImage(
                              source: ImageSource.gallery);
                          if (file == null)
                            return CircularProgressIndicator();
                          else {
                            setState(() {
                              uploadFiles(file).then((value){
                                if(value != null){
                                  Map<String, dynamic> messageMap = {
                                    "message": value,
                                    "sendBy": Constants.myName,
                                    "time": DateTime.now().millisecondsSinceEpoch
                                  };
                                  databaseService.addConversation(
                                      widget.chatRoomId, messageMap);
                                }
                                else CircularProgressIndicator();
                              });
                            });
                          }
                        }),
                    Expanded(
                      child: TextField(
                        controller: message,
                        style: TextStyle(color: Colors.white70),
                        decoration: InputDecoration.collapsed(
                            hintText: "Message...",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none),
                        onSubmitted: handleInput(message.text),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        handleInput(message.text);
                        sendMessage();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            gradient: gradient(),
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

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  MessageTile({this.message, this.sendByMe});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Container(
      padding: EdgeInsets.only(
          left: sendByMe ? 100 : 25, right: sendByMe ? 25 : 100),
      margin: EdgeInsets.symmetric(vertical: 4),
      width: MediaQuery.of(context).size.width,
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: sendByMe
                      ? [const Color(0xFF42A5F5), const Color(0xFF1565C0)]
                      : [Colors.black87, Colors.black54]),
              borderRadius: sendByMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      topRight: Radius.circular(20.0))
                  : BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                      topLeft: Radius.circular(20.0))),
          child: Text(message,
              style: TextStyle(color: Colors.white, fontSize: 17.0))),
    );
  }
}
