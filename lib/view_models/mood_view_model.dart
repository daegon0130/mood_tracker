import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_model.dart';
import '../repositories/mood_repository.dart';
import 'auth_view_model.dart';

// Mood 리스트 상태를 관리하는 State 클래스
class MoodListState {
  final List<MoodModel> moods;
  final bool isLoading;
  final String? error;

  const MoodListState({
    this.moods = const [],
    this.isLoading = false,
    this.error,
  });

  MoodListState copyWith({
    List<MoodModel>? moods,
    bool? isLoading,
    String? error,
  }) {
    return MoodListState(
      moods: moods ?? this.moods,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Mood 생성 상태를 관리하는 State 클래스
class MoodCreationState {
  final bool isLoading;
  final String? error;
  final String selectedMood;
  final String description;
  final bool isSuccess;

  const MoodCreationState({
    this.isLoading = false,
    this.error,
    this.selectedMood = '😊',
    this.description = '',
    this.isSuccess = false,
  });

  MoodCreationState copyWith({
    bool? isLoading,
    String? error,
    String? selectedMood,
    String? description,
    bool? isSuccess,
  }) {
    return MoodCreationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedMood: selectedMood ?? this.selectedMood,
      description: description ?? this.description,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Mood 리스트를 관리하는 ViewModel
class MoodListViewModel extends StateNotifier<MoodListState> {
  final MoodRepository _moodRepository;
  final String _userId;

  MoodListViewModel(
    this._moodRepository,
    this._userId,
  ) : super(const MoodListState()) {
    _loadMoods();
  }

  // Mood 리스트 로드
  void _loadMoods() {
    state = state.copyWith(isLoading: true, error: null);

    _moodRepository.getUserMoodEntriesStream(_userId).listen(
      (moods) {
        state = state.copyWith(
          moods: moods,
          isLoading: false,
          error: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }

  // Mood 삭제
  Future<bool> deleteMood(String moodId) async {
    try {
      await _moodRepository.deleteMoodEntry(moodId);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

// Mood 생성을 관리하는 ViewModel
class MoodCreationViewModel extends StateNotifier<MoodCreationState> {
  final MoodRepository _moodRepository;
  final String _userId;

  MoodCreationViewModel(
    this._moodRepository,
    this._userId,
  ) : super(const MoodCreationState());

  // 선택된 기분 변경
  void selectMood(String mood) {
    state = state.copyWith(selectedMood: mood);
  }

  // 설명 변경
  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  // Mood 생성
  Future<bool> createMood() async {
    if (state.description.trim().isEmpty) {
      state = state.copyWith();
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _moodRepository.createMoodEntry(
        userId: _userId,
        mood: state.selectedMood,
        description: state.description.trim(),
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        description: '', // 성공 후 초기화
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

// 현재 사용자의 MoodListViewModel Provider
final currentUserMoodListProvider =
    StateNotifierProvider<MoodListViewModel, MoodListState>((ref) {
  final userId = ref.watch(authViewModelProvider).user?.uid;
  if (userId == null) {
    // 로그인되지 않은 상태에서는 빈 상태 반환
    return MoodListViewModel(ref.read(moodProvider), '');
  }
  return MoodListViewModel(ref.read(moodProvider), userId);
});

// 현재 사용자의 MoodCreationViewModel Provider
final currentUserMoodCreationProvider =
    StateNotifierProvider<MoodCreationViewModel, MoodCreationState>((ref) {
  final userId = ref.watch(authViewModelProvider).user?.uid;
  if (userId == null) {
    // 로그인되지 않은 상태에서는 빈 상태 반환
    return MoodCreationViewModel(ref.read(moodProvider), '');
  }
  return MoodCreationViewModel(ref.read(moodProvider), userId);
});

// Stream Provider로 실시간 무드 데이터 제공
final userMoodEntriesStreamProvider =
    StreamProvider.autoDispose<List<MoodModel>>((ref) {
  final userId = ref.watch(authViewModelProvider).user?.uid;

  if (userId == null) {
    return Stream.value(<MoodModel>[]);
  }

  return ref.read(moodProvider).getUserMoodEntriesStream(userId);
});

// Mood 삭제 상태를 관리하는 Provider
final moodDeletionProvider = StateProvider<String?>((ref) => null);
