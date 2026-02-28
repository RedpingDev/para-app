import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart'
    if (dart.library.html) '../database/app_database_web.dart';
import 'firestore_repository.dart';
import '../../services/auth_service.dart';

// ─────────────────────────────────────────
// DB 싱글턴 프로바이더 (Windows 로컬용, 보존)
// ─────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ─────────────────────────────────────────
// Repository 프로바이더 (Firestore 기반)
// ─────────────────────────────────────────

final paraRepositoryProvider = Provider<FirestoreRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return FirestoreRepository(user.uid);
});
