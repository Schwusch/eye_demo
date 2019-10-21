import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overseeing_eye/eye.dart';
import 'package:overseeing_eye/tracking_text_input.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamController<Offset> caret = StreamController.broadcast();

  @override
  void dispose() {
    super.dispose();
    caret.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView(
          children: [
            Row(
              children: [
                Eye(
                  size: Size(200, 200),
                  lookAt: caret.stream,
                  mirror: true,
                ),
                Eye(
                  size: Size(200, 200),
                  lookAt: caret.stream,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TrackingTextInput(
                  label: "Nothing you type goes unseen",
                  hint: "Type something",
                  onCaretMoved: caret.add),
            ),
          ],
        ),
      ),
    );
  }
}
