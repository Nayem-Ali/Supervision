import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supervision/pages/attendance/attendence_page.dart';
import 'package:supervision/pages/initial_page.dart';
import 'package:supervision/utility/constant_login.dart';
import 'package:supervision/utility/reusable_button.dart';
import 'ML/Recognition.dart';
import 'ML/Recognizer.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RecognitionScreen extends StatefulWidget {
  String groupID;

  RecognitionScreen({Key? key, required this.groupID}) : super(key: key);

  @override
  State<RecognitionScreen> createState() => _HomePageState();
}

class _HomePageState extends State<RecognitionScreen> {
  //TODO declare variables
  late ImagePicker imagePicker;
  File? _image;
  var image;
  List<Recognition> recognitions = [];
  List<Face> faces = [];
  List<String> students = [];

  //TODO declare detector
  dynamic faceDetector;
  bool _isLoading = false;

  //TODO declare face recognizer
  late Recognizer _recognizer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();

    //TODO initialize detector
    final options = FaceDetectorOptions(
        enableClassification: false,
        enableContours: false,
        enableLandmarks: false);

    //TODO initalize face detector
    faceDetector = FaceDetector(options: options);

    //TODO initalize face recognizer
    _recognizer = Recognizer();
  }

  //TODO capture image using camera
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      doFaceDetection();
    }
  }

  //TODO choose image using gallery
  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      doFaceDetection();
    }
  }

  //TODO face detection code here
  TextEditingController textEditingController = TextEditingController();

  doFaceDetection() async {
    faces.clear();

    //TODO remove rotation of camera images
    // _image = await removeRotation(_image!);

    //TODO passing input to face detector and getting detected faces
    final inputImage = InputImage.fromFile(_image!);
    faces = await faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      errorDialog();
    }
    //TODO call the method to perform face recognition on detected faces
    performFaceRecognition();
  }

  errorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Oops...",
          textAlign: TextAlign.center,
        ),
        alignment: Alignment.center,
        content: SizedBox(
          height: 70,
          child: Column(
            children: [
              const Text("No face detected. Please try again."),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Ok"),
              )
            ],
          ),
        ),
      ),
    );
  }

  //TODO remove rotation of camera images
  // removeRotation(File inputImage) async {
  //   final img.Image? capturedImage = img.decodeImage( await File(inputImage.path).readAsBytes());
  //   final img.Image orientedImage = img.bakeOrientation(capturedImage!); //bakeOrientation(capturedImage!)
  //   return await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
  // }

  //TODO perform Face Recognition
  performFaceRecognition() async {
    image = await _image?.readAsBytes();
    image = await decodeImageFromList(image);
    // print("${image.width}   ${image.height}");

    recognitions.clear();
    for (Face face in faces) {
      Rect faceRect = face.boundingBox;
      num left = faceRect.left < 0 ? 0 : faceRect.left;
      num top = faceRect.top < 0 ? 0 : faceRect.top;
      num right =
          faceRect.right > image.width ? image.width - 1 : faceRect.right;
      num bottom =
          faceRect.bottom > image.height ? image.height - 1 : faceRect.bottom;
      num width = right - left;
      num height = bottom - top;

      //TODO crop face
      File cropedFace = await FlutterNativeImage.cropImage(_image!.path,
          left.toInt(), top.toInt(), width.toInt(), height.toInt());
      final bytes = await File(cropedFace.path).readAsBytes();
      final img.Image? faceImg = img.decodeImage(bytes);
      Recognition recognition = await _recognizer.recognize(
          faceImg!, face.boundingBox, widget.groupID);
      // print("recognitions: ${recognition.name} and distance: ${recognition.distance}");

      if (recognition.distance > 1) {
        recognition.name = "Unknown";
      }
      recognitions.add(recognition);
    }
    for (Recognition recognition in recognitions) {
      students.add(recognition.name);
    }
    drawRectangleAroundFaces();

  }

  //TODO draw rectangles
  drawRectangleAroundFaces() async {
    setState(() {
      image;
      faces;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            image != null
                ? Container(
                    margin: const EdgeInsets.only(
                        top: 40, left: 30, right: 30, bottom: 0),
                    child: FittedBox(
                      child: SizedBox(
                        width: image.width.toDouble(),
                        height: image.width.toDouble() * 0.8,
                        child: CustomPaint(
                          painter: FacePainter(
                              facesList: recognitions, imageFile: image),
                        ),
                      ),
                    ),
                  )
                : !_isLoading
                    ? Container(
                        margin: const EdgeInsets.only(top: 100),
                        child: Image.asset(
                          "images/profile.jpg",
                          width: screenWidth - 100,
                          height: screenWidth - 100,
                        ),
                      )
                    : SizedBox(
                        height: screenWidth,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),

            // Container(
            //   height: 50,
            // ),
            if (recognitions.isNotEmpty)
              const Text(
                "Recognized Faces",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.teal,
                    fontSize: 24),
              ),
            for (Recognition rectangle in recognitions)
              if (rectangle.name != "Unknown")
                Card(
                  child: ListTile(
                    title: Text("Student ID: ${rectangle.name}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.blueAccent,
                            fontSize: 18)),
                    subtitle: Text(
                        "Confidence: ${rectangle.distance.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.blueGrey,
                            fontSize: 18)),
                  ),
                ),
            //section which displays buttons for choosing and capturing images

            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  if (recognitions.isEmpty)
                    Container(
                      margin: const EdgeInsets.all(18.0),
                      //padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                minimumSize: Size(
                                    screenWidth * 0.4, screenWidth * 0.15)),
                            onPressed: () {
                              setState(() {
                                image = null;
                                _isLoading = true;
                              });
                              _imgFromGallery();
                            },
                            icon: const Icon(
                              Icons.photo,
                              color: kPrimaryColor,
                              size: 35,
                            ),
                            label: const Text(
                              "Gallery",
                              style:
                                  TextStyle(color: kPrimaryColor, fontSize: 18),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.05),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                minimumSize: Size(
                                    screenWidth * 0.4, screenWidth * 0.15)),
                            onPressed: () {
                              setState(() {
                                image = null;
                                _isLoading = true;
                              });
                              _imgFromCamera();
                            },
                            icon: const Icon(Icons.camera,
                                color: kPrimaryColor, size: 35),
                            label: const Text(
                              "Camera",
                              style:
                                  TextStyle(color: kPrimaryColor, fontSize: 18),
                            ),
                          )
                        ],
                      ),
                    ),
                  if (recognitions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Button(
                          buttonName: "Retake",
                          onPressed: () {
                            setState(() {
                              image = null;
                              _isLoading = false;
                              recognitions.clear();
                            });
                          }),
                    ),
                  Button(
                      buttonName: "Submit",
                      onPressed: () async {
                        //Navigator.pop(context);
                        String? name;
                        await FirebaseFirestore.instance
                            .collection("groups")
                            .doc(widget.groupID)
                            .get()
                            .then((value) {
                          name = value.get("groupName");
                        });

                        Get.to(
                            () => InitialPage(
                                  groupId: widget.groupID,
                                  groupName: name!,
                                ),
                            arguments: students);
                      }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Recognition> facesList;
  dynamic imageFile;

  FacePainter({required this.facesList, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    Paint p = Paint();
    p.color = Colors.red;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;

    for (Recognition rectangle in facesList) {
      canvas.drawRect(rectangle.location, p);
      TextSpan span = TextSpan(
          style: const TextStyle(color: Colors.red, fontSize: 100,backgroundColor: Colors.white),

          text: rectangle.name != "Unknown"
              ? rectangle.name.substring(7, 10)
              : "N/A");
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.end,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(rectangle.location.left, rectangle.location.bottom + 20));
    }

    Paint p2 = Paint();
    p2.color = Colors.green;
    p2.style = PaintingStyle.stroke;
    p2.strokeWidth = 3;

    Paint p3 = Paint();
    p3.color = Colors.yellow;
    p3.style = PaintingStyle.stroke;
    p3.strokeWidth = 1;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
