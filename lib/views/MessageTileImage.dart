import 'package:flutter/material.dart';


class MessageTileImage extends StatelessWidget{
  final String message;
  final bool sendByMe;
  MessageTileImage({this.message, this.sendByMe});


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        padding:
        EdgeInsets.only(left: sendByMe ? 100 : 25, right: sendByMe ? 25 : 100),
        margin: EdgeInsets.symmetric(vertical: 4),
        width: MediaQuery.of(context).size.width,
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Image.network(message),
    );
  }
}