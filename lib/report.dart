import 'package:flutter/material.dart';
import 'package:flutter_vision/zero_result.dart';
import 'package:flutter_vision/filter_patent.dart';
import 'package:flutter_vision/view_patent_ia_keywords.dart';
import 'models/patent.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'services/getSuggestions.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter_vision/models/searchString.dart';

class Report extends StatefulWidget {
  List patents;
  List<String> selectedLabels;

  Report({this.patents, this.selectedLabels});

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  TextEditingController _controller = TextEditingController();
  List newPatent = [];
  List<List<Patent>> patentCount = [[], [], [], []];
  List<String> userKeyWord = [];
  int i, j;
  bool _isLoading = false;
  List<String> suggestion;
  String currentText;
  List<List<SearchString>> reports = [[], [], [], []];
  @override
  void initState() {
    setState(() {
      reports.forEach((report) {
        report.length = 0;
      });
    });
    setState(() {
      suggestion = Suggestion.getKeywords();
      userKeyWord.clear();
    });
    for (i = 0; i < widget.selectedLabels.length; i++) {
      for (j = 0; j < widget.patents.length; j++) {
        if (widget.patents[j]['patent_title']
                .toString()
                .toLowerCase()
                .contains(widget.selectedLabels[i].toLowerCase()) ||
            widget.patents[j]['patent_abstract']
                .toString()
                .toLowerCase()
                .contains(widget.selectedLabels[i].toLowerCase())) {
          String patent_number = widget.patents[j]['patent_number'];
          String patent_title = widget.patents[j]['patent_title'];
          patentCount[i].add(Patent(patent_number, patent_title));
        }
      }
    }

    print("selected labels ${widget.selectedLabels.length}");

    for (i = 0; i < widget.selectedLabels.length; i++) {
      reports[0]
          .add(SearchString(widget.selectedLabels[i], patentCount[i].length));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filter Result"),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: SimpleAutoCompleteTextField(
                                suggestions: suggestion,
                                suggestionsAmount: 10,
                                textCapitalization: TextCapitalization.words,
                                controller: _controller,
                                textChanged: (text) => currentText = text,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 40.0),
                                  labelText: "Enter your keyword",
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),

                                  ///Filter Patent Button
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.search),
                                    onPressed: () {
                                      if (userKeyWord.length > 0) {
                                        userKeyWord.removeLast();
                                      }
                                      userKeyWord.add(_controller.text);
                                      if (suggestion
                                              .contains(_controller.text) ==
                                          false) {
                                        Suggestion.addKeyword(_controller.text);
                                      }
                                      filterPatent(_controller.text);
                                      _controller.clear();
                                      if (newPatent.length <= 0) {
                                        setState(() {
                                          newPatent = getClosestPatent();
                                        });
                                        Navigator.push(context,
                                            MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return ZeroResult(
                                            reports: reports,
                                            userKeywords: userKeyWord,
                                          );
                                        }));
                                      } else {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return FilterPatent(
                                            selectedLabels:
                                                widget.selectedLabels,
                                            userKeywords: userKeyWord,
                                            patents: newPatent,
                                            reports: reports,
                                          );
                                        }));
                                      }
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "KEYWORDS",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "PATENT COUNT",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            Divider(),
                            Container(
                              height: MediaQuery.of(context).size.height,
                              child: ListView.builder(
                                itemCount: widget.selectedLabels.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      GestureDetector(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(widget.selectedLabels[index]),
                                            Text(patentCount[index]
                                                .length
                                                .toString()),
                                          ],
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          Navigator.push(context,
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return ViewPatentWithKeyword(
                                              patents: patentCount[index],
                                            );
                                          }));
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        },
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Divider(),
                                    ],
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Patent> getClosestPatent() {
    List<Patent> newPatent = [];
    widget.patents.forEach((patent) {
      String patent_number = patent["patent_number"];
      String patent_title = patent['patent_title'];
      newPatent.add(Patent(patent_number, patent_title));
    });
    return newPatent;
  }

  void filterPatent(String keyword) {
    widget.patents.forEach((patent) {
      if (patent["patent_title"]
              .toLowerCase()
              .contains(keyword.toLowerCase()) ||
          patent["patent_abstract"]
              .toLowerCase()
              .contains(keyword.toLowerCase())) {
        newPatent.add(patent);
      }
    });
  }
}

//ListView.builder(
//itemCount: widget.patents.length,
//itemBuilder: (context, index) {
//return ListTile(
//title: Text("${widget.patents[index]['patent_title']}"),
//subtitle: Text("${widget.patents[index]['patent_number']}"),
//);
//})
