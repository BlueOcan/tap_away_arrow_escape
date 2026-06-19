import 'dart:convert';
import 'package:flutter/services.dart';

import 'arrow_piece.dart';
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

    final boardCells = boardCellsJson.map((c) {
      final coord = c as List<dynamic>;

      return Position(
        coord[0] as int, // x
        coord[1] as int, // y
      );
    }).toSet();

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

    final body = bodyJson.map((c) {
      final coord = c as List<dynamic>;

      return Position(coord[0] as int, coord[1] as int);
    }).toList();

    return ArrowPiece(id: json['id'] as String, body: body);
  }
}
