import 'package:flutter/material.dart';
import 'package:flutter_vision/generate.dart';
import 'models/searchString.dart';

class ZeroResult extends StatelessWidget {
  List<List<SearchString>> reports;
  List<String> userKeywords;
  ZeroResult({this.reports, this.userKeywords});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            if (userKeywords.length >= 1) {
              userKeywords.removeLast();
            }
            Navigator.of(context).pop();
          },
        ),
        title: Text("Closest Patent(s)"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Opacity(
                opacity: .5,
                child: Icon(
                  Icons.info_outline,
                  size: 98,
                ),
              ),
              Text("No More Result Found"),
              SizedBox(
                height: 25.0,
              ),
              SizedBox(
                height: 38.0,
                width: 190.0,
                child: RaisedButton(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  color: Colors.deepOrange,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return GenerateReport(
                        reports: reports,
                      );
                    }));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.description,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        "Generate Report",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
