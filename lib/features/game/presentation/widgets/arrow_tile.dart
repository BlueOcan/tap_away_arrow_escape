import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/arrow_piece.dart';
import '../../domain/models/direction.dart';

class ArrowTile extends StatefulWidget {
  final ArrowPiece piece;
  final double cellSize;
  final double step;
  final double boardOffsetX;
  final double boardOffsetY;
  final Color arrowColor; // ← injected by BoardWidget
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
    required this.boardOffsetX,
    required this.boardOffsetY,
    required this.arrowColor,
    this.triggerEscape = false,
    this.triggerBlocked = false,
    this.onTap,
    this.onEscapeAnimationDone,
    this.onBlockedAnimationDone,
  });

  @override
  State<ArrowTile> createState() => _ArrowTileState();
}

class _ArrowTileState extends State<ArrowTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _snakeProgress = 0.0;
  bool _isFlashingRed = false;
  Offset _blockedOffset = Offset.zero;
  Duration _blockedDuration = const Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _controller.addListener(() {
      setState(() => _snakeProgress = _controller.value);
    });
  }

  @override
  void didUpdateWidget(ArrowTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerEscape && !oldWidget.triggerEscape) _playEscape();
    if (widget.triggerBlocked && !oldWidget.triggerBlocked) _playBlocked();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playEscape() async {
    _snakeProgress = 0.0;
    _controller.reset();
    await _controller.animateTo(
      1.0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInCubic,
    );
    if (!mounted) return;
    widget.onEscapeAnimationDone?.call();
  }

  Future<void> _playBlocked() async {
    final escapeDir = widget.piece.moveDirection;
    final (dr, dc) = escapeDir.delta;
    final bump = Offset(
      dc * widget.cellSize * 0.18,
      dr * widget.cellSize * 0.18,
    );
    if (!mounted) return;
    setState(() {
      _isFlashingRed = true;
      _blockedDuration = const Duration(milliseconds: 90);
      _blockedOffset = bump;
    });
    await Future.delayed(const Duration(milliseconds: 90));
    if (!mounted) return;
    setState(() {
      _blockedDuration = const Duration(milliseconds: 140);
      _blockedOffset = Offset.zero;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _isFlashingRed = false);
    widget.onBlockedAnimationDone?.call();
  }

  List<_Segment> _buildSegments() {
    final cs = widget.cellSize;
    final s = widget.step;
    final piece = widget.piece;
    final tailCenter = Offset(cs / 2, cs / 2);

    final segs = <_Segment>[];
    var cursor = tailCenter;
    for (final d in piece.segments) {
      final (dr, dc) = d.delta;
      final next = Offset(cursor.dx + dc * s, cursor.dy + dr * s);
      segs.add(_Segment(start: cursor, end: next, direction: d));
      cursor = next;
    }
    if (segs.isEmpty) {
      segs.add(
        _Segment(
          start: tailCenter,
          end: tailCenter,
          direction: piece.direction,
        ),
      );
    }
    return segs;
  }

  @override
  Widget build(BuildContext context) {
    // Use flashing red on block; otherwise use the injected arrowColor
    final color = _isFlashingRed ? AppColors.path : widget.arrowColor;
    final cs = widget.cellSize;
    final segments = _buildSegments();

    double minX = 0, minY = 0, maxX = cs, maxY = cs;
    for (final seg in segments) {
      for (final p in [seg.start, seg.end]) {
        if (p.dx < minX) minX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy > maxY) maxY = p.dy;
      }
    }

    final canvasW = maxX - minX;
    final canvasH = maxY - minY;
    final drawOffset = Offset(-minX, -minY);

    final totalOffsetX =
        widget.boardOffsetX + (widget.piece.position.col * widget.step) + minX;
    final totalOffsetY =
        widget.boardOffsetY + (widget.piece.position.row * widget.step) + minY;

    return Positioned(
      left: totalOffsetX,
      top: totalOffsetY,
      width: canvasW,
      height: canvasH,
      child: AnimatedContainer(
        duration: _blockedDuration,
        transform: Matrix4.translationValues(
          _blockedOffset.dx,
          _blockedOffset.dy,
          0,
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: canvasW,
            height: canvasH,
            child: CustomPaint(
              painter: _SnakeArrowPainter(
                segments: segments,
                color: color,
                progress: _snakeProgress,
                cellSize: cs,
                step: widget.step,
                drawOffset: drawOffset,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Segment {
  final Offset start;
  final Offset end;
  final Direction direction;
  const _Segment({
    required this.start,
    required this.end,
    required this.direction,
  });
}

class _SnakeArrowPainter extends CustomPainter {
  final List<_Segment> segments;
  final Color color;
  final double progress;
  final double cellSize;
  final double step;
  final Offset drawOffset;

  const _SnakeArrowPainter({
    required this.segments,
    required this.color,
    required this.progress,
    required this.cellSize,
    required this.step,
    required this.drawOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    canvas.save();
    canvas.translate(drawOffset.dx, drawOffset.dy);

    final strokeW = cellSize * 0.08;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final headLen = cellSize * 0.32;
    final fullPoints = _buildFullPolyline();
    final totalLen = _polylineLength(fullPoints);
    final escapeLen = step * 10.0;
    final arrowBodyLen = totalLen - escapeLen;

    if (progress == 0.0) {
      _drawFullArrow(canvas, paint, headLen);
      canvas.restore();
      return;
    }

    final headTravel = arrowBodyLen + progress * escapeLen;
    final tailCut = progress * totalLen;

    final clippedFull = _clipPolyline(fullPoints, tailCut, headTravel);
    if (clippedFull == null || clippedFull.points.length < 2) {
      canvas.restore();
      return;
    }

    final rawTip = clippedFull.points.last;
    final shaftTopDist = math.max(tailCut, headTravel - headLen);
    final clippedShaft = _clipPolyline(fullPoints, tailCut, shaftTopDist);

    if (clippedShaft != null && clippedShaft.points.length >= 2) {
      final path = Path()
        ..moveTo(clippedShaft.points.first.dx, clippedShaft.points.first.dy);
      for (var i = 1; i < clippedShaft.points.length; i++) {
        path.lineTo(clippedShaft.points[i].dx, clippedShaft.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    _drawHead(canvas, rawTip, clippedFull.tipDirection, headLen);
    canvas.restore();
  }

  void _drawFullArrow(Canvas canvas, Paint paint, double headLen) {
    if (segments.isEmpty) return;
    final tip = segments.last.end;
    final (dr, dc) = segments.last.direction.delta;
    final shaftDirNorm = Offset(dc.toDouble(), dr.toDouble());
    final shaftEnd = tip - shaftDirNorm * headLen;

    final path = Path()
      ..moveTo(segments.first.start.dx, segments.first.start.dy);
    for (var i = 0; i < segments.length - 1; i++) {
      path.lineTo(segments[i].end.dx, segments[i].end.dy);
    }
    path.lineTo(shaftEnd.dx, shaftEnd.dy);

    canvas.drawPath(path, paint);
    _drawHead(canvas, tip, segments.last.direction, headLen);
  }

  List<Offset> _buildFullPolyline() {
    final pts = <Offset>[segments.first.start];
    for (final seg in segments) {
      pts.add(seg.end);
    }
    final last = pts.last;
    final (dr, dc) = segments.last.direction.delta;
    pts.add(Offset(last.dx + dc * step * 10, last.dy + dr * step * 10));
    return pts;
  }

  double _polylineLength(List<Offset> pts) {
    var len = 0.0;
    for (var i = 0; i < pts.length - 1; i++) {
      len += (pts[i + 1] - pts[i]).distance;
    }
    return len;
  }

  _ClippedPolyline? _clipPolyline(
    List<Offset> pts,
    double startDist,
    double endDist,
  ) {
    final result = <Offset>[];
    Direction tipDir = segments.last.direction;
    double traveled = 0.0;

    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final segLen = (b - a).distance;
      if (segLen == 0) continue;

      final segStart = traveled;
      final segEnd = traveled + segLen;

      if (segEnd <= startDist) {
        traveled = segEnd;
        continue;
      }
      if (segStart >= endDist) break;

      final t0 = math.max(0.0, (startDist - segStart) / segLen);
      final t1 = math.min(1.0, (endDist - segStart) / segLen);

      final p0 = Offset.lerp(a, b, t0)!;
      final p1 = Offset.lerp(a, b, t1)!;

      if (result.isEmpty) result.add(p0);
      result.add(p1);

      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      if (dx.abs() > dy.abs()) {
        tipDir = dx > 0 ? Direction.right : Direction.left;
      } else {
        tipDir = dy > 0 ? Direction.down : Direction.up;
      }
      traveled = segEnd;
    }
    if (result.length < 2) return null;
    return _ClippedPolyline(points: result, tipDirection: tipDir);
  }

  void _drawHead(Canvas canvas, Offset tip, Direction dir, double headLen) {
    const headAngle = 0.52;
    final angle = switch (dir) {
      Direction.right => 0.0,
      Direction.left => math.pi,
      Direction.down => math.pi / 2,
      Direction.up => -math.pi / 2,
    };

    final leftWing = Offset(
      tip.dx - headLen * math.cos(angle + headAngle),
      tip.dy - headLen * math.sin(angle + headAngle),
    );
    final rightWing = Offset(
      tip.dx - headLen * math.cos(angle - headAngle),
      tip.dy - headLen * math.sin(angle - headAngle),
    );

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(leftWing.dx, leftWing.dy)
      ..lineTo(rightWing.dx, rightWing.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _SnakeArrowPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.drawOffset != drawOffset;
}

class _ClippedPolyline {
  final List<Offset> points;
  final Direction tipDirection;
  const _ClippedPolyline({required this.points, required this.tipDirection});
}
