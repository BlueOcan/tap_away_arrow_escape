import 'direction.dart';
import 'position.dart';

enum ArrowShape { straight, bent }

class ArrowPiece {
  final String id;
  final List<Position> body; // [Tail -> ... -> Head]

  const ArrowPiece({required this.id, required this.body});

  List<Position> get bodyCells => body;

  Position get headCell => body.last;

  Position get position => body.first;

  List<Direction> get segments {
    final list = <Direction>[];

    for (var i = 0; i < body.length - 1; i++) {
      final current = body[i];
      final next = body[i + 1];

      final dx = next.x - current.x;
      final dy = next.y - current.y;

      if (dx == 0 && dy == -1) list.add(Direction.up);
      if (dx == 0 && dy == 1) list.add(Direction.down);
      if (dx == -1 && dy == 0) list.add(Direction.left);
      if (dx == 1 && dy == 0) list.add(Direction.right);
    }

    return list;
  }

  Direction get moveDirection {
    final segs = segments;

    if (segs.isEmpty) {
      return Direction.right;
    }

    return segs.last;
  }

  Direction get direction => moveDirection;

  int get length => body.length - 1;

  ArrowShape get shape {
    final segs = segments;

    if (segs.isEmpty) return ArrowShape.straight;

    final firstDir = segs.first;

    return segs.every((d) => d == firstDir)
        ? ArrowShape.straight
        : ArrowShape.bent;
  }

  List<Direction> get bendDirections => segments;

  ArrowPiece copyWith({List<Position>? body}) {
    return ArrowPiece(id: id, body: body ?? this.body);
  }
}
