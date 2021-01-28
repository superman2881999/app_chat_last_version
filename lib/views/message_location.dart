import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/constant.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'home.dart';

class MessageLocation extends StatefulWidget {
  MessageLocation({this.locationDes,this.checkSender, this.message, this.sendByMe, this.sendBy});
  final String sendBy;
  final String message;
  final bool sendByMe;
  final bool checkSender;
  final List<String> locationDes;
  @override
  State<StatefulWidget> createState() {
    return MessageLocationState();
  }
}

class MessageLocationState extends State<MessageLocation> {
  // Object for PolylinePoints
  PolylinePoints polylinePoints;

// List of coordinates to join
  List<LatLng> polylineCoordinates = [];

  // For controlling the view of the Map
  GoogleMapController mapController;

  // Map storing polyLines created by connecting
// two points
  Map<PolylineId, Polyline> polyLines = {};

  Position _currentPosition = HomeScreen.currentLocation;

  Position des;

  Set<Marker> markers = {};

  _createPolyLines(Position start, Position destination) async {
    markers.clear();
    polylineCoordinates.clear();
    polyLines.clear();
    // Destination Location Marker
    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: LatLng(
        destination.latitude,
        destination.longitude,
      ),
      // infoWindow: InfoWindow(
      //   title: 'Destination',
      //   snippet: _destinationAddress,
      // ),
      icon: BitmapDescriptor.defaultMarker,
    );
    // Add the markers to the list
    markers.add(destinationMarker);
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constants.key, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );
    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print("khong co diem nao");
    }
    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    // Adding the polyline to the map
    polyLines[id] = polyline;

    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition.latitude,
      _currentPosition.longitude,
      destination.latitude,
      destination.longitude,
    );
    print(distanceInMeters);
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
          // Store the position in the variable
          _currentPosition = position;
          // For moving the camera to current location
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 18.0,
              ),
            ),
          );

    }).catchError((e) {
      print(e);
    });
  }

  void showAsBottomSheet() async {
    await showSlidingBottomSheet(context, builder: (context) {
      return SlidingSheetDialog(
        elevation: 8,
        cornerRadius: 16,
        snapSpec: const SnapSpec(
          snap: true,
          snappings: [0.4, 0.7, 1.0],
          positioning: SnapPositioning.relativeToAvailableSpace,
        ),
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Stack(
                children: <Widget>[
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                        target: LatLng(_currentPosition.latitude,
                            _currentPosition.longitude)),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: false,
                    markers: markers != null ? Set<Marker>.from(markers) : null,
                    polylines: Set<Polyline>.of(polyLines.values),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                //Zoom nhỏ bản đồ
                                mapController
                                    .animateCamera(CameraUpdate.zoomIn());
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.yellow),
                                child: const Icon(
                                  Icons.zoom_in,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                //Zoom to bản đồ
                                mapController
                                    .animateCamera(CameraUpdate.zoomOut());
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.yellow),
                                child: const Icon(
                                  Icons.zoom_out,
                                ),
                              ),
                            ),
                          ],
                        ),
                        //Widget này giúp người dùng quay về vị trí của mình trên bản đồ
                        FloatingActionButton(
                          backgroundColor: Colors.yellow,
                          onPressed: () {
                            setState(() {
                              mapController.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                      target: LatLng(_currentPosition.latitude,
                                          _currentPosition.longitude),
                                      zoom: 15),
                                ),
                              );
                            });
                          },
                          child: const Icon(Icons.my_location),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getCurrentLocation().then((_) {
      _createPolyLines(
          _currentPosition,
          Position(
          latitude: double.tryParse(widget.locationDes[1]),
          longitude: double.tryParse(widget.locationDes[2])));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentLocation().then((_) {
      _createPolyLines(_currentPosition, Position(
      latitude: double.tryParse(widget.locationDes[1]),
      longitude: double.tryParse(widget.locationDes[2])));
    });
    return Container(
        padding: EdgeInsets.only(
            left: widget.sendByMe ? 120 : 25,
            right: widget.sendByMe ? 25 : 120),
        margin: EdgeInsets.symmetric(vertical: 4),
        width: MediaQuery.of(context).size.width,
        alignment:
            widget.sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          mainAxisAlignment:
              widget.sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: widget.sendByMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: widget.sendByMe
                  ? EdgeInsets.only(right: 5)
                  : EdgeInsets.only(left: 5),
              child: widget.checkSender
                  ? Text(widget.sendBy, style: TextStyle(fontSize: 15.0))
                  : Container(),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFE0E0E0),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                        child: Icon(Icons.near_me, color: Colors.blue)),
                    title: Text("Vị trí trực tiếp"),
                    subtitle: Text("${widget.sendBy} đã chia sẻ vị trí của họ"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Color(0xFF64B5F6),
                      onPressed: () {
                        showAsBottomSheet();
                      },
                      child: Center(
                        child: Text("Chỉ đường",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
