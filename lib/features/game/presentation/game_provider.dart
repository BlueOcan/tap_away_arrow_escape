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

    final otherArrows = state.arrows.where((a) => a.id != pieceId).toList();

    final occupied = <Position>{};
    for (final a in otherArrows) {
      occupied.addAll(a.bodyCells);
    }

    final moveDir = piece.segments.isNotEmpty
        ? piece.segments.last
        : Direction.right;

    final (dx, dy) = moveDir.delta;

    var currentBody = List<Position>.from(piece.body);

    bool isEscape = false;

    final maxSteps = state.level.boardCells.length + 6;

    for (var step = 0; step < maxSteps; step++) {
      final head = currentBody.last;

      final nextHead = Position(head.x + dx, head.y + dy);

      if (occupied.contains(nextHead) &&
          state.level.boardCells.contains(nextHead)) {
        isEscape = false;
        break;
      }

      currentBody = [...currentBody.sublist(1), nextHead];

      final anyOnBoard = currentBody.any(
        (pos) => state.level.boardCells.contains(pos),
      );

      if (!anyOnBoard) {
        isEscape = true;
        break;
      }
    }

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
