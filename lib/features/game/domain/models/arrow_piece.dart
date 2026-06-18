import 'direction.dart';
import 'position.dart';

class ArrowPiece {
  final String id;
  final Position position;
  final Direction direction;
  final int length;

  const ArrowPiece({
    required this.id,
    required this.position,
    required this.direction,
    this.length = 1,
  });

  ArrowPiece copyWith({Position? position, Direction? direction, int? length}) {
    return ArrowPiece(
      id: id,
      position: position ?? this.position,
      direction: direction ?? this.direction,
      length: length ?? this.length,
    );
  }
}
