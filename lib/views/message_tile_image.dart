import 'package:flutter/material.dart';

class MessageTileImage extends StatelessWidget {
  final String message;
  final String sendBy;
  final bool sendByMe;
  final bool checkSender;
  MessageTileImage(
      {this.checkSender, this.message, this.sendByMe, this.sendBy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: sendByMe ? 100 : 25, right: sendByMe ? 25 : 100),
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
            padding:
                sendByMe ? EdgeInsets.only(right: 5) : EdgeInsets.only(left: 5),
            child: checkSender
                ? Text(sendBy, style: TextStyle(fontSize: 15.0))
                : Container(),
          ),
          Image.network(
            message,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
