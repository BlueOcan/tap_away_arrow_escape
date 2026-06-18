import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              _TopBar(
                onBack: () => Navigator.of(context).maybePop(),
                onReset: () => controller.reset(),
                livesRemaining: state.livesRemaining,
              ),
              const SizedBox(height: 24),
              Text(
                'Arrows left: ${state.arrows.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
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
              ),
              const SizedBox(height: 24),
              _buildBottomArea(context, state, controller),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomArea(
    BuildContext context,
    GameState state,
    GameController controller,
  ) {
    if (state.phase == GamePhase.won) {
      return _ResultBanner(
        won: true,
        onContinue: () => Navigator.of(context).maybePop(true),
      );
    }
    if (state.phase == GamePhase.lost) {
      return _ResultBanner(won: false, onContinue: () => controller.reset());
    }
    return const SizedBox(height: 56);
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onReset;
  final int livesRemaining;

  const _TopBar({
    required this.onBack,
    required this.onReset,
    required this.livesRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _RoundIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
            const SizedBox(width: 12),
            _RoundIconButton(icon: Icons.refresh, onTap: onReset),
          ],
        ),
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
      children: [
        Text(
          won ? 'Level Complete!' : 'Out of hearts — try again',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: won ? AppColors.success : AppColors.path,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onContinue,
            child: Text(won ? 'NEXT LEVEL' : 'RETRY'),
          ),
        ),
      ],
    );
  }
}
