import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/models/one_bar_chart_model.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_app_chat_last_version/widgets/widget.dart';

// ignore: must_be_immutable
class ChartLengthGroup extends StatelessWidget {
  ChartLengthGroup({this.amount,this.chatRoomsGroupStream,this.databaseService,this.resizableController});
  final Stream chatRoomsGroupStream;
  final DatabaseService databaseService;
  final AnimationController resizableController;
  final int amount;

  QuerySnapshot groupInfoSnapshot;
  String nameGroup;
  List<OneBarChartModal> data = new List<OneBarChartModal>();
  List<charts.Series<OneBarChartModal, String>> _createSampleData(
      List<OneBarChartModal> data) {
    return [
      new charts.Series<OneBarChartModal, String>(
        id: 'Name',
        labelAccessorFn: (OneBarChartModal barchar, _) =>
        '${barchar.messageCount.toString()}',
        displayName: "Name",
        colorFn: (OneBarChartModal barchar, __) =>
        charts.MaterialPalette.deepOrange.shadeDefault,
        domainFn: (OneBarChartModal barchar, _) => barchar.name,
        measureFn: (OneBarChartModal barchar, _) => barchar.messageCount,
        data: data,
      )
    ];
  }
  @override
  Widget build(BuildContext context) {
    data.clear();
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: StreamBuilder(
              stream: chatRoomsGroupStream,
              builder: (context, snapshot) {
                if (snapshot.data == null) return CircularProgressIndicator();
                for (int i = 0; i < snapshot.data.documents.length; i++) {
                  databaseService
                      .getLengthOfGroupConversation(
                      snapshot.data.documents[i].data["groupId"])
                      .then((value) async {
                    groupInfoSnapshot = await value;
                    nameGroup = snapshot.data.documents[i].data["groupName"];
                    data.add(new OneBarChartModal(
                        messageCount: groupInfoSnapshot.documents.length,
                        name: nameGroup));
                  });
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
                    charts.SlidingViewport(
                      charts.SelectionModelType.action,
                    ),
                    charts.PanBehavior(),
                  ],
                )
                    : Container(child: Center(child: CircularProgressIndicator()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top:10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                card("Đã tham gia",amount,"nhóm",resizableController),
                card("Là admin của",1,"nhóm",resizableController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
