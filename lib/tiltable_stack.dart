import 'package:flutter/material.dart';

class TiltableStack extends StatefulWidget {
  final List<Widget> children;
  final Alignment alignment;

  const TiltableStack({
    Key key,
    this.children,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  TiltableStackState createState() => TiltableStackState();
}

class TiltableStackState extends State<TiltableStack>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> pitchAnimation;
  Animation<double> yawAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..forward(from: 1.0);
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
    final RenderBox box = context.findRenderObject();
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    final center =
        Offset(position.dx + size.width / 2, position.dy + size.height / 2);

    pitchAnimation = nextAnimation(pitchAnimation, offset.dy - center.dy);
    yawAnimation = nextAnimation(yawAnimation, center.dx - offset.dx);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (_, __) {
        var yaw = yawAnimation?.value ?? 0.0;
        var pitch = pitchAnimation?.value ?? 0.0;

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
                        ..rotateX(pitch * 0.0015)
                        ..rotateY(yaw * 0.0015)
                        ..translate(-yaw * i * 0.06, pitch * i * 0.06, 0),
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
      animation: _controller,
    );
  }
}
