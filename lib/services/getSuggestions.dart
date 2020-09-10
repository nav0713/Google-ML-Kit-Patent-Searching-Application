import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Suggestion {
  static List<String> getKeywords() {
    CollectionReference collectionReference =
        Firestore.instance.collection("suggestions");
    StreamSubscription<QuerySnapshot> subscription;

    List<String> keywords = [];

    subscription = collectionReference.snapshots().listen((data) {
      List<DocumentSnapshot> snapshot = data.documents;
      snapshot.forEach((word) {
        keywords.add(word["word"]);
      });
      print("keyword length ${keywords.length}");
    });

    return keywords;
  }

  static void addKeyword(String keyword) async {
    CollectionReference collectionReference =
        Firestore.instance.collection("suggestions");
    DocumentReference documentReference =
        await collectionReference.add({"word": keyword});
  }
}
