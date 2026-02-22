/// 앱 전체에서 사용하는 문자열 상수
class AppStrings {
  AppStrings._();

  // ── App ──────────────────────────────────────
  static const String appName = 'PARA';
  static const String appSubtitle = 'Management System';
  static const String appTagline = '생각을 정리하고, 행동을 이끌어내는 두 번째 뇌';

  // ── Navigation ───────────────────────────────
  static const String dashboard = '대시보드';
  static const String projects = '프로젝트';
  static const String areas = '영역';
  static const String resources = '자료';
  static const String archive = '보관함';
  static const String inbox = '인박스';
  static const String settings = '설정';
  static const String search = '검색...';

  // ── Actions ──────────────────────────────────
  static const String create = '생성';
  static const String edit = '수정';
  static const String delete = '삭제';
  static const String save = '저장';
  static const String cancel = '취소';
  static const String confirm = '확인';
  static const String moveToArchive = '보관함으로 이동';
  static const String restore = '복원';

  // ── Project Status ───────────────────────────
  static const String statusActive = '진행중';
  static const String statusOnHold = '대기중';
  static const String statusCompleted = '완료';
  static const String statusArchived = '보관됨';

  // ── Empty States ─────────────────────────────
  static const String noProjects = '아직 프로젝트가 없습니다';
  static const String noAreas = '아직 영역이 없습니다';
  static const String noResources = '아직 자료가 없습니다';
  static const String noArchive = '보관함이 비어있습니다';
  static const String noInbox = '인박스가 비어있습니다';
  static const String noSearchResults = '검색 결과가 없습니다';

  // ── Dialog ───────────────────────────────────
  static const String deleteConfirmTitle = '정말 삭제하시겠습니까?';
  static const String deleteConfirmMessage = '이 작업은 되돌릴 수 없습니다.';
  static const String archiveConfirmTitle = '보관함으로 이동하시겠습니까?';
}
