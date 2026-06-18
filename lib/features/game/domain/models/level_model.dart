import 'arrow_piece.dart';
import 'position.dart';

class LevelModel {
  final int id;
  final String difficulty;
  final int gridSize;
  final Set<Position> boardCells;
  final List<ArrowPiece> arrows;

  const LevelModel({
    required this.id,
    required this.difficulty,
    required this.gridSize,
    required this.boardCells,
    required this.arrows,
  });

  factory LevelModel.square({
    required int id,
    required String difficulty,
    required int gridSize,
    required List<ArrowPiece> arrows,
  }) {
    final cells = <Position>{};
    for (var r = 0; r < gridSize; r++) {
      for (var c = 0; c < gridSize; c++) {
        cells.add(Position(r, c));
      }
    }
    return LevelModel(
      id: id,
      difficulty: difficulty,
      gridSize: gridSize,
      boardCells: cells,
      arrows: arrows,
    );
  }

  @override
  bool operator ==(Object other) => other is LevelModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
