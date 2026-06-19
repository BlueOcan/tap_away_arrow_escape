enum Direction { up, down, left, right }

extension DirectionX on Direction {
  (int dx, int dy) get delta {
    switch (this) {
      case Direction.up:
        return (0, -1);

      case Direction.down:
        return (0, 1);

      case Direction.left:
        return (-1, 0);

      case Direction.right:
        return (1, 0);
    }
  }

  double get quarterTurns {
    switch (this) {
      case Direction.up:
        return 0;

      case Direction.right:
        return 1;

      case Direction.down:
        return 2;

      case Direction.left:
        return 3;
    }
  }
}
