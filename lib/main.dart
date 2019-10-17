import 'package:flutter/material.dart';
import 'package:overseeing_eye/tiltable_stack.dart';
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
  GlobalKey<TiltableStackState> tiltKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('A watching eye'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  painter: EyePainter(),
                  child: Container(
                    height: 200,
                    width: 400,
                  ),
                ),
                ClipPath(
                  clipper: EyeClipper(),
                  child: Transform.translate(
                    offset: Offset(20, 0),
                    child: TiltableStack(
                      key: tiltKey,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 200,
                          width: 400,
                        ),
                        SizedOverflowBox(
                          child: Container(
                            height: 310,
                            width: 310,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(),
                                color: Colors.white),
                          ),
                          size: Size(200, 200),
                        ),
                        Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey,
                          ),
                        ),
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.black),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 20,
                                top: 20,
                                child: Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TrackingTextInput(
                label: "Let's see what you have to say",
                hint: "Type something",
                onCaretMoved: (Offset caret) {
                  if (caret == null) {
                    tiltKey.currentState?.cancelPan();
                  } else {
                    tiltKey.currentState?.updatePan(caret);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Path createEyePath(Size size) {
  Path path = Path();
  path.moveTo(size.width * 0.05, size.height * 0.5);
  path.cubicTo(size.width * 0.30, -size.height * 0.1, size.width * 0.7,
      -size.height * 0.1, size.width * 0.95, size.height * 0.5);
  path.cubicTo(size.width * 0.7, size.height * 1.1, size.width * 0.30,
      size.height * 1.1, size.width * 0.05, size.height * 0.5);
  return path;
}

class EyePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = createEyePath(size);

    Paint paint = Paint()
      ..color = Colors.redAccent.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    paint
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

class EyeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => createEyePath(size);

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => oldClipper != this;
}
