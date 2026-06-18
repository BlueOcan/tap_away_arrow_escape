import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/arrow_piece.dart';
import '../../domain/models/level_model.dart';
import 'arrow_tile.dart';

class BoardWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final gap = boardSize * 0.015;
        final cellSize =
            (boardSize - gap * (level.gridSize - 1)) / level.gridSize;
        final step = cellSize + gap;

        final occupiedPositions = {for (final a in arrows) a.position: a};

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(
            children: [
              for (final pos in level.boardCells)
                if (!occupiedPositions.containsKey(pos))
                  Positioned(
                    left: pos.col * step,
                    top: pos.row * step,
                    child: _EmptyDot(cellSize: cellSize),
                  ),
              for (final piece in arrows)
                Positioned(
                  left: piece.position.col * step,
                  top: piece.position.row * step,
                  child: ArrowTile(
                    key: ValueKey(piece.id),
                    piece: piece,
                    cellSize: cellSize,
                    step: step,
                    triggerEscape: animatingEscapeId == piece.id,
                    triggerBlocked: animatingBlockedId == piece.id,
                    onTap: () => onTapArrow(piece.id),
                    onEscapeAnimationDone: onEscapeAnimationDone,
                    onBlockedAnimationDone: onBlockedAnimationDone,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyDot extends StatelessWidget {
  final double cellSize;
  const _EmptyDot({required this.cellSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Center(
        child: Container(
          width: cellSize * 0.12,
          height: cellSize * 0.12,
          decoration: const BoxDecoration(
            color: AppColors.gridLine,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
