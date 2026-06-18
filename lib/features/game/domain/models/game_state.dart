import 'arrow_piece.dart';
import 'level_model.dart';

enum GamePhase { playing, won, lost }

class LastMove {
  final String pieceId;
  final bool wasEscape;

  const LastMove({required this.pieceId, required this.wasEscape});
}

class GameState {
  final LevelModel level;
  final List<ArrowPiece> arrows;
  final int livesRemaining;
  final GamePhase phase;
  final LastMove? lastMove;

  const GameState({
    required this.level,
    required this.arrows,
    required this.livesRemaining,
    required this.phase,
    this.lastMove,
  });

  factory GameState.initial(LevelModel level, {required int startingLives}) {
    return GameState(
      level: level,
      arrows: List.of(level.arrows),
      livesRemaining: startingLives,
      phase: GamePhase.playing,
    );
  }

  GameState copyWith({
    List<ArrowPiece>? arrows,
    int? livesRemaining,
    GamePhase? phase,
    LastMove? lastMove,
  }) {
    return GameState(
      level: level,
      arrows: arrows ?? this.arrows,
      livesRemaining: livesRemaining ?? this.livesRemaining,
      phase: phase ?? this.phase,
      lastMove: lastMove,
    );
  }
}
