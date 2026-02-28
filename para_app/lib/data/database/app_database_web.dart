// 웹 플랫폼용 AppDatabase 스텁
// 웹에서는 Drift/SQLite 대신 Firestore를 사용하므로 빈 구현

class AppDatabase {
  Future<void> close() async {}
}
