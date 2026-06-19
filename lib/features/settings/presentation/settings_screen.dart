import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

// ---------------------------------------------------------------------------
// Local bool providers (vibration, sound — wired up later)
// ---------------------------------------------------------------------------

final vibrationProvider = StateNotifierProvider<_BoolNotifier, bool>(
  (ref) => _BoolNotifier('pref_vibration', defaultValue: true),
);

final soundProvider = StateNotifierProvider<_BoolNotifier, bool>(
  (ref) => _BoolNotifier('pref_sound', defaultValue: true),
);

final removeAdsProvider = StateNotifierProvider<_BoolNotifier, bool>(
  (ref) => _BoolNotifier('pref_remove_ads', defaultValue: false),
);

class _BoolNotifier extends StateNotifier<bool> {
  final String _key;

  _BoolNotifier(this._key, {required bool defaultValue}) : super(defaultValue) {
    _load(defaultValue);
  }

  Future<void> _load(bool defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) state = prefs.getBool(_key) ?? defaultValue;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vibration = ref.watch(vibrationProvider);
    final sound = ref.watch(soundProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final removeAds = ref.watch(removeAdsProvider);

    final bg = AppColors.bg(context);
    final surf = AppColors.surf(context);
    final textPrim = AppColors.textPrim(context);
    final gridCol = AppColors.grid(context);
    final toggleOff = AppColors.toggleOff(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: textPrim)),
        backgroundColor: bg,
        foregroundColor: textPrim,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrim),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // ── Preferences ────────────────────────────────────────────────
            _SectionCard(
              color: surf,
              children: [
                _ToggleRow(
                  icon: Icons.vibration_rounded,
                  label: 'Vibrations',
                  value: vibration,
                  iconColor: textPrim,
                  labelColor: textPrim,
                  toggleOff: toggleOff,
                  onToggle: () => ref.read(vibrationProvider.notifier).toggle(),
                ),
                _Divider(color: gridCol),
                _ToggleRow(
                  icon: Icons.volume_up_rounded,
                  label: 'Sounds',
                  value: sound,
                  iconColor: textPrim,
                  labelColor: textPrim,
                  toggleOff: toggleOff,
                  onToggle: () => ref.read(soundProvider.notifier).toggle(),
                ),
                _Divider(color: gridCol),
                _ToggleRow(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark mode',
                  value: isDark,
                  iconColor: textPrim,
                  labelColor: textPrim,
                  toggleOff: toggleOff,
                  onToggle: () => ref.read(themeProvider.notifier).toggle(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Purchases ──────────────────────────────────────────────────
            _SectionCard(
              color: surf,
              children: [
                _ToggleRow(
                  icon: Icons.block_rounded,
                  label: 'Remove Ads',
                  value: removeAds,
                  iconColor: textPrim,
                  labelColor: textPrim,
                  toggleOff: toggleOff,
                  onToggle: () => ref.read(removeAdsProvider.notifier).toggle(),
                ),
                _Divider(color: gridCol),
                _TapRow(
                  icon: Icons.refresh_rounded,
                  label: 'Restore purchases',
                  iconColor: textPrim,
                  labelColor: textPrim,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No purchases to restore.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Feedback ───────────────────────────────────────────────────
            _SectionCard(
              color: surf,
              children: [
                _TapRow(
                  icon: Icons.star_rounded,
                  label: 'Rate us',
                  iconColor: textPrim,
                  labelColor: textPrim,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Legal ──────────────────────────────────────────────────────
            _SectionCard(
              color: surf,
              children: [
                _TapRow(
                  icon: Icons.description_rounded,
                  label: 'Privacy',
                  iconColor: textPrim,
                  labelColor: textPrim,
                  onTap: () {},
                ),
                _Divider(color: gridCol),
                _TapRow(
                  icon: Icons.info_rounded,
                  label: 'Terms of Service',
                  iconColor: textPrim,
                  labelColor: textPrim,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable components
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  final Color color;

  const _SectionCard({required this.children, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: color,
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final Color iconColor;
  final Color labelColor;
  final Color toggleOff;
  final VoidCallback onToggle;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.labelColor,
    required this.toggleOff,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: (_) => onToggle(),
              activeColor: Colors.white,
              activeTrackColor: AppColors.accent,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: toggleOff,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}

class _TapRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color labelColor;
  final VoidCallback onTap;

  const _TapRow({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
