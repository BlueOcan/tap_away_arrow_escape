import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/models/arrow_piece.dart';
import '../domain/models/direction.dart';
import '../domain/models/game_state.dart';
import '../domain/models/level_model.dart';
import '../domain/models/position.dart';

class GameController extends StateNotifier<GameState> {
  GameController(LevelModel level)
    : super(GameState.initial(level, startingLives: AppConstants.maxLives));

  void tapArrow(String pieceId) {
    if (state.phase != GamePhase.playing) return;
    if (state.lastMove != null) return;

    ArrowPiece? piece;
    for (final a in state.arrows) {
      if (a.id == pieceId) {
        piece = a;
        break;
      }
    }
    if (piece == null) return;

    // ── RIGID BODY COLLISION ENGINE ──────────────────────────────────────────
    int dRow = 0;
    int dCol = 0;

    // Map your Direction enum safely to coordinate shifts
    switch (piece.exitDirection) {
      case Direction.up:
        dRow = -1;
        break;
      case Direction.down:
        dRow = 1;
        break;
      case Direction.left:
        dCol = -1;
        break;
      case Direction.right:
        dCol = 1;
        break;
    }

    final otherArrows = state.arrows.where((a) => a.id != pieceId).toList();
    bool isEscape = true;
    int step = 1;

    // Track the entire slide trajectory of the rigid block until it exits the board
    while (true) {
      // Shift every single piece coordinate uniformly by the direction vector step
      final shiftedPositions = piece.body.map((pos) {
        return Position(pos.row + (dRow * step), pos.col + (dCol * step));
      }).toList();

      // Check if any part of this step's shifted block occupies the board boundaries
      bool anyCellOnBoard = false;
      for (final pos in shiftedPositions) {
        final isOnBoard = state.level.boardCells.any(
          (cell) => cell.row == pos.row && cell.col == pos.col,
        );
        if (isOnBoard) {
          anyCellOnBoard = true;
          break;
        }
      }

      // If the entire rigid layout has moved outside board boundaries, it successfully escaped!
      if (!anyCellOnBoard) {
        break;
      }

      // Check if the current block path overlaps with any other remaining pieces
      bool collided = false;
      for (final other in otherArrows) {
        for (final shiftedPos in shiftedPositions) {
          final hitsOther = other.body.any(
            (b) => b.row == shiftedPos.row && b.col == shiftedPos.col,
          );
          if (hitsOther) {
            collided = true;
            break;
          }
        }
        if (collided) break;
      }

      // If a collision occurs at any step along the path, flag movement as blocked
      if (collided) {
        isEscape = false;
        break;
      }

      step++;
    }
    // ─────────────────────────────────────────────────────────────────────────

    if (isEscape) {
      state = state.copyWith(
        lastMove: LastMove(pieceId: pieceId, wasEscape: true),
      );
    } else {
      final remainingLives = state.livesRemaining - 1;
      final lost = remainingLives <= 0;

      state = state.copyWith(
        livesRemaining: remainingLives < 0 ? 0 : remainingLives,
        phase: lost ? GamePhase.lost : GamePhase.playing,
        lastMove: LastMove(pieceId: pieceId, wasEscape: false),
      );
    }
  }

  void confirmEscape(String pieceId) {
    final remainingArrows = state.arrows.where((a) => a.id != pieceId).toList();
    final won = remainingArrows.isEmpty;

    state = GameState(
      level: state.level,
      arrows: remainingArrows,
      livesRemaining: state.livesRemaining,
      phase: won ? GamePhase.won : GamePhase.playing,
      lastMove: null,
    );
  }

  void clearLastMove() {
    state = GameState(
      level: state.level,
      arrows: state.arrows,
      livesRemaining: state.livesRemaining,
      phase: state.phase,
      lastMove: null,
    );
  }

  void reset() {
    state = GameState.initial(
      state.level,
      startingLives: AppConstants.maxLives,
    );
  }
}

final gameControllerProvider =
    StateNotifierProvider.family<GameController, GameState, LevelModel>(
      (ref, level) => GameController(level),
    );
