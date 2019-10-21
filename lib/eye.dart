import 'package:flutter/material.dart';

import 'tiltable_stack.dart';

class Eye extends StatelessWidget {
  const Eye({
    Key key,
    @required this.size,
    @required this.lookAt,
    this.mirror = false,
  }) : super(key: key);

  final Size size;
  final Stream<Offset> lookAt;
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    // The eye is designed for a ratio of width/height = 2
    double height = size.height;
    double width = size.width;
    if (height.isInfinite) {
      height = width / 2;
    } else if (width.isInfinite) {
      width = height * 2;
    } else if (!(width / height).toString().startsWith("2")) {
      height = height.clamp(0, width / 2);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // This container is for fixing a weird Flutter web bug
        Container(
          width: width,
          height: height,
          color: Colors.transparent,
        ),
        // Draw the outlines and red background first
        CustomPaint(
          painter: EyePainter(),
          child: Container(
            height: height,
            width: width,
          ),
        ),
        // Contain the "eye ball" in a ClipPath, to make the eye seem "inside"
        ClipPath(
          clipper: EyeClipper(),
          // Shift the "eye ball" a little bit to the side for authenticity
          child: Transform.translate(
            offset: Offset(mirror ? -width * 0.05 : width * 0.05, 0),
            // Here begins the moving "eye ball"
            child: StreamBuilder(
              stream: lookAt,
              builder: (context, snap) => TiltableStack(
                size: size,
                tiltTowards: snap.hasData ? snap.data : null,
                alignment: Alignment.center,
                children: [
                  Container(
                    height: height,
                    width: width,
                  ),
                  SizedOverflowBox(
                    child: Container(
                      height: width * 0.84,
                      width: width * 0.84,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(),
                          color: Colors.white),
                    ),
                    size: Size(height, height),
                  ),
                  Container(
                    height: height * 0.65,
                    width: height * 0.65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueGrey,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: height * 0.35,
                          width: height * 0.35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                        ),
                        Positioned(
                          right: height * 0.25,
                          top: height * 0.25,
                          child: Container(
                            height: height * 0.05,
                            width: height * 0.05,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// The outer line is used by both EyePainter and EyeClipper, so it is extracted
Path createEyePath(Size size) {
  Path path = Path();
  path.moveTo(size.width * 0.05, size.height * 0.5);
  path.cubicTo(size.width * 0.30, -size.height * 0.1, size.width * 0.7,
      -size.height * 0.1, size.width * 0.95, size.height * 0.5);
  path.cubicTo(size.width * 0.7, size.height * 1.1, size.width * 0.30,
      size.height * 1.1, size.width * 0.05, size.height * 0.5);
  return path;
}

// This painter draws the black outline and red background of the eye
class EyePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = createEyePath(size);

    // First draw the red background
    Paint paint = Paint()
      ..color = Colors.redAccent.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    // Draw the black outline of the eye
    paint
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

// The EyeClipper removes rendered things outside its path, like the eyeball
class EyeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => createEyePath(size);

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => oldClipper != this;
}
