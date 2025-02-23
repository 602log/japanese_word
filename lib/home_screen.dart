import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFlipped = false;
  List<Word> words = [];
  Word? currentWord;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    loadWords();
  }

  Future<void> loadWords() async {
    final String response = await rootBundle.loadString('assets/words.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      words = data.map((json) => Word.fromJson(json)).toList();
      showRandomWord();
    });
  }

  void showRandomWord() {
    if (words.isEmpty) return;
    final random = Random();
    setState(() {
      currentWord = words[random.nextInt(words.length)];
      isFlipped = false;
      _controller.reset();
    });
  }


  void flipCard() {
    if (_controller.isAnimating) return;
    if (isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('日本語のい形容詞'),),
      body: Center(
        child: words.isEmpty
            ? CircularProgressIndicator()
            : GestureDetector(
          onTap: flipCard,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              double angle = _animation.value * pi;
              bool isBack = angle > pi / 2;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002) // 3D 효과
                  ..rotateY(angle),
                child: Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  alignment: Alignment.center,
                  child: isBack
                      ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: Text(
                      "${currentWord?.hiragana ?? "???"}\n(${currentWord?.meaning ?? "의미 없음"})",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : Text(
                    currentWord?.kanji ?? "로딩 중...",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showRandomWord,
        child: Icon(Icons.shuffle),
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }
}

class Word {
  final String kanji;
  final String hiragana;
  final String meaning;

  Word({required this.kanji, required this.hiragana, required this.meaning});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      kanji: json['kanji'],
      hiragana: json['hiragana'],
      meaning: json['meaning'],
    );
  }
}