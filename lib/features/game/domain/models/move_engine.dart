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

    // Snake/train movement: only the HEAD needs a clear cell.
    // Each body cell slides into the position previously held by the cell ahead of it.
    // Collision check is ONLY on the next position of the HEAD.
    var currentBody = List<Position>.from(piece.bodyCells);
    final moveDir = piece.moveDirection;
    final path = <Position>[];

    final maxSteps = level.boardCells.length + 6;

    for (var step = 0; step < maxSteps; step++) {
      final nextHead = currentBody.last.move(moveDir);

      // Check if next head position hits another piece on a valid board cell
      if (occupied.contains(nextHead) && level.boardCells.contains(nextHead)) {
        return MoveResult(MoveOutcome.blocked, path);
      }

      // Slide: new head appended, old tail dropped (snake movement)
      currentBody = [...currentBody.sublist(1), nextHead];

      // Escape condition: entire body has left the board
      final anyOnBoard = currentBody.any(level.boardCells.contains);
      if (!anyOnBoard) {
        return MoveResult(MoveOutcome.escaped, path);
      }
    }

    return MoveResult(MoveOutcome.blocked, path);
  }
}
