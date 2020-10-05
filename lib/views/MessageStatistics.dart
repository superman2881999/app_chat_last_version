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
    return new _MessageStatisticsState(seriesList,animate: animate);
  }
}

class _MessageStatisticsState extends State<MessageStatistics> {
  final List<charts.Series> seriesList;
  final bool animate;
  _MessageStatisticsState(this.seriesList, {this.animate});

  DatabaseService databaseService = new DatabaseService();
  Stream chatRoomsStream;

  /// Creates a [BarChart] with sample data and no transition.
  factory _MessageStatisticsState.withSampleData() {
    return new _MessageStatisticsState(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }

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
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {

        return snapshot.hasData
            ?
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
        child: new charts.BarChart(
          _createSampleData(),
          barGroupingType: charts.BarGroupingType.grouped,
          animationDuration: Duration(seconds: 3),
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
        ),
      ),

    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<OneBarChartModal, String>> _createSampleData() {
    final data = [
      new OneBarChartModal(),
      new OneBarChartModal(),
      new OneBarChartModal(),
      new OneBarChartModal(),

    ];

    return [
      new charts.Series<OneBarChartModal, String>(
        id: 'Name',
        labelAccessorFn: (OneBarChartModal barchar, _) => '${barchar.messageCount.toString()}',
        displayName: "Name",
        colorFn: (OneBarChartModal barchar, __) => charts.MaterialPalette.purple.shadeDefault,
        domainFn: (OneBarChartModal barchar, _) => barchar.name,
        measureFn: (OneBarChartModal barchar, _) => barchar.messageCount,
        data: data,
      )
    ];
  }
}
