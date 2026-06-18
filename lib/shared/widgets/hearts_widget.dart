import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class HeartsWidget extends StatelessWidget {
  final int livesRemaining;
  final int maxLives;

  const HeartsWidget({
    super.key,
    required this.livesRemaining,
    required this.maxLives,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (i) {
        final filled = i < livesRemaining;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(
            filled ? Icons.favorite : Icons.favorite_border,
            color: filled ? AppColors.heartFilled : AppColors.heartEmpty,
            size: 26,
          ),
        );
      }),
    );
  }
}
