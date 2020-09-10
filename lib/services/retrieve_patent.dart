import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RetrievePatent {
  List<String> selectedLabels;
  static List<String> keywords = List(5);
  RetrievePatent({
    this.selectedLabels,
  });

  Future<List<dynamic>> getPatent() async {
    assignKeywordValue();
    print(
        "keyword 0 = ${keywords[0]}, keyword 1 = ${keywords[1]} keywords2 = ${keywords[2]}, keywords3 = ${keywords[3]}");
    List patents = [];
    Map data;
    int i;
    for (i = 1; i <= 5; i++) {
      print("Current index retrieving patent $i");
      data = await getData(i);
      if (data["count"] > 1) {
        patents.addAll(data['patents']);
      } else {
        print("errorrrrr");
        break;
      }
      print("total patent count ${patents.length}");
    }
    return patents;
  }

  void assignKeywordValue() {
    int i;
    for (i = 0; i < 4; i++) {
      if (i < selectedLabels.length) {
        keywords[i] = selectedLabels[i];
      } else {
        keywords[i] = "----";
      }
    }
  }

//
//  Future<Map> getData(int i) async {
//  String url1 =
//      'http://www.patentsview.org/api/patents/query?q={"_and":[{"_or": [{"_text_phrase":{"patent_title": $keywords[0]}},{"_text_phrase": {"patent_title":$keywords[1]}},{"_text_phrase": {"patent_title":$keywords[2]}},{"_text_phrase": {"patent_title":$keywords[3]}}]},';
//  String url2 =
//      '{"_or":[{"_text_phrase":{"patent_abstract":$keywords[0]}},{"_text_phrase":{"patent_abstract":$keywords[1]}},{"_text_phrase":{"patent_abstract":$keywords[2]}},{"_text_phrase":{"patent_abstract":$keywords[3]}}]}]}';
//  String url3 = '&f=["patent_title"]';
////    String url4 = '&o={"page":$i,"per_page":10000}';
//  String urlAPI = url1 + url2 + url3;
//    try {
//      http.Response response = await http.get(urlAPI);
//      return json.decode(response.body);
//    } catch (e) {
//      print(e);
//    }
//  }
//}

  Future<Map> getData(int i) async {
    String url1 =
        'https://www.patentsview.org/api/patents/query?q={"_and":[{"_and": [{"_text_phrase":{"patent_title": "${keywords[0]}"}},{"_text_phrase": {"patent_title":"${keywords[1]}"}},{"_text_phrase": {"patent_title":"${keywords[2]}"}},{"_text_phrase": {"patent_title":"${keywords[3]}"}}]},';
    String url2 =
        '{"_or":[{"_text_phrase":{"patent_abstract":"${keywords[0]}"}},{"_text_phrase":{"patent_abstract":"${keywords[1]}"}},{"_text_phrase":{"patent_abstract":"${keywords[2]}"}},{"_text_phrase":{"patent_abstract":"${keywords[3]}"}}]}]}';
    String url3 = '&f=["patent_title","patent_number","patent_abstract"]';
    String url4 = '&o={"page":$i,"per_page":10000}';
    String urlAPI = url1 + url2 + url3 + url4;

    //String urlAPI =
//        'https://www.patentsview.org/api/patents/query?q={"_text_phrase":{"patent_title":"bicycle"}}&o={"page":$i,"per_page":10000}';
    //    'https://www.patentsview.org/api/patents/query?q={"_text_phrase":{"patent_title":"bicycle"}}';

    http.Response response = await http.get(urlAPI);
    return json.decode(response.body);
  }
}
