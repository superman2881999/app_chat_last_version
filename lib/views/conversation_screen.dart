import 'dart:convert';
import 'dart:io' as Io;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/constans.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';
import 'package:flutter_app_chat_last_version/service/TakePicture.dart';

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

  Widget ChatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                 String isCheck = "/data/user/0/com.example.flutter_app_chat_last_version/cache/";
                  return snapshot.data.documents[index].data["message"].toString().contains(isCheck) ? MessageTileImage(message: snapshot.data.documents[index].data["message"],sendByMe: snapshot.data.documents[index].data["sendBy"] ==
                      Constants.myName,) : MessageTile(
                      message: snapshot.data.documents[index].data["message"],
                      sendByMe: snapshot.data.documents[index].data["sendBy"] ==
                          Constants.myName);
                },
              )
            : Container(
                child: Center(child: new CircularProgressIndicator()),);
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
    getCamera();
    super.initState();
  }
  Future<void> getCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
   firstCamera = cameras.first;
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
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(gradient: gradient()),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Row(
                  children: [
                    IconButton(icon: Icon(Icons.photo_camera,color: Colors.white70), onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera,chatRoomId: widget.chatRoomId,),));
                    }),
                    IconButton(icon: Icon(Icons.photo,color: Colors.white70), onPressed: (){}),
                    Expanded(
                      child: TextField(
                        controller: message,
                        style: TextStyle(color: Colors.white70),
                        decoration: InputDecoration.collapsed(
                            hintText: "Message...",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            gradient: gradient(),
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          padding: EdgeInsets.all(12.0),
                          child: Center(child: Icon(Icons.send,color: Colors.white70,))),
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
      padding:
          EdgeInsets.only(left: sendByMe ? 100 : 25, right: sendByMe ? 25 : 100),
      margin: EdgeInsets.symmetric(vertical: 4),
      width: MediaQuery.of(context).size.width,
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child:Container(
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
          child: Text(message, style: TextStyle(color: Colors.white,fontSize: 17.0))),
    );
  }
}
class MessageTileImage extends StatelessWidget{
  final String message;
  final bool sendByMe;
  MessageTileImage({this.message, this.sendByMe});

  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final bytes = Io.File(message).readAsBytesSync();
    String img64 = base64Encode(bytes);
    return Container(
        padding:
        EdgeInsets.only(left: sendByMe ? 100 : 25, right: sendByMe ? 25 : 100),
        margin: EdgeInsets.symmetric(vertical: 4),
        width: MediaQuery.of(context).size.width,
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: imageFromBase64String(img64));
  }
}
