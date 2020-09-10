import 'package:flutter/material.dart';
import 'package:flutter_vision/patent_document.dart';
import 'package:flutter_vision/services/get_document_url.dart';
import 'models/patent.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'services/get_document_url.dart';

class ViewPatentWithKeyword extends StatefulWidget {
  final List<Patent> patents;

  ViewPatentWithKeyword({this.patents});

  @override
  _ViewPatentWithKeywordState createState() => _ViewPatentWithKeywordState();
}

class _ViewPatentWithKeywordState extends State<ViewPatentWithKeyword> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Patents List"),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: widget.patents.length == 0
              ? Center(
                  child: Container(
                    child: Opacity(
                      opacity: .3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 134.0,
                          ),
                          Icon(
                            Icons.error_outline,
                            size: 200.0,
                          ),
                          Text(
                            "No Result Found",
                            style: TextStyle(fontSize: 32.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: widget.patents.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text("${index + 1}"),
                      title: Text("${widget.patents[index].patent_title}"),
                      subtitle: Text(
                          "Patent number: ${widget.patents[index].patent_number}"),
                      onTap: () async {
                        String patent_number =
                            widget.patents[index].patent_number;
                        String url = PatentDocument.getPatentUrl(patent_number);
                        print(url);
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          PDFDocument document = await PDFDocument.fromURL(url);
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return PatentImage(
                              document: document,
                              title:
                                  widget.patents[index].patent_title.toString(),
                            );
                          }));
                        } catch (e) {
                          print(e.toString());
                        }

                        setState(() {
                          isLoading = false;
                        });
                      },
                    );
                  },
                )),
    );
  }
}
