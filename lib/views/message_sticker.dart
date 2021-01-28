import 'package:flutter/material.dart';

class MessageSticker extends StatelessWidget {
  final String sendBy;
  final String message;
  final bool sendByMe;
  final bool checkSender;
  MessageSticker({this.checkSender, this.message, this.sendByMe, this.sendBy});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        padding: EdgeInsets.only(
            left: sendByMe ? 250 : 25, right: sendByMe ? 25 : 250),
        margin: EdgeInsets.symmetric(vertical: 4),
        width: MediaQuery.of(context).size.width,
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          mainAxisAlignment:
              sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment:
              sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: sendByMe
                  ? EdgeInsets.only(right: 5)
                  : EdgeInsets.only(left: 5),
              child: checkSender
                  ? Text(sendBy, style: TextStyle(fontSize: 15.0))
                  : Container(),
            ),
            Image.asset(message)
          ],
        ));
  }
}
