import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────
// Auth 상태 스트림 프로바이더
// ─────────────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).asData?.value;
});

// ─────────────────────────────────────────
// AuthService
// ─────────────────────────────────────────

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
        // 웹/윈도우: 팝업으로 구글 로그인
        return await _auth.signInWithPopup(provider);
      } else {
        // Android: 리다이렉트 방식
        await _auth.signInWithRedirect(provider);
        return await _auth.getRedirectResult();
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
