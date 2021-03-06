import 'dart:async';
import 'dart:io' as Io;

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/constant.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:path/path.dart' show join;
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    this.single,
    this.camera,
    this.chatRoomId,
  });
  final CameraDescription camera;
  final String chatRoomId;
  final String single;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  DatabaseService databaseService = new DatabaseService();
  @override
  void initState() {
    super.initState();

    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<String> uploadFiles(Io.File _image) async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("ImagesChat/${Path.basename(_image.path)}");
    StorageUploadTask uploadTask = ref.putFile(_image);
    await uploadTask.onComplete;
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chụp ảnh')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );
            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);
            Io.File file = Io.File(path);
            setState(() {
              uploadFiles(file).then((value) {
                if (value != null) {
                  Map<String, dynamic> messageMap = {
                    "message": value,
                    "sendBy": Constants.myName,
                    "time": DateTime.now().millisecondsSinceEpoch
                  };
                  databaseService.sendMessage(widget.single, messageMap);
                } else
                  CircularProgressIndicator();
              });
            });
            Navigator.pop(context, true);
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}
