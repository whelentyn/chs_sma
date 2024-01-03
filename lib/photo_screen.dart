import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
    _cameraController.initialize().then((_) {
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
    // Get the size of the screen
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Take a Photo'),
      ),
      body: _cameraController.value.isInitialized
          ? Stack(
        children: [
          Padding(
            // Add padding to push the camera box up a bit
            padding: EdgeInsets.only(top: screenSize.height * 0.05), // Adjust this value as needed
            child: Container(
              // Set the height to a specific value or a proportion of the screen height
              height: screenSize.height * 0.7, // 70% of the screen height
              width: screenSize.width, // Match the screen width
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
                          builder: (context) => DisplayPictureScreen(imagePath: image.path),
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

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}