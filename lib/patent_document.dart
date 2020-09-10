import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:flutter/material.dart';

class PatentImage extends StatefulWidget {
  final PDFDocument document;
  final String title;
  PatentImage({this.document, this.title});

  @override
  _PatentImageState createState() => _PatentImageState();
}

class _PatentImageState extends State<PatentImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: SafeArea(
          child: PDFViewer(
            document: widget.document,
          ),
        ));
  }
}
