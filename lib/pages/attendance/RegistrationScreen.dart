import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supervision/log_in/sign_up.dart';
import 'package:supervision/utility/constant_login.dart';
import 'ML/Recognition.dart';
import 'ML/Recognizer.dart';
import 'databaseService/dbService.dart';

class RegistrationScreen extends StatefulWidget {
  String uid;

  RegistrationScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _HomePageState();
}

class _HomePageState extends State<RegistrationScreen> {
  DBService db = DBService();

  //TODO declare variables
  late ImagePicker imagePicker;
  File? _image;
  var image;
  List<Face> faces = [];

  //TODO declare detector
  dynamic faceDetector;

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

    //TODO initialize face detector
    faceDetector = FaceDetector(options: options);

    //TODO initialize face recognizer
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
    _image = await removeRotation(_image!);

    //TODO passing input to face detector and getting detected faces
    final inputImage = InputImage.fromFile(_image!);
    faces = await faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      errorDialog();
    }
    //TODO call the method to perform face recognition on detected faces
    performFaceRecognition();
  }

  //TODO remove rotation of camera images
  removeRotation(File inputImage) async {
    final img.Image? capturedImage =
        img.decodeImage(await File(inputImage.path).readAsBytes());
    final img.Image orientedImage = img.bakeOrientation(capturedImage!);
    return await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
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

  //TODO perform Face Recognition
  performFaceRecognition() async {
    image = await _image!.readAsBytes();
    image = await decodeImageFromList(image);
    print("${image.width}   ${image.height} perform recogniton");

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
      Recognition recognition =
          await _recognizer.recognize(faceImg!, face.boundingBox, "");

      //TODO show face registration dialogue
      showFaceRegistrationDialogue(cropedFace, recognition);
    }
    drawRectangleAroundFaces();
  }

  //TODO Face Registration Dialogue
  showFaceRegistrationDialogue(File cropedFace, Recognition recognition) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Face Registration", textAlign: TextAlign.center),
        alignment: Alignment.center,
        content: SizedBox(
          height: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.file(
                cropedFace,
                width: 200,
                height: 200,
              ),
              SizedBox(
                width: 200,
                child: TextField(
                    controller: textEditingController,
                    decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Enter your student ID: ")),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    // HomeScreen.registered.putIfAbsent(
                    //     textEditingController.text, () => recognition);
                    db.addDatabase(
                        textEditingController.text, recognition, widget.uid);
                    textEditingController.text = "";
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Face Registered"),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      minimumSize: const Size(200, 40)),
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  //TODO draw rectangles
  drawRectangleAroundFaces() async {
    image = await _image!.readAsBytes();
    image = await decodeImageFromList(image);
    print("${image.width}   ${image.height}");
    print("Draw Rectangle");
    setState(() {
      image;
      faces;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Face Registration"),
        actions: [
          BackButton(
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          signUp()));
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          image != null
              ? Container(
                  margin: const EdgeInsets.only(
                      top: 60, left: 30, right: 30, bottom: 0),
                  child: FittedBox(
                    child: SizedBox(
                      width: image.width.toDouble(),
                      height: image.width.toDouble(),
                      child: CustomPaint(
                        painter:
                            FacePainter(facesList: faces, imageFile: image),
                      ),
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: Image.asset(
                    "images/profile.jpg",
                    width: screenWidth - 100,
                    height: screenWidth - 100,
                  ),
                ),

          Container(
            height: 50,
          ),

          //section which displays buttons for choosing and capturing images
          Container(
            margin: const EdgeInsets.only(bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(200))),
                  child: InkWell(
                    onTap: () {
                      _imgFromGallery();
                    },
                    child: SizedBox(
                      width: screenWidth / 2 - 100,
                      height: screenWidth / 2 - 100,
                      child: Icon(Icons.image,
                          color: kPrimaryColor, size: screenWidth / 7),
                    ),
                  ),
                ),
                Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(200))),
                  child: InkWell(
                    onTap: () {
                      _imgFromCamera();
                    },
                    child: SizedBox(
                      width: screenWidth / 2 - 100,
                      height: screenWidth / 2 - 100,
                      child: Icon(Icons.camera,
                          color: kPrimaryColor, size: screenWidth / 7),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Face> facesList;
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

    for (Face face in facesList) {
      canvas.drawRect(face.boundingBox, p);
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
