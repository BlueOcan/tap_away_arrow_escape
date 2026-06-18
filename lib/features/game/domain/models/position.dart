import 'direction.dart';

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  Position move(Direction dir) {
    final (dr, dc) = dir.delta;
    return Position(row + dr, col + dc);
  }

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row,$col)';
}
