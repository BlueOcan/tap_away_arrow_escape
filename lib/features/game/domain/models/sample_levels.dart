import 'arrow_piece.dart';
import 'direction.dart';
import 'level_model.dart';
import 'position.dart';

class SampleLevels {
  static final LevelModel level1 = LevelModel.square(
    id: 1,
    difficulty: 'easy',
    gridSize: 5,
    arrows: [
      const ArrowPiece(
        id: 'a1',
        position: Position(2, 2),
        direction: Direction.right,
      ),
      const ArrowPiece(
        id: 'a2',
        position: Position(2, 4),
        direction: Direction.down,
      ),
      const ArrowPiece(
        id: 'a3',
        position: Position(0, 0),
        direction: Direction.left,
      ),
      const ArrowPiece(
        id: 'a4',
        position: Position(4, 4),
        direction: Direction.right,
      ),
    ],
  );

  static final LevelModel level2 = LevelModel.square(
    id: 2,
    difficulty: 'easy',
    gridSize: 5,
    arrows: [
      const ArrowPiece(
        id: 'b1',
        position: Position(1, 1),
        direction: Direction.right,
      ),
      const ArrowPiece(
        id: 'b2',
        position: Position(1, 2),
        direction: Direction.right,
      ),
      const ArrowPiece(
        id: 'b3',
        position: Position(1, 3),
        direction: Direction.right,
      ),
      const ArrowPiece(
        id: 'b4',
        position: Position(3, 0),
        direction: Direction.up,
      ),
      const ArrowPiece(
        id: 'b5',
        position: Position(2, 0),
        direction: Direction.up,
      ),
    ],
  );

  static final List<LevelModel> all = [level1, level2];
}
