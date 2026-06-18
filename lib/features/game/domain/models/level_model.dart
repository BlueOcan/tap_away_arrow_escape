import 'arrow_piece.dart';
import 'position.dart';

class LevelModel {
  final int id;
  final String difficulty;
  final int gridSize;
  final Set<Position> boardCells;
  final List<ArrowPiece> arrows;
  final double cellSize;

  const LevelModel({
    required this.id,
    required this.difficulty,
    required this.gridSize,
    required this.boardCells,
    required this.arrows,
    this.cellSize = 64.0,
  });

  @override
  bool operator ==(Object other) => other is LevelModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
