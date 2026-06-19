import 'direction.dart';
import 'position.dart';

enum ArrowShape { straight, bent }

class ArrowPiece {
  final String id;
  final Position position;
  final Direction direction;
  final int length;
  final ArrowShape shape;
  final List<Direction> bendDirections;

  const ArrowPiece({
    required this.id,
    required this.position,
    this.direction = Direction.up,
    this.length = 1,
    this.shape = ArrowShape.straight,
    this.bendDirections = const [],
  });

  List<Direction> get segments {
    if (shape == ArrowShape.bent) return bendDirections;
    return List.filled(length, direction);
  }

  Direction get moveDirection {
    if (shape == ArrowShape.bent && bendDirections.isNotEmpty) {
      return bendDirections.last;
    }
    return direction;
  }

  List<Position> get bodyCells {
    final cells = <Position>[position];
    var cur = position;
    for (final d in segments) {
      cur = cur.move(d);
      cells.add(cur);
    }
    return cells;
  }

  Position get headCell => bodyCells.last;

  ArrowPiece copyWith({
    Position? position,
    Direction? direction,
    int? length,
    ArrowShape? shape,
    List<Direction>? bendDirections,
  }) {
    return ArrowPiece(
      id: id,
      position: position ?? this.position,
      direction: direction ?? this.direction,
      length: length ?? this.length,
      shape: shape ?? this.shape,
      bendDirections: bendDirections ?? this.bendDirections,
    );
  }
}
