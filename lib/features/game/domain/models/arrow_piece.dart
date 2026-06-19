import 'direction.dart';
import 'position.dart';

enum ArrowShape { straight, bent }

class ArrowPiece {
  final String id;
  final List<Position> body; // Clean absolute array: [Tail -> ... -> Head]
  final Direction exitDirection; // The exact direction the arrow escapes

  const ArrowPiece({
    required this.id,
    required this.body,
    required this.exitDirection,
  });

  // ===========================================================================
  // 🔄 ANIMATION & UI SAFEGUARDS (Do not delete!)
  // These calculated properties keep your existing UI layout entirely happy.
  // ===========================================================================

  /// Alias for the body array to maintain drawing loop logic
  List<Position> get bodyCells => body;

  /// Retrieves the very tip (head) cell of the arrow
  Position get headCell => body.last;

  /// Retrieves the starting (tail) position of the arrow
  Position get position => body.first;

  /// Maps directly to the exit direction for movement logic
  Direction get moveDirection => exitDirection;

  /// Backward compatibility alias for general direction
  Direction get direction => exitDirection;

  /// Dynamically computes the steps/segments between the body coordinates
  List<Direction> get segments {
    final list = <Direction>[];
    for (var i = 0; i < body.length - 1; i++) {
      final current = body[i];
      final next = body[i + 1];
      final dr = next.row - current.row;
      final dc = next.col - current.col;

      if (dr == -1 && dc == 0) list.add(Direction.up);
      if (dr == 1 && dc == 0) list.add(Direction.down);
      if (dr == 0 && dc == -1) list.add(Direction.left);
      if (dr == 0 && dc == 1) list.add(Direction.right);
    }
    return list;
  }

  /// Calculates the count of extension segments
  int get length => body.length - 1;

  /// Automatically tells the UI if the piece curves or runs straight
  ArrowShape get shape {
    final segs = segments;
    if (segs.isEmpty) return ArrowShape.straight;
    final firstDir = segs.first;
    return segs.every((d) => d == firstDir)
        ? ArrowShape.straight
        : ArrowShape.bent;
  }

  /// Compatibility fallback tracking structural directions
  List<Direction> get bendDirections => segments;

  // ===========================================================================
  // 🛠️ UPDATED COPYWITH
  // ===========================================================================
  ArrowPiece copyWith({List<Position>? body, Direction? exitDirection}) {
    return ArrowPiece(
      id: id,
      body: body ?? this.body,
      exitDirection: exitDirection ?? this.exitDirection,
    );
  }
}
