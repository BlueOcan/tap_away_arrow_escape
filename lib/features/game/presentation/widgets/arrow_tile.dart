import 'dart:math' as math;

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
    final escapeDir =
        widget.piece.shape == ArrowShape.lShape &&
            widget.piece.turnDirection != null
        ? widget.piece.turnDirection!
        : widget.piece.direction;
    final (dr, dc) = escapeDir.delta;
    final bump = Offset(
      dc * widget.cellSize * 0.18,
      dr * widget.cellSize * 0.18,
    );

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

  /// Build segments in LOCAL canvas coordinates.
  ///
  /// Rule: the Positioned parent places this widget at
  ///   left = piece.position.col * step
  ///   top  = piece.position.row * step
  ///
  /// So inside the canvas the tail cell's TOP-LEFT is (0, 0).
  /// The centre of that cell is (cs/2, cs/2).
  /// Every other point is offset from there by multiples of [step].
  List<_Segment> _buildSegments() {
    final cs = widget.cellSize;
    final s = widget.step;
    final piece = widget.piece;

    // Tail cell centre in local coords
    final tailCenter = Offset(cs / 2, cs / 2);

    if (piece.shape == ArrowShape.lShape && piece.turnDirection != null) {
      final (dr1, dc1) = piece.direction.delta;
      final pivot = Offset(tailCenter.dx + dc1 * s, tailCenter.dy + dr1 * s);
      final (dr2, dc2) = piece.turnDirection!.delta;
      final tip = Offset(pivot.dx + dc2 * s, pivot.dy + dr2 * s);
      return [
        _Segment(start: tailCenter, end: pivot, direction: piece.direction),
        _Segment(start: pivot, end: tip, direction: piece.turnDirection!),
      ];
    }

    // Straight — one segment spanning [length] cells
    final (dr, dc) = piece.direction.delta;
    final tip = Offset(
      tailCenter.dx + dc * s * piece.length,
      tailCenter.dy + dr * s * piece.length,
    );
    return [_Segment(start: tailCenter, end: tip, direction: piece.direction)];
  }

  /// The canvas must be large enough to contain ALL segment points
  /// plus the escape overshoot in the head direction.
  ///
  /// We also need to handle arrows that extend BACKWARDS from the anchor
  /// (e.g. a left-facing arrow: tail is at right side of canvas).
  /// We solve this by giving the canvas extra room on all sides and then
  /// translating the content so nothing is clipped.
  @override
  Widget build(BuildContext context) {
    final color = _isFlashingRed ? AppColors.path : AppColors.cellDefault;
    final cs = widget.cellSize;
    final segments = _buildSegments();

    // Compute the natural bounding box of the segments
    double minX = 0, minY = 0, maxX = cs, maxY = cs;
    for (final seg in segments) {
      for (final p in [seg.start, seg.end]) {
        if (p.dx < minX) minX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy > maxY) maxY = p.dy;
      }
    }

    // Add escape overshoot in the head direction
    final headDir = segments.isNotEmpty
        ? segments.last.direction
        : widget.piece.direction;
    final (hdr, hdc) = headDir.delta;
    final overshoot = widget.step * 10;
    if (hdc > 0) maxX += overshoot;
    if (hdc < 0) minX -= overshoot;
    if (hdr > 0) maxY += overshoot;
    if (hdr < 0) minY -= overshoot;

    // Canvas size
    final canvasW = maxX - minX;
    final canvasH = maxY - minY;

    // We need to shift all drawing by (-minX, -minY) so everything fits
    // inside the canvas. We also shift the widget itself by (minX, minY)
    // so the tail cell still aligns with piece.position in the parent Stack.
    final drawOffset = Offset(-minX, -minY);
    final widgetShift = Offset(minX, minY);

    return AnimatedContainer(
      duration: _blockedDuration,
      transform: Matrix4.translationValues(
        _blockedOffset.dx,
        _blockedOffset.dy,
        0,
      ),
      child: Transform.translate(
        // widgetShift corrects the canvas position in the parent
        offset: widgetShift,
        child: GestureDetector(
          onTap: widget.onTap,
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

// ─── Data ────────────────────────────────────────────────────────────────────

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

// ─── Painter ─────────────────────────────────────────────────────────────────

class _SnakeArrowPainter extends CustomPainter {
  final List<_Segment> segments;
  final Color color;
  final double progress;
  final double cellSize;
  final double step;
  final Offset drawOffset; // shifts all coordinates so they fit in the canvas

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

    // Full polyline: tail → ... → original head → escape overshoot point
    final fullPoints = _buildFullPolyline();
    final totalLen = _polylineLength(fullPoints);

    final escapeLen = step * 10.0;
    final arrowBodyLen = totalLen - escapeLen;

    final headTravel = progress * (arrowBodyLen + escapeLen);
    final tailCut = math.max(0.0, headTravel - arrowBodyLen);

    if (progress == 0.0) {
      _drawFullArrow(canvas, paint, headLen);
      canvas.restore();
      return;
    }

    final clipped = _clipPolyline(fullPoints, tailCut, headTravel);
    if (clipped == null || clipped.points.length < 2) {
      _drawFullArrow(canvas, paint, headLen);
      canvas.restore();
      return;
    }

    // Pull the shaft tip back by headLen so it doesn't overlap the triangle
    final rawTip = clipped.points.last;
    final secondLast = clipped
        .points[clipped.points.length > 1 ? clipped.points.length - 2 : 0];
    final shaftDir = (rawTip - secondLast);
    final shaftDirNorm = shaftDir.distance > 0
        ? shaftDir / shaftDir.distance
        : Offset.zero;
    final shaftTip = rawTip - shaftDirNorm * headLen;

    final path = Path()
      ..moveTo(clipped.points.first.dx, clipped.points.first.dy);
    for (var i = 1; i < clipped.points.length - 1; i++) {
      path.lineTo(clipped.points[i].dx, clipped.points[i].dy);
    }
    path.lineTo(shaftTip.dx, shaftTip.dy);

    canvas.drawPath(path, paint);
    _drawHead(canvas, rawTip, clipped.tipDirection, headLen);

    canvas.restore();
  }

  void _drawFullArrow(Canvas canvas, Paint paint, double headLen) {
    if (segments.isEmpty) return;

    // Find the tip and shaft direction
    final tip = segments.last.end;
    final (dr, dc) = segments.last.direction.delta;
    final shaftDirNorm = Offset(dc.toDouble(), dr.toDouble());
    // Pull shaft end back by headLen
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
    // Escape overshoot
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

      // Direction of this segment
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
