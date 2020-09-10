import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_vision/report.dart';
import 'package:toast/toast.dart';
import 'models/myLabels.dart';
import 'services/retrieve_patent.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ImageDisplay extends StatefulWidget {
  File image;
  List<ImageLabel> detectedLabels;

  ImageDisplay({this.image, this.detectedLabels});

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  List<MyLabels> tempList = [];
  List<String> selectedLabels = [];
  bool isLoading = false;
  @override
  void initState() {
    widget.detectedLabels.forEach((label) {
      setState(() {
        tempList.add(MyLabels(
            name: label.text,
            confidence: (label.confidence * 100).toStringAsFixed(1) + "%"));
      });
    });
    tempList.forEach((lable) {
      print(lable.name);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 5.0,
          title: Text("Recognized Object"),
          centerTitle: true,
        ),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
              child: Container(
                child: Column(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 10 / 10,
                      child: Card(
                        child: Image.file(
                          widget.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Material(
                      child: Container(
                        height: 40.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: selectedLabels.length > 0
                                ? Colors.green
                                : Colors.red),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "${selectedLabels.length} Items Selected",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  color: selectedLabels.length <= 0
                                      ? Colors.black87
                                      : Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 250.0,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: [
                            DataColumn(
                              label: Text(
                                "Labels",
                                style: TextStyle(fontSize: 16.0),
                              ),
                              numeric: false,
                              tooltip: "Detected Labels",
                            ),
                            DataColumn(
                              label: Text(
                                "Confidence",
                                style: TextStyle(fontSize: 16.0),
                              ),
                              numeric: false,
                              tooltip: "Confidence Level",
                            )
                          ],
                          rows: tempList.map((label) {
                            return DataRow(
                                selected: selectedLabels.contains(label.name),
                                onSelectChanged: (b) {
                                  onSelect(b, label);
                                },
                                cells: [
                                  DataCell(Text(label.name)),
                                  DataCell(Text(label.confidence)),
                                ]);
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    SizedBox(
                      height: 42.0,
                      width: double.infinity,
                      child: RaisedButton(
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          "SEARCH PATENT",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.deepOrange,
                        onPressed: () async {
                          if (selectedLabels.length == 0) {
                            Toast.show("Please Select label", context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.CENTER);
                          } else if (selectedLabels.length > 4) {
                            Toast.show("Maximum label selection is 4", context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.CENTER);
                          } else if (selectedLabels.length > 0 &&
                              selectedLabels.length <= 4) {
                            setState(() {
                              isLoading = true;
                            });
                            print("hi");
                            RetrievePatent retrivePatent =
                                RetrievePatent(selectedLabels: selectedLabels);
                            List patents = await retrivePatent.getPatent();
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return Report(
                                patents: patents,
                                selectedLabels: selectedLabels,
                              );
                            }));
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  onSelect(bool selected, MyLabels label) async {
    setState(() {
      if (selected) {
        selectedLabels.add(label.name);
      } else {
        selectedLabels.remove(label.name);
      }
    });
  }
}
