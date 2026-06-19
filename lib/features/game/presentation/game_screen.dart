import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../level_select/presentation/level_select_screen.dart';
import '../../progress/presentation/progress_provider.dart';
import '../domain/models/game_state.dart';
import '../domain/models/level_model.dart';
import 'game_provider.dart';
import 'widgets/board_widget.dart';
import '../../../shared/widgets/hearts_widget.dart';

class GameScreen extends ConsumerWidget {
  final LevelModel level;
  const GameScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider(level));
    final controller = ref.read(gameControllerProvider(level).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _TopBar(
                levelId: level.id,
                onBack: () => Navigator.of(context).maybePop(),
                onReset: () => controller.reset(),
                livesRemaining: state.livesRemaining,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Arrows: ${state.arrows.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(
                        Icons.pinch,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Pinch to zoom',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRect(
                child: BoardWidget(
                  level: state.level,
                  arrows: state.arrows,
                  animatingEscapeId: state.lastMove?.wasEscape == true
                      ? state.lastMove!.pieceId
                      : null,
                  animatingBlockedId: state.lastMove?.wasEscape == false
                      ? state.lastMove!.pieceId
                      : null,
                  onTapArrow: (id) => controller.tapArrow(id),
                  onEscapeAnimationDone: () {
                    final id = state.lastMove?.pieceId;
                    if (id != null) controller.confirmEscape(id);
                  },
                  onBlockedAnimationDone: () => controller.clearLastMove(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: _buildBottomArea(context, ref, state, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomArea(
    BuildContext context,
    WidgetRef ref,
    GameState state,
    GameController controller,
  ) {
    if (state.phase == GamePhase.won) {
      return _ResultBanner(
        won: true,
        onContinue: () async {
          await ref
              .read(progressNotifierProvider.notifier)
              .completeLevel(level.id);
          if (!context.mounted) return;

          final levels = await ref.read(levelsProvider.future);
          final nextIndex = levels.indexWhere((l) => l.id == level.id) + 1;
          if (!context.mounted) return;

          if (nextIndex < levels.length) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => GameScreen(level: levels[nextIndex]),
              ),
            );
          } else {
            Navigator.of(context).maybePop(true);
          }
        },
      );
    }
    if (state.phase == GamePhase.lost) {
      return _ResultBanner(won: false, onContinue: () => controller.reset());
    }
    return const SizedBox(height: 48);
  }
}

class _TopBar extends StatelessWidget {
  final int levelId;
  final VoidCallback onBack;
  final VoidCallback onReset;
  final int livesRemaining;

  const _TopBar({
    required this.levelId,
    required this.onBack,
    required this.onReset,
    required this.livesRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
        const SizedBox(width: 8),
        _RoundIconButton(icon: Icons.refresh, onTap: onReset),
        const Spacer(),
        Text(
          'Level $levelId',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        HeartsWidget(livesRemaining: livesRemaining, maxLives: 3),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final bool won;
  final VoidCallback onContinue;

  const _ResultBanner({required this.won, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          won ? '🎉 Level Complete!' : 'Out of hearts — try again',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: won ? AppColors.success : AppColors.path,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onContinue,
            child: Text(won ? 'NEXT LEVEL' : 'RETRY'),
          ),
        ),
      ],
    );
  }
}
