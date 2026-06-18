import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../game/domain/models/level_model.dart';
import '../../game/domain/models/sample_levels.dart';
import '../../game/presentation/game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LevelModel> levels = SampleLevels.all;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Level')),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: levels.length,
          itemBuilder: (context, index) {
            final level = levels[index];
            return _LevelTile(
              level: level,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GameScreen(level: level)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final LevelModel level;
  final VoidCallback onTap;

  const _LevelTile({required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            '${level.id}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
