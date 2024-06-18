import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';
import 'Recognition.dart';

class Recognizer {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;

  late List<int> _inputShape;
  late List<int> _outputShape;

  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  late TfLiteType _inputType;
  late TfLiteType _outputType;

  late var _probabilityProcessor;

  @override
  String get modelName => 'mobile_face_net.tflite';

  @override
  NormalizeOp get preProcessNormalizeOp => NormalizeOp(127.5, 127.5);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 1);

  Recognizer({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter =
          await Interpreter.fromAsset(modelName, options: _interpreterOptions);
      print('Interpreter Created Successfully');

      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;
      _inputType = interpreter.getInputTensor(0).type;
      _outputType = interpreter.getOutputTensor(0).type;

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
      _probabilityProcessor =
          TensorProcessorBuilder().add(postProcessNormalizeOp).build();
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  TensorImage _preProcess() {
    int cropSize = min(_inputImage.height, _inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(
            _inputShape[1], _inputShape[2], ResizeMethod.nearestneighbour))
        .add(preProcessNormalizeOp)
        .build()
        .process(_inputImage);
  }

  Future<Recognition> recognize(Image image, Rect location, String groupID) async {
    final pres = DateTime.now().millisecondsSinceEpoch;
    _inputImage = TensorImage(_inputType);
    _inputImage.loadImage(image);
    _inputImage = _preProcess();
    final pre = DateTime.now().millisecondsSinceEpoch - pres;
    print('Time to load image: $pre ms');
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    print('Time to run inference: $run ms');
    //
    _probabilityProcessor.process(_outputBuffer);
    //     .getMapWithFloatValue();
    // final pred = getTopProbability(labeledProb);
    //print(_outputBuffer.getDoubleList());
    Pair pair = await findNearest(_outputBuffer.getDoubleList(), groupID);
    // print("Pair.name: ${pair.name}");
    // print("Pair.distance: ${pair.distance}");
    return Recognition(
        pair.name, location, _outputBuffer.getDoubleList(), pair.distance);
  }

  //TODO  looks for the nearest embedding in the dataset
  // and retrurns the pair <id, distance>

  Future findNearest(List<double> emb, String groupID) async {
    Pair pair = Pair("Unknown", -5);
    List<dynamic> members = [];
   await FirebaseFirestore.instance.collection("groups").doc(groupID).get().then((value) {
      members = value.get("members");
    });
    //print(members);

    for(dynamic member in members){
      print(member);
      await FirebaseFirestore.instance.collection("users").doc(member.toString()).get().then((value) async{
        if(value.get("isSupervisor") == false){
          await FirebaseFirestore.instance.collection("users").doc(member.toString()).collection("face").get().then((value) {
            dynamic document = value.docs;
            final String name = document[0].id;
            dynamic knownEmb = document[0].get("embeddings");
            
            double distance = 0;
            for (int i = 0; i < emb.length; i++) {
              double diff = emb[i] - knownEmb[i];
              distance += diff * diff;
            }
            distance = sqrt(distance);
            if (pair.distance == -5 || distance < pair.distance) {
              pair.distance = distance;
              pair.name = name;
            }
            // print("Inside");
            // print("Pair.name: ${pair.name}");
            // print("Pair.distance: ${pair.distance}");


          });
        }
      });
    }
    // await FirebaseFirestore.instance.collection("face").get().then((snapshot) {
    //   if (snapshot.docs.isNotEmpty) {
    //     for (var document in snapshot.docs) {
    //       final String name = document.id;
    //       dynamic knownEmb = document.get("embeddings");
    //       // print(name);
    //       // print(knownEmb);
    //       double distance = 0;
    //       for (int i = 0; i < emb.length; i++) {
    //         double diff = emb[i] - knownEmb[i];
    //         distance += diff * diff;
    //       }
    //       distance = sqrt(distance);
    //       if (pair.distance == -5 || distance < pair.distance) {
    //         pair.distance = distance;
    //         pair.name = name;
    //       }
    //       // print("Inside");
    //       // print("Pair.name: ${pair.name}");
    //       // print("Pair.distance: ${pair.distance}");
    //
    //     }
    //   }
    // });

    // for (MapEntry<String, Recognition> item in HomeScreen.registered.entries){
    //   final String name = item.key;
    //   List<double> knownEmb = item.value.embeddings;
    //   print(name);
    //   print(knownEmb);
    //   double distance = 0;
    //   for (int i = 0; i < emb.length; i++) {
    //     double diff = emb[i] - knownEmb[i];
    //     distance += diff*diff;
    //   }
    //   distance = sqrt(distance);
    //   if (pair.distance == -5 || distance < pair.distance) {
    //     pair.distance = distance;
    //     pair.name = name;
    //   }
    // }
    // print("Outside");
    // print("Pair.name: ${pair.name}");
    // print("Pair.distance: ${pair.distance}");


   return pair;
  }

  void close() {
    interpreter.close();
  }
}

class Pair {
  String name;
  double distance;

  Pair(this.name, this.distance);
}

/*

 */
