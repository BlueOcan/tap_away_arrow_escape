import 'package:shared_preferences/shared_preferences.dart';

class ProgressRepository {
  static const _key = 'max_unlocked_level';

  Future<int> getMaxUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 1;
  }

  Future<void> unlockLevel(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key) ?? 1;
    if (levelId > current) {
      await prefs.setInt(_key, levelId);
    }
  }
}
