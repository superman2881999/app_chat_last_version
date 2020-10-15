import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_app_chat_last_version/helper/constans.dart';
import 'package:flutter_app_chat_last_version/helper/helperFunctions.dart';
import 'package:flutter_app_chat_last_version/modals/OneBarChartModal.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';

class MessageStatistics extends StatefulWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  MessageStatistics(this.seriesList, {this.animate});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _MessageStatisticsState(seriesList, animate: animate);
  }
}

class _MessageStatisticsState extends State<MessageStatistics> {
  final List<charts.Series> seriesList;
  final bool animate;
  _MessageStatisticsState(this.seriesList, {this.animate});

  DatabaseService databaseService = new DatabaseService();
  Stream chatRoomsStream;

  @override
  void initState() {
    // TODO: implement initState
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getuserNameSharePreference();
    databaseService.getChatRooms(Constants.myName).then((value) {
      setState(() {
        chatRoomsStream = value;
      });
    });

  }

  Widget ChatRoomList() {
    final List<OneBarChartModal> data = new List<OneBarChartModal>();
    data.clear();
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        if (snapshot.data == null)
          return CircularProgressIndicator();
        for (int i = 0; i < snapshot.data.documents.length; i++) {
          List<String> username = snapshot
              .data.documents[i].data["chatroomid"]
              .toString()
              .split("_");
         databaseService.getLengthOfConversation(snapshot.data.documents[i].data["chatroomid"]).then((QuerySnapshot snapshot){
           snapshot.documents.forEach(
                 (DocumentSnapshot documentSnapshot) {
               // prints all the documents available
               // in the collection
               debugPrint(documentSnapshot.data.toString());
             },
           );
         });
              // data.add(new OneBarChartModal(
              //     messageCount: lengthMessage,
              //     name: username[0]));

        }

        return snapshot.hasData
            ? charts.BarChart(
                _createSampleData(data),
                barGroupingType: charts.BarGroupingType.grouped,
                animationDuration: Duration(seconds: 2),
                animate: true,
                vertical: true,
                barRendererDecorator: new charts.BarLabelDecorator<String>(),
                domainAxis: new charts.OrdinalAxisSpec(),
                behaviors: [
                  // Adding this behavior will allow tapping a bar to center it in the viewport
                  charts.SlidingViewport(
                    charts.SelectionModelType.action,
                  ),
                  charts.PanBehavior(),
                ],
              )
            : Container(child: Center(child: CircularProgressIndicator()));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // For horizontal bar charts, set the [vertical] flag to false.
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        margin: EdgeInsets.all(20.0),
        child: ChatRoomList(),
      ),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<OneBarChartModal, String>> _createSampleData(
      List<OneBarChartModal> data) {
    return [
      new charts.Series<OneBarChartModal, String>(
        id: 'Name',
        labelAccessorFn: (OneBarChartModal barchar, _) =>
            '${barchar.messageCount.toString()}',
        displayName: "Name",
        colorFn: (OneBarChartModal barchar, __) =>
            charts.MaterialPalette.purple.shadeDefault,
        domainFn: (OneBarChartModal barchar, _) => barchar.name,
        measureFn: (OneBarChartModal barchar, _) => barchar.messageCount,
        data: data,
      )
    ];
  }
}
