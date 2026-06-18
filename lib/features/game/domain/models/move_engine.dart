import 'arrow_piece.dart';
import 'level_model.dart';
import 'position.dart';

enum MoveOutcome { escaped, blocked }

class MoveResult {
  final MoveOutcome outcome;
  final List<Position> path;

  const MoveResult(this.outcome, this.path);

  bool get isEscape => outcome == MoveOutcome.escaped;
}

class MoveEngine {
  static MoveResult checkMove(
    LevelModel level,
    List<ArrowPiece> arrows,
    ArrowPiece piece,
  ) {
    final occupied = {
      for (final a in arrows)
        if (a.id != piece.id) a.position,
    };

    final path = <Position>[];
    var current = piece.position;

    final maxSteps = level.boardCells.length + 4;
    var steps = 0;

    while (steps < maxSteps) {
      current = current.move(piece.direction);
      steps++;

      if (!level.boardCells.contains(current)) {
        return MoveResult(MoveOutcome.escaped, path);
      }

      if (occupied.contains(current)) {
        path.add(current);
        return MoveResult(MoveOutcome.blocked, path);
      }

      path.add(current);
    }

    return MoveResult(MoveOutcome.blocked, path);
  }
}
