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
    final boardCells = boardCellsJson
        .map((c) => Position((c as List)[0] as int, c[1] as int))
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
    final posJson = json['position'] as List<dynamic>;
    final shapeStr = json['shape'] as String? ?? 'straight';

    if (shapeStr == 'bent') {
      final bendListJson = json['bendDirections'] as List<dynamic>;
      final bendDirections = bendListJson
          .map((d) => _parseDirection(d as String))
          .toList();

      return ArrowPiece(
        id: json['id'] as String,
        position: Position(posJson[0] as int, posJson[1] as int),
        shape: ArrowShape.bent,
        bendDirections: bendDirections,
      );
    }

    return ArrowPiece(
      id: json['id'] as String,
      position: Position(posJson[0] as int, posJson[1] as int),
      direction: _parseDirection(json['direction'] as String),
      length: (json['length'] as int?) ?? 1,
      shape: ArrowShape.straight,
    );
  }

  static Direction _parseDirection(String s) {
    switch (s) {
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
