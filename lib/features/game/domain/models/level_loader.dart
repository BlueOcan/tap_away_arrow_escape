import 'dart:convert';
import 'package:flutter/services.dart';

import 'arrow_piece.dart';
import 'direction.dart';
import 'level_model.dart';
import 'position.dart';

class LevelLoader {
  static List<LevelModel>? _cache;

  static Future<List<LevelModel>> loadAll() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/levels/levels.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final levelsJson = decoded['levels'] as List<dynamic>;

    final levels = levelsJson
        .map((e) => _parseLevel(e as Map<String, dynamic>))
        .toList();

    levels.sort((a, b) => a.id.compareTo(b.id));
    _cache = levels;
    return levels;
  }

  static LevelModel _parseLevel(Map<String, dynamic> json) {
    final boardCellsJson = json['boardCells'] as List<dynamic>;

    // Maps index 0 to Column (X) and index 1 to Row (Y)
    final boardCells = boardCellsJson
        .map((c) => Position((c as List)[1] as int, c[0] as int))
        .toSet();

    final arrowsJson = json['arrows'] as List<dynamic>;
    final arrows = arrowsJson
        .map((a) => _parseArrow(a as Map<String, dynamic>))
        .toList();

    return LevelModel(
      id: json['id'] as int,
      difficulty: json['difficulty'] as String,
      gridSize: json['gridSize'] as int,
      cellSize: (json['cellSize'] as num).toDouble(),
      boardCells: boardCells,
      arrows: arrows,
    );
  }

  static ArrowPiece _parseArrow(Map<String, dynamic> json) {
    final bodyJson = json['body'] as List<dynamic>;

    // Maps absolute coordinate lists [X, Y] directly to Position(row, col)
    final body = bodyJson.map((c) {
      final coord = c as List<dynamic>;
      final int x = coord[0] as int; // Column
      final int y = coord[1] as int; // Row
      return Position(y, x); // Position(row, col)
    }).toList();

    return ArrowPiece(
      id: json['id'] as String,
      body: body,
      exitDirection: _parseDirection(json['exitDirection'] as String),
    );
  }

  static Direction _parseDirection(String s) {
    switch (s.toLowerCase().trim()) {
      case 'up':
        return Direction.up;
      case 'down':
        return Direction.down;
      case 'left':
        return Direction.left;
      case 'right':
        return Direction.right;
      default:
        throw FormatException('Unknown direction: $s');
    }
  }
}
