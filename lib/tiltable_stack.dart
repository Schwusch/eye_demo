import 'package:flutter/material.dart';

class TiltableStack extends StatefulWidget {
  final List<Widget> children;
  final Alignment alignment;
  final Offset tiltTowards;
  final Size size;

  const TiltableStack({
    Key key,
    this.children,
    this.alignment = Alignment.center,
    this.tiltTowards,
    this.size,
  }) : super(key: key);

  @override
  TiltableStackState createState() => TiltableStackState();
}

class TiltableStackState extends State<TiltableStack>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> pitchAnimation;
  Animation<double> yawAnimation;

  double get maxPitch => 50;

  double get maxYaw => 250;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    yawAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticIn.flipped,
      ),
    );
    pitchAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticIn.flipped,
      ),
    );
    updatePan(widget.tiltTowards);
  }

  @override
  void didUpdateWidget(TiltableStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    updatePan(widget.tiltTowards);
  }

  @override
  dispose() {
    super.dispose();
    _controller.dispose();
  }

  cancelPan() {
    yawAnimation = nextAnimation(yawAnimation, 0.0);
    pitchAnimation = nextAnimation(pitchAnimation, 0.0);
    _controller.forward(from: 0);
  }

  Animation<double> nextAnimation(Animation<double> animation, double end) =>
      Tween<double>(
        begin: animation.value,
        end: end,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticIn.flipped,
        ),
      );

  updatePan(Offset offset) {
    // null means go back to default
    if (offset == null) {
      cancelPan();
      return;
    }

    final RenderBox box = context.findRenderObject();

    if (box == null) return; // Nothing can be done here, eject.

    final position = box.localToGlobal(Offset.zero);
    final center = Offset(position.dx + widget.size.width / 2,
        position.dy + widget.size.height / 2);

    double pitch = offset.dy - center.dy;

    // It looks nicer when the eye distinctly look up or down
    if (pitch > 0) {
      pitch = 50;
    } else {
      pitch = -50;
    }

    pitchAnimation = nextAnimation(pitchAnimation, pitch);
    yawAnimation = nextAnimation(yawAnimation, center.dx - offset.dx);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          var yaw = yawAnimation.value.clamp(-maxYaw, maxYaw);
          var pitch = pitchAnimation.value;

          return Stack(
            alignment: widget.alignment,
            children: widget.children
                .asMap()
                .map(
                  (i, element) {
                    return MapEntry(
                      i,
                      Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(yaw * 0.002)
                          ..rotateY(pitch * 0.002)
                          // Scale the translation to the size of the widget
                          // Otherwise small widgets translate a lot, and
                          // large widgets barely see any difference
                          ..translate(widget.size.width * -yaw * i * 0.0004,
                              widget.size.height * pitch * i * 0.001, 0),
                        child: element,
                        alignment: FractionalOffset.center,
                      ),
                    );
                  },
                )
                .values
                .toList(),
          );
        },
      );
}
