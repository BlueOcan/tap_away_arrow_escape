import 'direction.dart';
import 'position.dart';

enum ArrowShape {
  straight, // classic single-direction arrow
  lShape, // turns 90° — has a bend
}

class ArrowPiece {
  final String id;
  final Position position;
  final Direction direction;
  final int length;
  final ArrowShape shape;
  final Direction?
  turnDirection; // only for lShape: the direction after the turn

  const ArrowPiece({
    required this.id,
    required this.position,
    required this.direction,
    this.length = 1,
    this.shape = ArrowShape.straight,
    this.turnDirection,
  });

  ArrowPiece copyWith({
    Position? position,
    Direction? direction,
    int? length,
    ArrowShape? shape,
    Direction? turnDirection,
  }) {
    return ArrowPiece(
      id: id,
      position: position ?? this.position,
      direction: direction ?? this.direction,
      length: length ?? this.length,
      shape: shape ?? this.shape,
      turnDirection: turnDirection ?? this.turnDirection,
    );
  }
}
