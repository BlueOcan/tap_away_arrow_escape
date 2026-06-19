import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../game/domain/models/level_loader.dart';
import '../../game/domain/models/level_model.dart';
import '../../game/presentation/game_screen.dart';
import '../../progress/presentation/progress_provider.dart';

final levelsProvider = FutureProvider<List<LevelModel>>((ref) {
  return LevelLoader.loadAll();
});

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(levelsProvider);
    final maxUnlocked = ref.watch(progressNotifierProvider);

    final bg = AppColors.bg(context);
    final surf = AppColors.surf(context);
    final surfMut = AppColors.surfMuted(context);
    final textPrim = AppColors.textPrim(context);
    final textSec = AppColors.textSec(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Level', style: TextStyle(color: textPrim)),
        backgroundColor: bg,
        foregroundColor: textPrim,
        iconTheme: IconThemeData(color: textPrim),
      ),
      backgroundColor: bg,
      body: levelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load levels: $err')),
        data: (levels) => Padding(
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
                surfaceColor: isUnlocked ? surf : surfMut,
                textPrimary: textPrim,
                textSecondary: textSec,
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
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final LevelModel level;
  final bool isUnlocked;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.level,
    required this.isUnlocked,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
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
          color: surfaceColor,
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
                  color: isUnlocked ? textPrimary : textSecondary,
                ),
              ),
            ),
            if (!isUnlocked)
              Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.lock_rounded, size: 12, color: textSecondary),
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
