import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cooking_app/ingredients_selector_screen.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

late List<CameraDescription> cameras;


Future<void> initCamera() async {
  cameras = await availableCameras();
}


class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(cameras[0], ResolutionPreset.max);
    _cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Take a Photo'),
      ),
      body: _cameraController.value.isInitialized
          ? Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: screenSize.height * 0.05),
            child: Container(
              height: screenSize.height * 0.7,
              width: screenSize.width,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 3,
                ),
              ),
              child: CameraPreview(_cameraController),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.camera),
                label: Text("Take Photo"),
                onPressed: () async {
                  try {
                    if (_cameraController.value.isInitialized) {
                      final image = await _cameraController.takePicture();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              IngredientsPage(),
                        ),
                      );
                    }
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}