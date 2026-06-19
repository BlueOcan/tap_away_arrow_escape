import 'direction.dart';

class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  Position move(Direction dir) {
    final (dx, dy) = dir.delta;
    return Position(x + dx, y + dy);
  }

  @override
  bool operator ==(Object other) =>
      other is Position && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x,$y)';
}
