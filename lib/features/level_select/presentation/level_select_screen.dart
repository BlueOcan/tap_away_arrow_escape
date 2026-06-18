import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../game/domain/models/level_model.dart';
import '../../game/domain/models/sample_levels.dart';
import '../../game/presentation/game_screen.dart';
import '../../progress/presentation/progress_provider.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<LevelModel> levels = SampleLevels.all;
    final maxUnlocked = ref.watch(progressNotifierProvider);

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
            final isUnlocked = level.id <= maxUnlocked;
            return _LevelTile(
              level: level,
              isUnlocked: isUnlocked,
              onTap: isUnlocked
                  ? () async {
                      final completed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(level: level),
                        ),
                      );
                      if (completed == true) {
                        await ref
                            .read(progressNotifierProvider.notifier)
                            .completeLevel(level.id);
                      }
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final LevelModel level;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.level,
    required this.isUnlocked,
    required this.onTap,
  });

  Color _difficultyColor() {
    switch (level.difficulty) {
      case 'medium':
        return AppColors.accent;
      case 'hard':
        return AppColors.path;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.surface : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: isUnlocked
              ? Border.all(
                  color: _difficultyColor().withOpacity(0.4),
                  width: 1.5,
                )
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${level.id}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (!isUnlocked)
              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.lock_rounded,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            if (isUnlocked)
              Positioned(
                bottom: 6,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _difficultyColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
