import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Word {
  final String kanji;
  final String hiragana;
  final String meaning;

  Word({
    required this.kanji,
    required this.hiragana,
    required this.meaning,
});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(kanji: json['kanji'], hiragana: json['hiragana'], meaning: json['meaning']);
  }
}

Future<List<Word>> loadWords() async {
  //json file load
  String jsonString = await rootBundle.loadString('assets/words.json');
  // list로 변환
  List<dynamic> jsonList = json.decode(jsonString);

  return jsonList.map((json) => Word.fromJson(json)).toList();
}