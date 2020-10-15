import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/authenticate.dart';
import 'package:flutter_app_chat_last_version/helper/constans.dart';
import 'package:flutter_app_chat_last_version/service/authService.dart';
import 'package:flutter_app_chat_last_version/views/MessageStatistics.dart';

class Draw extends StatefulWidget{
  final AuthService authService;
  final BuildContext context;
  Draw({this.authService,this.context});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new DrawState();
  }
}
class DrawState extends State<Draw>{

  Future<void> _showDialog(AuthService authService, BuildContext buildContext) async {
    return showDialog <void> (context: buildContext,builder: (context) {
      return AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure to logout ? "),
        shape: new RoundedRectangleBorder(
            side: new BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(5.0)),
        actions: [
          FlatButton(onPressed: () {
            Navigator.of(context).pop();
          }, child: Text("No")),
          FlatButton(onPressed: () {
            authService.signOut();
            Navigator.pop(context,true);
            Navigator.pushReplacement(
                buildContext,
                MaterialPageRoute(
                  builder: (buildContext) => Authenticate(),
                ));
          }, child: Text("Yes"))
        ],
      );
    },);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final draw = new Drawer(
      child: new ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          new DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: new Container(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    new Image.asset(
                      "images/avatar.jpg",
                      fit: BoxFit.cover,
                      width: 100.0,
                      height: 100.0,
                    ),
                    new Text(
                      Constants.myName,
                      style: new TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold,fontSize: 20.0),
                    )
                  ],
                ),
              )),
          new Container(
            margin: EdgeInsets.only(left: 20.0),
            child: Text("ACCOUNT & SUPPORT",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                )),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => MessageStatistics(null,animate: null,),));
            },
            child: new ListTile(
                leading: Icon(Icons.show_chart),
                title: Text("Message statistics")),
          ),
          new ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("Account Setting")),
          new ListTile(leading: Icon(Icons.help), title: Text("Help")),
          new Divider(
            color: Colors.black54,
            indent: 10.0,
          ),
          SizedBox(height: 150.0,),
          Container(child: IconButton(onPressed: () {
            _showDialog(widget.authService,widget.context);
          },icon: Icon(Icons.exit_to_app),)),
          Container(alignment: Alignment.center,child: Text("Log out")),
        ],
      ),
    );
    return draw;
  }
}