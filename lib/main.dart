import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  ValueNotifier<Offset> caretPosition = ValueNotifier(null);
  StreamController<Offset> caret = StreamController.broadcast();

  @override
  void dispose() {
    super.dispose();
    caret.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('A watching eye'),
        leading: LayoutBuilder(
          builder: (_, constraints) => Eye(
            size: constraints.biggest,
            lookAt: caret.stream,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView(
          shrinkWrap: true,
          children: [
            Eye(
              size: Size(400, 200),
              lookAt: caret.stream,
            ),
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
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 90),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Eye(size: Size(40, 40), lookAt: caret.stream),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TrackingTextInput(
                          label: "Let's see what you have to say",
                          hint: "Type something",
                          onCaretMoved: caret.add),
                    ),
                  ),
                  Eye(size: Size(40, 40), lookAt: caret.stream),
                ],
              ),
            ),
            Eye(
              size: Size(400, 200),
              lookAt: caret.stream,
            ),
          ],
        ),
      ),
    );
  }
}
