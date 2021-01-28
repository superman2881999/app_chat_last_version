import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/authenticate.dart';
import 'package:flutter_app_chat_last_version/helper/constant.dart';
import 'package:flutter_app_chat_last_version/service/auth_service.dart';
import 'package:flutter_app_chat_last_version/views/message_statistics.dart';
import 'package:flutter_app_chat_last_version/views/profile.dart';
import 'package:rating_dialog/rating_dialog.dart';

class Draw extends StatefulWidget {
  final AuthService authService;
  final BuildContext context;
  Draw({this.authService, this.context});
  @override
  State<StatefulWidget> createState() {
    return new DrawState();
  }
}

class DrawState extends State<Draw> {
  FirebaseUser _user;

  Future<void> _showDialog(
      AuthService authService, BuildContext buildContext) async {
    return showDialog<void>(
      context: buildContext,
      builder: (context) {
        return AlertDialog(
          title: Text("Đăng xuất"),
          content: Text("Bạn có chắc muốn đăng xuất không ? "),
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
                  authService.signOut();
                  Navigator.pop(context, true);
                  Navigator.pushReplacement(
                      buildContext,
                      MaterialPageRoute(
                        builder: (buildContext) => Authenticate(),
                      ));
                },
                child: Text("Có"))
          ],
        );
      },
    );
  }

  getUid() async {
    _user = await FirebaseAuth.instance.currentUser();
  }

  @override
  void initState() {
    setState(() {
      getUid();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final draw = new Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    CircleAvatar(
                        backgroundImage:
                            Constants.urlAvt == "images/Avt_Default.jpg"
                                ? AssetImage(Constants.urlAvt)
                                : NetworkImage(Constants.urlAvt),
                        maxRadius: 50),
                    Text(
                      Constants.myName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17.0),
                    )
                  ],
                )),
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text("TÀI KHOẢN & HỖ TRỢ",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  )),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MessageStatistics(uidUser: _user.uid)));
              },
              child: ListTile(
                  leading: Icon(Icons.show_chart),
                  title: Text("Thống kê tin nhắn")),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileUser()));
              },
              child: ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text("Thông tin tài khoản")),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    barrierDismissible: true, // set to false if you want to force a rating
                    builder: (context) {
                      return RatingDialog(
                        icon: Image.asset("images/iconApp.png",height: 100), // set your own image/icon widget
                        title: "Đánh giá",
                        description:
                        "Nhấn vào một dấu sao để đặt xếp hạng của bạn. Thêm mô tả khác ở đây nếu bạn muốn.",
                        submitButton: "Gửi đánh giá",
                        alternativeButton: "Liên hệ với chúng tôi?", // optional
                        positiveComment: "Chúng tôi rất vui 😍", // optional

                        negativeComment: "Chúng tôi rất buồn 🙁", // optional
                        accentColor: Colors.red, // optional
                        onSubmitPressed: (int rating) {
                          print("onSubmitPressed: rating = $rating");
                          Constants.toastAddSuccess(context,"Cảm ơn bạn đã đánh giá ứng dụng của chúng tôi");
                        },
                        onAlternativePressed: () {
                          print("onAlternativePressed: do something");
                          // TODO: maybe you want the user to contact you instead of rating a bad review
                        },
                      );
                    });
              },
                child: ListTile(leading: Icon(Icons.star_border), title: Text("Đánh giá ứng dụng"))),
            Divider(
              color: Colors.black54,
              indent: 10.0,
            ),
            SizedBox(
              height: 150.0,
            ),
            Container(
                child: IconButton(
              onPressed: () {
                _showDialog(widget.authService, widget.context);
              },
              icon: Icon(Icons.exit_to_app),
            )),
            Container(alignment: Alignment.center, child: Text("Đăng xuất")),
          ],
        ),
      ),
    );
    return draw;
  }
}
