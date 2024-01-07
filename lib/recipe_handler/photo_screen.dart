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
    if (label.isNotEmpty && !detectedObjects.contains(label)) {
      /*detectedObjects.add(label);
        print(detectedObjects);*/
      setState(() {
        label = detector!.first['label'].toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    detectedObjects.clear();
    _cameraController = CameraController(cameras[0], ResolutionPreset.max);
    _cameraController.initialize().then((value) {
      _cameraController.startImageStream((image) {
        cameraCount++;
        if (cameraCount % 10 == 0) {
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
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: screenSize.height * 0.05),
                height: screenSize.height * 0.75,
                // Adjust the height as needed
                width: screenSize.width,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                ),
                child: CameraPreview(
                    _cameraController), // Placeholder for camera preview
              ),
              if (label.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (!detectedObjects.contains(label)) {
                          detectedObjects.add(label);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      color: Colors.white,
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                  spacing: 8.0, // Gap between adjacent chips
                  runSpacing: 4.0, // Gap between lines
                  children: List<Widget>.generate(
                    detectedObjects.length,
                    (int index) {
                      return Chip(
                        labelPadding: EdgeInsets.all(2.0),
                        avatar: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: Text(detectedObjects[index][0].toUpperCase()),
                        ),
                        label: Text(
                          detectedObjects[index],
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        backgroundColor: Colors.grey[300],
                        padding: EdgeInsets.all(8.0),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 70.0,
        width: 70.0,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              _cameraController.dispose();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => IngredientsPage(preselectedIngredients: detectedObjects),
                ),
              );
            },
            backgroundColor: Color(0xFFC3C1C1),
            elevation: 8.0,
            shape: const CircleBorder(
              side: BorderSide.none,
            ),
            child: const Icon(Icons.navigate_next_rounded,
                size: 40.0, color: Colors.black),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        color: Color(0xFFD9D9D9),
        height: 60.0,
        shape: null,
      ),
    );
  }
}
