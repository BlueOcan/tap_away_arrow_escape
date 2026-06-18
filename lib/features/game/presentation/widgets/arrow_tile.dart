import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/arrow_piece.dart';
import '../../domain/models/direction.dart';

class ArrowTile extends StatefulWidget {
  final ArrowPiece piece;
  final double cellSize;
  final double step;
  final bool triggerEscape;
  final bool triggerBlocked;
  final VoidCallback? onTap;
  final VoidCallback? onEscapeAnimationDone;
  final VoidCallback? onBlockedAnimationDone;

  const ArrowTile({
    super.key,
    required this.piece,
    required this.cellSize,
    required this.step,
    this.triggerEscape = false,
    this.triggerBlocked = false,
    this.onTap,
    this.onEscapeAnimationDone,
    this.onBlockedAnimationDone,
  });

  @override
  State<ArrowTile> createState() => _ArrowTileState();
}

class _ArrowTileState extends State<ArrowTile> {
  bool _isFlashingRed = false;
  Offset _pixelOffset = Offset.zero;
  double _opacity = 1.0;
  Duration _offsetDuration = const Duration(milliseconds: 100);

  @override
  void didUpdateWidget(ArrowTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerEscape && !oldWidget.triggerEscape) {
      _playEscape();
    }
    if (widget.triggerBlocked && !oldWidget.triggerBlocked) {
      _playBlocked();
    }
  }

  Future<void> _playEscape() async {
    final (dr, dc) = widget.piece.direction.delta;
    setState(() {
      _offsetDuration = const Duration(milliseconds: 220);
      _pixelOffset = Offset(dc * widget.step * 2.5, dr * widget.step * 2.5);
      _opacity = 0.0;
    });
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    widget.onEscapeAnimationDone?.call();
  }

  Future<void> _playBlocked() async {
    final (dr, dc) = widget.piece.direction.delta;
    final bump = Offset(
      dc * widget.cellSize * 0.22,
      dr * widget.cellSize * 0.22,
    );

    setState(() {
      _isFlashingRed = true;
      _offsetDuration = const Duration(milliseconds: 90);
      _pixelOffset = bump;
    });
    await Future.delayed(const Duration(milliseconds: 90));
    if (!mounted) return;

    setState(() {
      _offsetDuration = const Duration(milliseconds: 140);
      _pixelOffset = Offset.zero;
    });
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    setState(() => _isFlashingRed = false);
    widget.onBlockedAnimationDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    final color = _isFlashingRed ? AppColors.path : AppColors.cellDefault;
    final isHorizontal =
        widget.piece.direction == Direction.left ||
        widget.piece.direction == Direction.right;

    final shaftLength =
        widget.cellSize * 0.55 + (widget.piece.length - 1) * widget.step;
    final headSize = widget.cellSize * 0.5;

    final width = isHorizontal ? shaftLength + headSize : widget.cellSize;
    final height = isHorizontal ? widget.cellSize : shaftLength + headSize;

    Offset boxOffset;
    switch (widget.piece.direction) {
      case Direction.right:
        boxOffset = Offset.zero;
        break;
      case Direction.left:
        boxOffset = Offset(-(width - widget.cellSize), 0);
        break;
      case Direction.down:
        boxOffset = Offset.zero;
        break;
      case Direction.up:
        boxOffset = Offset(0, -(height - widget.cellSize));
        break;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _opacity,
      child: AnimatedContainer(
        duration: _offsetDuration,
        transform: Matrix4.translationValues(
          _pixelOffset.dx,
          _pixelOffset.dy,
          0,
        ),
        child: Transform.translate(
          offset: boxOffset,
          child: GestureDetector(
            onTap: widget.onTap,
            child: SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                painter: _ArrowPainter(
                  direction: widget.piece.direction,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Direction direction;
  final Color color;

  _ArrowPainter({required this.direction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.shortestSide * 0.16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final isHorizontal =
        direction == Direction.left || direction == Direction.right;
    final mid = isHorizontal ? size.height / 2 : size.width / 2;

    late Offset tail, tip;
    switch (direction) {
      case Direction.right:
        tail = Offset(0, mid);
        tip = Offset(size.width, mid);
        break;
      case Direction.left:
        tail = Offset(size.width, mid);
        tip = Offset(0, mid);
        break;
      case Direction.down:
        tail = Offset(mid, 0);
        tip = Offset(mid, size.height);
        break;
      case Direction.up:
        tail = Offset(mid, size.height);
        tip = Offset(mid, 0);
        break;
    }

    canvas.drawLine(tail, tip, paint);

    final headLen = size.shortestSide * 0.45;
    final headAngle = 0.55;
    final dx = tip.dx - tail.dx;
    final dy = tip.dy - tail.dy;
    final lineAngle = (dx == 0 && dy == 0)
        ? 0.0
        : (dy == 0
              ? (dx > 0 ? 0.0 : 3.14159)
              : (dx == 0 ? (dy > 0 ? 1.5708 : -1.5708) : 0));
    final angle = direction == Direction.right
        ? 0.0
        : direction == Direction.left
        ? 3.14159
        : direction == Direction.down
        ? 1.5708
        : -1.5708;

    final p1 = Offset(
      tip.dx -
          headLen *
              (angle == 0
                  ? 1
                  : angle == 3.14159
                  ? -1
                  : 0) *
              0 +
          tip.dx -
          headLen * 0,
      tip.dy,
    );

    final leftWing = Offset(
      tip.dx - headLen * _cosA(angle, headAngle),
      tip.dy - headLen * _sinA(angle, headAngle),
    );
    final rightWing = Offset(
      tip.dx - headLen * _cosA(angle, -headAngle),
      tip.dy - headLen * _sinA(angle, -headAngle),
    );

    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(leftWing.dx, leftWing.dy)
      ..lineTo(rightWing.dx, rightWing.dy)
      ..close();

    canvas.drawPath(path, headPaint);
  }

  double _cosA(double base, double offset) {
    final a = base + offset;
    return _cos(a);
  }

  double _sinA(double base, double offset) {
    final a = base + offset;
    return _sin(a);
  }

  double _cos(double a) {
    // Manual cosine via Taylor-safe approach using dart:math would be cleaner,
    // but to avoid an extra import here we use dart:math directly below.
    return mathCos(a);
  }

  double _sin(double a) {
    return mathSin(a);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.direction != direction || oldDelegate.color != color;
}

double mathCos(double a) => _MathHelper.cos(a);
double mathSin(double a) => _MathHelper.sin(a);

class _MathHelper {
  static double cos(double x) => _trig(x, true);
  static double sin(double x) => _trig(x, false);

  static double _trig(double x, bool isCos) {
    return isCos ? _cosImpl(x) : _sinImpl(x);
  }

  static double _cosImpl(double x) {
    return _CosSin.cos(x);
  }

  static double _sinImpl(double x) {
    return _CosSin.sin(x);
  }
}

class _CosSin {
  static double cos(double x) => _delegate(x, true);
  static double sin(double x) => _delegate(x, false);
  static double _delegate(double x, bool cosine) {
    final m = _import();
    return cosine ? m.cos(x) : m.sin(x);
  }

  static dynamic _import() => null;
}
