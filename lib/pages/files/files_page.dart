import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supervision/utility/constant_login.dart';

class FilesPage extends StatefulWidget {
  String groupId;

  FilesPage({Key? key, required this.groupId}) : super(key: key);

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  late Future<ListResult> futureFiles;
  final Dio dio = Dio();
  double progress = 0;

  @override
  void initState() {
    super.initState();
    getListOfFiles();
  }

  getListOfFiles() {
    futureFiles = FirebaseStorage.instance.ref('/${widget.groupId}').list();
  }

  Future deleteFile(Reference ref) async {
    try {
      ref.delete();
      setState(() {
        getListOfFiles();
      });
    } on FirebaseException catch (e) {
      final SnackBar snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> downloadFile(Reference ref) async {
    /** Directory? directory;
        try {
        if (await requestPermission(Permission.storage)) {
        directory = await getExternalStorageDirectory();
        String newPath = "";
        List<String>? folders = directory!.path.split("/");
        for (int i = 1; i < folders.length; i++) {
        String folder = folders[i];
        if (folder != "Android") {
        newPath += '/$folder';
        } else {
        break;
        }
        }
        newPath += "/SuperVision";
        directory = Directory(newPath);
        print(directory.path);
        if (! await directory.exists()) {
        await directory.create(recursive: true);
        }
        if (await directory.exists()) {
        String refer = ref.toString();
        String fileName =
        refer.substring(refer.indexOf("/") + 1, refer.length - 1);
        File file = File("${directory.path}/$fileName");
        await dio.download(await ref.getDownloadURL(), file.path,
        onReceiveProgress: (downloaded, totalSize) {
        setState(() {
        progress = downloaded / totalSize;
        });
        });
        }
        } else {
        showSnackBar(context, "Download Permission Denied");
        }
        }  catch (e) {
        print(e.toString());
        showSnackBar(context, e.toString());
        }*/
    try {
      Directory? appDirectory = await getExternalStorageDirectory();
      String refer = ref.toString();
      String fileName =
          refer.substring(refer.indexOf("/") + 1, refer.length - 1);

      File file = File('${appDirectory?.path}/$fileName');
      await dio.download(await ref.getDownloadURL(), file.path,
          onReceiveProgress: (downloaded, totalSize) {
        setState(() {
          progress = downloaded / totalSize;
        });
      }).whenComplete(() {
        showSnackBar(context, "Files saved at ${file.path}");
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message);
    }
  }

  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future uploadFile() async {
    try {
      final path = '/${widget.groupId}/${pickedFile!.name}';
      final file = File(pickedFile!.path!);
      final ref = FirebaseStorage.instance.ref().child(path);
      ref.putFile(file).whenComplete(() {
        setState(() {
          getListOfFiles();
          showSnackBar(context, "File Uploaded Successfully");
        });
      });

      pickedFile = null;
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message);
    }
  }

  Future selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return;
      setState(() {
        pickedFile = result.files.first;
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: FutureBuilder<ListResult>(
                future: futureFiles,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final files = snapshot.data!.items;
                    return ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return Card(
                          color: Colors.grey.shade300,
                          child: ListTile(
                            leading: IconButton(
                              icon: const Icon(
                                Icons.download,
                                color: Colors.green,
                              ),
                              onPressed: () => downloadFile(file),
                            ),
                            title: Text(
                              file.name,
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => deleteFile(file),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error Occurred"),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                      ),
                    );
                  }
                },
              ),
            ),
            if (pickedFile != null)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: Text(
                    pickedFile!.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: kPrimaryColor),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Wrap(
        spacing: 20,
        children: [
          FloatingActionButton(
            onPressed: selectFile,
            backgroundColor: kPrimaryColor,
            child: const Icon(Icons.select_all),
          ),
          FloatingActionButton(
            onPressed: uploadFile,
            backgroundColor: kPrimaryColor,
            child: const Icon(Icons.upload),
          ),
        ],
      ),
    );
  }
}
/**
 * try {
    var url = await ref.getDownloadURL();
    var httpClient = HttpClient();
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    final directory = await getApplicationSupportDirectory();
    File file =  File('${directory.path}/');
    await file.writeAsBytes(bytes);
    showSnackBar(context, 'Downloaded ${ref.name}');
    /*final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${ref.name}');
    await ref.writeToFile(file).then((p0) {
    showSnackBar(context, 'Downloaded ${ref.name}');
    });*/
    } on FirebaseException catch (e) {
    showSnackBar(context, e.message);
    }
 */
