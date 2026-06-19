import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../level_select/presentation/level_select_screen.dart';
import '../../progress/presentation/progress_provider.dart';
import '../../settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProgress());
  }

  Future<void> _loadProgress() async {
    final saved = await ref
        .read(progressRepositoryProvider)
        .getMaxUnlockedLevel();
    ref.read(progressNotifierProvider.notifier).initMaxUnlocked(saved);
  }

  @override
  Widget build(BuildContext context) {
    final maxUnlocked = ref.watch(progressNotifierProvider);
    final bg = AppColors.bg(context);
    final surfMut = AppColors.surfMuted(context);
    final textPrim = AppColors.textPrim(context);
    final textSec = AppColors.textSec(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 3),
              _Logo(color: textPrim),
              const SizedBox(height: 12),
              Text(
                'Level $maxUnlocked',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              const Spacer(flex: 4),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LevelSelectScreen(),
                    ),
                  ),
                  child: const Text(
                    'Play',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              _BottomNav(
                surfaceMuted: surfMut,
                textPrimary: textPrim,
                textSecondary: textSec,
                onSettingsTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logo ─────────────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  final Color color;
  const _Logo({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          size: const Size(40, 36),
          painter: _TrianglePainter(color: color),
        ),
        Text(
          'rrows',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Bottom nav ────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onSettingsTap;

  const _BottomNav({
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            active: true,
            activeColor: textPrimary,
            inactiveColor: textSecondary,
          ),
          _NavItem(
            icon: Icons.lock,
            label: 'Scores',
            active: false,
            activeColor: textPrimary,
            inactiveColor: textSecondary,
          ),
          _NavItem(
            icon: Icons.emoji_events_rounded,
            label: 'Levels',
            active: false,
            activeColor: textPrimary,
            inactiveColor: textSecondary,
          ),
          _NavItem(
            icon: Icons.settings,
            label: 'Settings',
            active: false,
            activeColor: textPrimary,
            inactiveColor: textSecondary,
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
