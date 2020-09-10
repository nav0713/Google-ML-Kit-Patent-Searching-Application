import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/main.dart';
import 'models/searchString.dart';

class GenerateReport extends StatefulWidget {
  List<List<SearchString>> reports;
  GenerateReport({this.reports});
  static const menuItems = <String>["Search again", "Exit"];

  @override
  _GenerateReportState createState() => _GenerateReportState();
}

class _GenerateReportState extends State<GenerateReport> {
  int getIndex() {
    int x, i;
    for (i = 0; i < widget.reports.length; i++) {
      if (widget.reports[i].length <= 0) {
        x = i;
        break;
      }
    }
    return x;
  }

  @override
  void initState() {
    widget.reports.forEach((report) {
      int i, j;
      for (i = 0; i < report.length; i++) {
        for (j = i + 1; j < report.length; j++) {
          if (report[i].keyword.toString() == report[j].keyword.toString()) {
            setState(() {
              report.removeAt(j);
            });
          }
        }
      }
      print("\n");
    });
    // TODO: implement initState
  }

  final List<PopupMenuItem<String>> _popUpMenuItems = GenerateReport.menuItems
      .map((String value) => PopupMenuItem<String>(
            value: value,
            child: Text(value),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    print(getIndex());
    print(widget.reports.length);
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Report"),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String newValue) {
              print("$newValue");
              if (newValue == GenerateReport.menuItems[0]) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Search new patent?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Yes"),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return HomeScreen();
                              }));
                            },
                          ),
                          FlatButton(
                            child: Text("No"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    });
              }
              if (newValue == GenerateReport.menuItems[1]) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Exit Application?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Yes"),
                            onPressed: () {
                              return exit(0);
                            },
                          ),
                          FlatButton(
                            child: Text("No"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    });
              }
            },
            itemBuilder: (BuildContext context) => _popUpMenuItems,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Search String",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("Patent Hits",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                    itemCount: getIndex(),
                    itemBuilder: (context, i) {
                      return buildReport(i);
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildReport(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        child: Table(
          border: TableBorder.all(width: 1.0, color: Colors.black),
          children: searchStrings(index),
        ),
      ),
    );
  }

  List<TableRow> searchStrings(int index) {
    List<TableRow> tableRow = [];
    widget.reports[index].forEach((patent) {
      tableRow.add(TableRow(children: [
        TableCell(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(patent.keyword),
                Text(patent.count.toString())
              ],
            ),
          ),
        )
      ]));
    });
    return tableRow;
  }
}
