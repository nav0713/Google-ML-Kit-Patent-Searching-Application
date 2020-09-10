import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_vision/displayImage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dialog.dart';

class ImageLabeling extends StatefulWidget {
  @override
  _ImageLabelingState createState() => _ImageLabelingState();
}

class _ImageLabelingState extends State<ImageLabeling> {
  File _image;
  //var detector = FirebaseVision.instance.imageLabeler();
  final ImageLabeler detector = FirebaseVision.instance.cloudImageLabeler();
  bool _isLoading = false;
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  Future<File> _pickImageFunction() async {
    File image;
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Select the image source"),
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    "Camera",
                    style: TextStyle(
                        color: Colors.deepOrange, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text("Gallery",
                      style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(
                    context,
                    ImageSource.gallery,
                  ),
                )
              ],
            ));

    if (imageSource != null) {
      final file = await ImagePicker.pickImage(
        source: imageSource,
        maxWidth: 1280.0,
        maxHeight: 720.0,
        imageQuality: 70,
      );
      if (file != null) {
        setState(() => image = file);
      }
    }
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Stack(
          children: <Widget>[
            Opacity(
              opacity: 1,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/image/patent_bg.jpg"),
                        fit: BoxFit.cover)),
              ),
            ),
            Container(
                alignment: Alignment.center,
                child: FloatingActionButton.extended(
                  elevation: 10.0,
                  backgroundColor: Colors.deepOrange,
                  onPressed: () async {
                    Dialogs.showLoadingDialog(context, _keyLoader);
                    _image = await _pickImageFunction();
                    if (_image != null) {
                      FirebaseVisionImage image =
                          FirebaseVisionImage.fromFile(_image);
                      final List<ImageLabel> currentLabels =
                          await detector.processImage(image);
                      Navigator.of(_keyLoader.currentContext,
                              rootNavigator: true)
                          .pop();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return (ImageDisplay(
                          image: _image,
                          detectedLabels: currentLabels,
                        ));
                      }));
                    } else {
                      Navigator.of(_keyLoader.currentContext,
                              rootNavigator: true)
                          .pop();
                      print("file not exist");
                    }
                  },
                  label: Text(
                    "Select Image",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  icon: Icon(Icons.image),
                ))
          ],
        ),
      ),
    );
  }
}
