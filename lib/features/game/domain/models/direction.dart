enum Direction { up, down, left, right }

extension DirectionX on Direction {
  (int dr, int dc) get delta {
    switch (this) {
      case Direction.up:
        return (-1, 0);
      case Direction.down:
        return (1, 0);
      case Direction.left:
        return (0, -1);
      case Direction.right:
        return (0, 1);
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
