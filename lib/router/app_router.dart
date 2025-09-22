import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/firebase_providers.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/post/post_screen.dart';
import '../screens/splash/splash_screen.dart';

// Router configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authAsync = authState;
      final isSplash = state.matchedLocation == '/splash';
      final isAuth = state.matchedLocation.startsWith('/auth');

      return authAsync.when(
        // 로딩 중일 때 - 한정된 시간만 대기
        loading: () {
          // 스플래시 화면에서만 로딩 허용, 다른 곳에서는 즉시 로그인으로
          if (isSplash) {
            return null; // 스플래시 화면 유지 (타임아웃으로 처리됨)
          }
          return '/auth/login';
        },
        // 에러 발생 시
        error: (error, stack) {
          // 에러 발생 시 항상 로그인 화면으로
          if (isAuth) {
            return null; // 이미 인증 화면에 있으면 유지
          }
          return '/auth/login';
        },
        // 데이터 로드 완료 시
        data: (user) {
          final isLoggedIn = user != null;

          // 로그인되지 않았고 인증 화면이 아니라면 로그인으로 이동
          if (!isLoggedIn && !isAuth) {
            return '/auth/login';
          }

          // 로그인되었고 스플래시나 인증 화면에 있다면 홈으로 이동
          if (isLoggedIn && (isAuth || isSplash)) {
            print('로그인됨, 홈 화면으로 이동');
            return '/home';
          }

          print('현재 위치 유지');
          return null; // 리디렉션 불필요
        },
      );
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/auth',
        redirect: (context, state) => '/auth/login',
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/post',
        name: 'post',
        builder: (context, state) => const PostScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.matchedLocation}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
