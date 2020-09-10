import 'package:flutter/material.dart';
import 'package:flutter_vision/zero_result.dart';
import 'package:flutter_vision/view_patent_ia_keywords.dart';
import 'models/patent.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'services/getSuggestions.dart';
import 'models/searchString.dart';
import 'generate.dart';

class FilterPatent extends StatefulWidget {
  List<String> selectedLabels;
  List<String> userKeywords;
  List patents;
  List<List<SearchString>> reports;
  FilterPatent(
      {this.selectedLabels, this.userKeywords, this.patents, this.reports});

  @override
  _FilterPatentState createState() => _FilterPatentState();
}

class _FilterPatentState extends State<FilterPatent> {
  TextEditingController _controller = TextEditingController();
  int i, j;
  int index;
  List newPatent = [];
  bool _isLoading = false;
  List<List<Patent>> patentCount = [[], [], [], []];
  List<List<Patent>> NewPatentCount = [[], [], [], []];
  List<String> suggestion;
  void initState() {
    setState(() {
      suggestion = Suggestion.getKeywords();
    });
    print("Select labels length ${widget.selectedLabels.length}");
//    setState(() {
//      List<String> tempList = widget.userKeywords;
//      widget.userKeywords = tempList.toSet().toList();
//    });
    for (i = 0; i < widget.selectedLabels.length; i++) {
      setState(() {
        patentCount[i].clear();
        print("patent length ${patentCount[i].length}");
      });
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

          ///check if the patent already in the list
          if (!patentAlreadyExist(patent_number, i)) {
            ///if patent is not in the list add the patent
            patentCount[i].add(Patent(patent_number, patent_title));
          }
        }
      }
    }

    for (i = 0; i < widget.reports.length; i++) {
      if (widget.reports[i].length >= 0) {
        index = i;
        break;
      }
    }

    for (i = 0; i < widget.selectedLabels.length; i++) {
      widget.reports[index]
          .add(SearchString(reportString(i), patentCount[i].length));
    }
    print("-----------------------------------------------------------");
    for (i = 0; i <= index; i++) {
      widget.reports[i].forEach((count) {
        print("${count.keyword} ${count.count}");
      });
      print("\n");
    }
    print("-----------------------------------------------------------");
    super.initState();
  }

  String reportString(int x) {
    String searchString = "";
    int z;
    searchString = searchString + widget.selectedLabels[x];
    for (z = 0; z < widget.userKeywords.length; z++) {
      searchString = searchString + "," + widget.userKeywords[z];
    }
    return searchString;
  }

  ///check if the patent is already in patentCount
  bool patentAlreadyExist(String number, int index) {
    bool exist = false;
    patentCount[i].forEach((patent) {
      if (number == patent.patent_number) {
        exist = true;
      }
    });
    return exist;
  }

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
  Widget build(BuildContext context) {
    String currentText;
    int reportLength = getIndex() - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text("Filter Result"),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              if (widget.userKeywords.length >= 1) {
                widget.userKeywords.removeLast();
              }
            });
            Navigator.of(context).pop();
          },
        ),
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
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
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
                                      widget.userKeywords.add(_controller.text);
                                      if (suggestion
                                              .contains(_controller.text) ==
                                          false) {
                                        Suggestion.addKeyword(_controller.text);
                                      }
                                      filterPatent(_controller.text);
                                      _controller.clear();
                                      if (newPatent.length <= 0) {
                                        List<Patent> closestPatent =
                                            getClosestPatent();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) {
                                                  return ZeroResult(
                                                    reports:
                                                        this.widget.reports,
                                                    userKeywords:
                                                        widget.userKeywords,
                                                  );
                                                },
                                                fullscreenDialog: true));
                                      } else {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return FilterPatent(
                                            selectedLabels:
                                                widget.selectedLabels,
                                            userKeywords: widget.userKeywords,
                                            patents: newPatent,
                                            reports: widget.reports,
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
                              height: 700.0,

                              ///display selected keywords and thier counts
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: 500.0,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          height: 300.0,
                                          child: ListView.builder(
                                            itemCount:
                                                widget.selectedLabels.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  GestureDetector(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: Text(
                                                            "${widget.selectedLabels[index]}, ${displayKeywords()}",
                                                            style: TextStyle(
                                                                fontSize: 16.0),
                                                          ),
                                                          flex: 10,
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            patentCount[index]
                                                                .length
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 16.0),
                                                          ),
                                                          flex: 2,
                                                        ),
                                                      ],
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        _isLoading = true;
                                                      });
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return ViewPatentWithKeyword(
                                                                  patents:
                                                                      patentCount[
                                                                          index],
                                                                );
                                                              },
                                                              fullscreenDialog:
                                                                  true));
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
                                        ),
                                        Visibility(
                                          visible: widget.patents.length <= 10
                                              ? true
                                              : false,
                                          child: SizedBox(
                                            height: 38.0,
                                            width: 190.0,
                                            child: RaisedButton(
                                              elevation: 5.0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0)),
                                              color: Colors.deepOrange,
                                              onPressed: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(builder:
                                                        (BuildContext context) {
                                                  return GenerateReport(
                                                    reports: widget.reports,
                                                  );
                                                }));
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  List<Patent> getClosestPatent() {
    List<Patent> newPatent = [];
    widget.patents.forEach((patent) {
      String patent_number = patent["patent_number"];
      String patent_title = patent['patent_title'];
      newPatent.add(Patent(patent_number, patent_title));
    });
    return newPatent;
  }

  void removePatent(String keyword) {
    widget.patents.forEach((patent) {
      if (patent["patent_title"]
              .toLowerCase()
              .contains(keyword.toLowerCase()) ||
          patent["patent_abstract"]
              .toLowerCase()
              .contains(keyword.toLowerCase())) {
        newPatent.remove(patent);
      }
    });
  }

  String displayKeywords() {
    String keywords = "";
    int i = 0;
    widget.userKeywords.forEach((words) {
      i++;
      keywords += words + ", ";
    });
    return keywords.substring(0, keywords.length - 2);
  }
}
