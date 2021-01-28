import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  const MessageTile(
      {this.checkSender, this.sendBy, this.message, this.sendByMe});
  final String sendBy;
  final String message;
  final bool sendByMe;
  final bool checkSender;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
            left: sendByMe ? 100 : 25, right: sendByMe ? 25 : 100),
        margin: EdgeInsets.symmetric(vertical: 4),
        width: MediaQuery.of(context).size.width,
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: sendByMe
                  ? EdgeInsets.only(right: 5)
                  : EdgeInsets.only(left: 5),
              child: checkSender
                  ? Text(sendBy, style: TextStyle(fontSize: 15.0))
                  : Container(height: 0, width: 0),
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: sendByMe
                            ? [Colors.redAccent, Colors.red]
                            : [
                                Colors.blue,
                                Color(0xFF64B5F6),
                              ]),
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
          ],
        ));
  }
}
