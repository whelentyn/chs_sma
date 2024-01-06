import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cooking_app/recipe_handler/ingredients_selector_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

late List<CameraDescription> cameras;

var cameraCount = 0;
String label = "";

List<String> detectedObjects = [];

Future<void> initCamera() async {
  cameras = await availableCameras();
}

Future<void> initTflite() async {
  await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false);
}

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  late CameraController _cameraController;

  objectDetector(CameraImage image) async {
    var detector = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((e) {
          return e.bytes;
        }).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 1,
        threshold: 0.4,
        asynch: false);
    label = detector!.first['label'].toString();
    if(label.isNotEmpty && !detectedObjects.contains(label)) {
        detectedObjects.add(label);
        print(detectedObjects);
        setState(() {
          label = detector!.first['label'].toString();
        });
    }
  }

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(cameras[0], ResolutionPreset.max);
    _cameraController.initialize().then((value) {
      _cameraController.startImageStream((image) {
        cameraCount++;
        if(cameraCount % 10 == 0) {
          cameraCount = 0;
          objectDetector(image);
        }
      });
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
                  child: Stack(
                    children: [
                      Container(
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
                      if (label != null && label.isNotEmpty)
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: Colors.white,
                            child: Text(
                              '$label',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.camera),
                      label: const Text("Take Photo"),
                      onPressed: () {
                        _cameraController.dispose();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IngredientsPage(),
                              ),
                            );
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
