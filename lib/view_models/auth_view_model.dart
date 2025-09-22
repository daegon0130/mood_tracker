import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mood_repository.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isSignedIn;
  final User? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isSignedIn = false,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isSignedIn,
    User? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      user: user ?? this.user,
    );
  }
}

// 인증 관련 비즈니스 로직을 처리하는 ViewModel
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final MoodRepository _moodRepository;

  AuthViewModel(
    this._authRepository,
    this._moodRepository,
  ) : super(const AuthState()) {
    // 인증 상태 변화 감지
    _authRepository.authStateChanges.listen((user) {
      state = state.copyWith(
        isSignedIn: user != null,
        user: user,
        isLoading: false,
      );
    });
  }

  // 회원가입
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Firebase Auth에 사용자 생성
      final userCredential = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential?.user != null) {
        // 2. 사용자 이름 업데이트
        await _authRepository.updateDisplayName(name);

        // 3. 환영 무드 엔트리 생성
        await _moodRepository.createWelcomeMoodEntry(
          userCredential!.user!.uid,
        );

        state = state.copyWith(
          isLoading: false,
          isSignedIn: true,
          user: userCredential.user,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // 로그인
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userCredential = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential?.user != null) {
        state = state.copyWith(
          isLoading: false,
          isSignedIn: true,
          user: userCredential!.user,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.signOut();
      state = state.copyWith(
        isLoading: false,
        isSignedIn: false,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

// AuthViewModel Provider
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    ref.read(authProvider),
    ref.read(moodProvider),
  );
});
