import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/arrow_piece.dart';
import '../../domain/models/level_model.dart';
import '../../domain/models/position.dart';
import 'arrow_tile.dart';

class BoardWidget extends StatefulWidget {
  final LevelModel level;
  final List<ArrowPiece> arrows;
  final String? animatingEscapeId;
  final String? animatingBlockedId;
  final void Function(String pieceId) onTapArrow;
  final VoidCallback onEscapeAnimationDone;
  final VoidCallback onBlockedAnimationDone;

  const BoardWidget({
    super.key,
    required this.level,
    required this.arrows,
    required this.onTapArrow,
    required this.onEscapeAnimationDone,
    required this.onBlockedAnimationDone,
    this.animatingEscapeId,
    this.animatingBlockedId,
  });

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Set<Position> _computeHiddenDots() {
    final hidden = <Position>{};
    for (final piece in widget.arrows) {
      hidden.addAll(piece.bodyCells);
    }
    return hidden;
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = widget.level.cellSize;
    final gap = cellSize * 0.15;
    final step = cellSize + gap;

    int maxRow = 0, maxCol = 0;
    for (final pos in widget.level.boardCells) {
      if (pos.row > maxRow) maxRow = pos.row;
      if (pos.col > maxCol) maxCol = pos.col;
    }

    final canvasW = (maxCol + 1) * step + cellSize * 2;
    final canvasH = (maxRow + 1) * step + cellSize * 2;

    const boardPadding = 1.0;
    final boardOffsetX = boardPadding * step;
    final boardOffsetY = boardPadding * step;

    final hiddenDots = _computeHiddenDots();

    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          transformationController: _transformController,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.2,
          maxScale: 4.0,
          constrained: false,
          child: SizedBox(
            width: canvasW + boardOffsetX * 2,
            height: canvasH + boardOffsetY * 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Render Background Grid Dots
                for (final pos in widget.level.boardCells)
                  if (!hiddenDots.contains(pos))
                    Positioned(
                      left: boardOffsetX + pos.col * step,
                      top: boardOffsetY + pos.row * step,
                      child: _GridDot(cellSize: cellSize),
                    ),

                // 2. Render Dynamic Arrow Game Pieces
                for (final piece in widget.arrows)
                  ArrowTile(
                    key: ValueKey(piece.id),
                    piece: piece,
                    cellSize: cellSize,
                    step: step,
                    boardOffsetX: boardOffsetX,
                    boardOffsetY: boardOffsetY,
                    triggerEscape: widget.animatingEscapeId == piece.id,
                    triggerBlocked: widget.animatingBlockedId == piece.id,
                    onTap: () => widget.onTapArrow(piece.id),
                    onEscapeAnimationDone: widget.onEscapeAnimationDone,
                    onBlockedAnimationDone: widget.onBlockedAnimationDone,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GridDot extends StatelessWidget {
  final double cellSize;

  const _GridDot({required this.cellSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Center(
        child: Container(
          width: cellSize * 0.10,
          height: cellSize * 0.10,
          decoration: const BoxDecoration(
            color: AppColors.gridLine,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
