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
    final occupied = <Position>{};
    for (final a in arrows) {
      if (a.id == piece.id) continue;
      occupied.addAll(a.bodyCells);
    }

    final path = <Position>[];
    var currentBody = List<Position>.from(piece.bodyCells);
    final moveDir = piece.moveDirection;

    final maxSteps = level.boardCells.length + 6;
    var steps = 0;

    while (steps < maxSteps) {
      // Shift the entire rigid structure by one step along the departure vector
      currentBody = currentBody.map((pos) => pos.move(moveDir)).toList();
      steps++;

      // Check if the entire structure has cleared the board completely
      final anyPartStillOnBoard = currentBody.any(
        (pos) => level.boardCells.contains(pos),
      );
      if (!anyPartStillOnBoard) {
        return MoveResult(MoveOutcome.escaped, path);
      }

      // Check if any single part of our shifted body collides with another piece
      for (final pos in currentBody) {
        if (occupied.contains(pos) && level.boardCells.contains(pos)) {
          path.add(pos); // Track where collision happened
          return MoveResult(MoveOutcome.blocked, path);
        }
      }
    }
    return MoveResult(MoveOutcome.blocked, path);
  }
}
