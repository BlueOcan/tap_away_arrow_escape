import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/progress_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>(
  (_) => ProgressRepository(),
);

final maxUnlockedLevelProvider = FutureProvider<int>((ref) async {
  return ref.read(progressRepositoryProvider).getMaxUnlockedLevel();
});

class ProgressNotifier extends StateNotifier<int> {
  final ProgressRepository _repo;

  ProgressNotifier(this._repo, int initial) : super(initial);

  /// Safely seeds the initial maximum unlocked level fetched from disk
  /// without throwing protected/visibleForTesting member mutation errors.
  void initMaxUnlocked(int levelId) {
    state = levelId;
  }

  Future<void> completeLevel(int levelId) async {
    await _repo.unlockLevel(levelId + 1);
    if (levelId + 1 > state) {
      state = levelId + 1;
    }
  }
}

final progressNotifierProvider = StateNotifierProvider<ProgressNotifier, int>((
  ref,
) {
  // Start at 1; will be updated after async load
  final repo = ref.read(progressRepositoryProvider);
  return ProgressNotifier(repo, 1);
});
