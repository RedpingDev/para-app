import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models/models.dart';
import '../data/repositories/para_repository.dart';

export '../data/repositories/para_repository.dart'
    show appDatabaseProvider, paraRepositoryProvider;

const _uuid = Uuid();

/// 테마 모드 프로바이더 (true = dark)
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, bool>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void set(bool isDark) => state = isDark;
}

/// ─────────────────────────────────────────
/// Projects Provider
/// ─────────────────────────────────────────
final projectsProvider =
    NotifierProvider<ProjectsNotifier, List<Project>>(ProjectsNotifier.new);

class ProjectsNotifier extends Notifier<List<Project>> {
  @override
  List<Project> build() {
    Future.microtask(_init);
    return [];
  }

  ParaRepository get _repo => ref.read(paraRepositoryProvider);

  Future<void> _init() async {
    var list = await _repo.getAllProjects();
    if (list.isEmpty) {
      for (final p in _sampleProjects) {
        await _repo.saveProject(p);
      }
      list = _sampleProjects;
    }
    state = list;
  }

  Future<void> add(Project project) async {
    await _repo.saveProject(project);
    state = [...state, project];
  }

  Future<void> update(Project project) async {
    await _repo.saveProject(project);
    state = [for (final p in state) if (p.id == project.id) project else p];
  }

  Future<void> remove(String id) async {
    await _repo.deleteProject(id);
    state = state.where((p) => p.id != id).toList();
  }

  Future<void> archive(String id) async {
    final now = DateTime.now();
    state = [
      for (final p in state)
        if (p.id == id)
          Project(
            id: p.id, title: p.title, description: p.description,
            status: ProjectStatus.archived, areaId: p.areaId,
            startDate: p.startDate, dueDate: p.dueDate,
            createdAt: p.createdAt, updatedAt: now, archivedAt: now,
            tasks: p.tasks, tags: p.tags,
          )
        else
          p,
    ];
    await _repo.saveProject(state.firstWhere((p) => p.id == id));
  }

  Future<void> restore(String id) async {
    final now = DateTime.now();
    state = [
      for (final p in state)
        if (p.id == id)
          Project(
            id: p.id, title: p.title, description: p.description,
            status: ProjectStatus.active, areaId: p.areaId,
            startDate: p.startDate, dueDate: p.dueDate,
            createdAt: p.createdAt, updatedAt: now, archivedAt: null,
            tasks: p.tasks, tags: p.tags,
          )
        else
          p,
    ];
    await _repo.saveProject(state.firstWhere((p) => p.id == id));
  }

  Future<void> toggleTask(String projectId, String taskId) async {
    state = [
      for (final p in state)
        if (p.id == projectId)
          p.copyWith(
            tasks: [
              for (final t in p.tasks)
                if (t.id == taskId)
                  t.copyWith(isCompleted: !t.isCompleted)
                else
                  t,
            ],
            updatedAt: DateTime.now(),
          )
        else
          p,
    ];
    await _repo.saveProject(state.firstWhere((p) => p.id == projectId));
  }

  Future<void> addTask(String projectId, String title) async {
    state = [
      for (final p in state)
        if (p.id == projectId)
          p.copyWith(
            tasks: [
              ...p.tasks,
              Task(
                id: _uuid.v4(), projectId: projectId, title: title,
                orderIndex: p.tasks.length, createdAt: DateTime.now(),
              ),
            ],
            updatedAt: DateTime.now(),
          )
        else
          p,
    ];
    await _repo.saveProject(state.firstWhere((p) => p.id == projectId));
  }

  Future<void> removeTask(String projectId, String taskId) async {
    state = [
      for (final p in state)
        if (p.id == projectId)
          p.copyWith(
            tasks: p.tasks.where((t) => t.id != taskId).toList(),
            updatedAt: DateTime.now(),
          )
        else
          p,
    ];
    await _repo.saveProject(state.firstWhere((p) => p.id == projectId));
  }
}

/// ─────────────────────────────────────────
/// Areas Provider
/// ─────────────────────────────────────────
final areasProvider =
    NotifierProvider<AreasNotifier, List<Area>>(AreasNotifier.new);

class AreasNotifier extends Notifier<List<Area>> {
  @override
  List<Area> build() {
    Future.microtask(_init);
    return [];
  }

  ParaRepository get _repo => ref.read(paraRepositoryProvider);

  Future<void> _init() async {
    var list = await _repo.getAllAreas();
    if (list.isEmpty) {
      for (final a in _sampleAreas) {
        await _repo.saveArea(a);
      }
      list = _sampleAreas;
    }
    state = list;
  }

  Future<void> add(Area area) async {
    await _repo.saveArea(area);
    state = [...state, area];
  }

  Future<void> update(Area area) async {
    await _repo.saveArea(area);
    state = [for (final a in state) if (a.id == area.id) area else a];
  }

  Future<void> remove(String id) async {
    await _repo.deleteArea(id);
    state = state.where((a) => a.id != id).toList();
  }

  Future<void> archive(String id) async {
    final now = DateTime.now();
    state = [
      for (final a in state)
        if (a.id == id)
          Area(
            id: a.id, title: a.title, description: a.description,
            icon: a.icon, standard: a.standard,
            createdAt: a.createdAt, updatedAt: now, archivedAt: now,
            tags: a.tags,
          )
        else
          a,
    ];
    await _repo.saveArea(state.firstWhere((a) => a.id == id));
  }

  Future<void> restore(String id) async {
    final now = DateTime.now();
    state = [
      for (final a in state)
        if (a.id == id)
          Area(
            id: a.id, title: a.title, description: a.description,
            icon: a.icon, standard: a.standard,
            createdAt: a.createdAt, updatedAt: now, archivedAt: null,
            tags: a.tags,
          )
        else
          a,
    ];
    await _repo.saveArea(state.firstWhere((a) => a.id == id));
  }
}

/// ─────────────────────────────────────────
/// Resources Provider
/// ─────────────────────────────────────────
final resourcesProvider =
    NotifierProvider<ResourcesNotifier, List<Resource>>(ResourcesNotifier.new);

class ResourcesNotifier extends Notifier<List<Resource>> {
  @override
  List<Resource> build() {
    Future.microtask(_init);
    return [];
  }

  ParaRepository get _repo => ref.read(paraRepositoryProvider);

  Future<void> _init() async {
    var list = await _repo.getAllResources();
    if (list.isEmpty) {
      for (final r in _sampleResources) {
        await _repo.saveResource(r);
      }
      list = _sampleResources;
    }
    state = list;
  }

  Future<void> add(Resource resource) async {
    await _repo.saveResource(resource);
    state = [...state, resource];
  }

  Future<void> update(Resource resource) async {
    await _repo.saveResource(resource);
    state = [for (final r in state) if (r.id == resource.id) resource else r];
  }

  Future<void> remove(String id) async {
    await _repo.deleteResource(id);
    state = state.where((r) => r.id != id).toList();
  }

  Future<void> archive(String id) async {
    final now = DateTime.now();
    state = [
      for (final r in state)
        if (r.id == id)
          Resource(
            id: r.id, title: r.title, content: r.content, url: r.url,
            createdAt: r.createdAt, updatedAt: now, archivedAt: now,
            tags: r.tags,
          )
        else
          r,
    ];
    await _repo.saveResource(state.firstWhere((r) => r.id == id));
  }

  Future<void> restore(String id) async {
    final now = DateTime.now();
    state = [
      for (final r in state)
        if (r.id == id)
          Resource(
            id: r.id, title: r.title, content: r.content, url: r.url,
            createdAt: r.createdAt, updatedAt: now, archivedAt: null,
            tags: r.tags,
          )
        else
          r,
    ];
    await _repo.saveResource(state.firstWhere((r) => r.id == id));
  }
}

/// ─────────────────────────────────────────
/// Inbox Provider
/// ─────────────────────────────────────────
final inboxProvider =
    NotifierProvider<InboxNotifier, List<InboxItem>>(InboxNotifier.new);

class InboxNotifier extends Notifier<List<InboxItem>> {
  @override
  List<InboxItem> build() {
    Future.microtask(_init);
    return [];
  }

  ParaRepository get _repo => ref.read(paraRepositoryProvider);

  Future<void> _init() async {
    state = await _repo.getAllInboxItems();
  }

  Future<void> add(String content) async {
    final item = InboxItem(
      id: _uuid.v4(),
      content: content,
      createdAt: DateTime.now(),
    );
    await _repo.saveInboxItem(item);
    state = [item, ...state];
  }

  Future<void> remove(String id) async {
    await _repo.deleteInboxItem(id);
    state = state.where((item) => item.id != id).toList();
  }
}

/// ─────────────────────────────────────────
/// Derived Providers
/// ─────────────────────────────────────────

final activeProjectsProvider = Provider<List<Project>>((ref) {
  return ref
      .watch(projectsProvider)
      .where((p) => p.status != ProjectStatus.archived)
      .toList();
});

final archivedProjectsProvider = Provider<List<Project>>((ref) {
  return ref
      .watch(projectsProvider)
      .where((p) => p.status == ProjectStatus.archived)
      .toList();
});

final activeAreasProvider = Provider<List<Area>>((ref) {
  return ref.watch(areasProvider).where((a) => a.archivedAt == null).toList();
});

final archivedAreasProvider = Provider<List<Area>>((ref) {
  return ref.watch(areasProvider).where((a) => a.archivedAt != null).toList();
});

final activeResourcesProvider = Provider<List<Resource>>((ref) {
  return ref
      .watch(resourcesProvider)
      .where((r) => r.archivedAt == null)
      .toList();
});

final archivedResourcesProvider = Provider<List<Resource>>((ref) {
  return ref
      .watch(resourcesProvider)
      .where((r) => r.archivedAt != null)
      .toList();
});

final urgentProjectsProvider = Provider<List<Project>>((ref) {
  return ref.watch(activeProjectsProvider).where((p) => p.isUrgent).toList();
});

final overdueProjectsProvider = Provider<List<Project>>((ref) {
  return ref.watch(activeProjectsProvider).where((p) => p.isOverdue).toList();
});

/// ─────────────────────────────────────────
/// 샘플 데이터 (최초 1회만 DB에 씨딩)
/// ─────────────────────────────────────────

final _sampleProjects = [
  Project(
    id: _uuid.v4(),
    title: 'PARA 앱 개발',
    description: 'Flutter로 PARA Management System을 개발합니다.',
    status: ProjectStatus.active,
    startDate: DateTime(2026, 2, 18),
    dueDate: DateTime(2026, 3, 15),
    createdAt: DateTime(2026, 2, 18),
    updatedAt: DateTime(2026, 2, 18),
    tasks: [
      Task(id: _uuid.v4(), projectId: '', title: '프로젝트 셋업', isCompleted: true, orderIndex: 0, createdAt: DateTime(2026, 2, 18)),
      Task(id: _uuid.v4(), projectId: '', title: '테마 시스템 구축', isCompleted: true, orderIndex: 1, createdAt: DateTime(2026, 2, 18)),
      Task(id: _uuid.v4(), projectId: '', title: '데이터 모델 정의', isCompleted: false, orderIndex: 2, createdAt: DateTime(2026, 2, 18)),
      Task(id: _uuid.v4(), projectId: '', title: '핵심 CRUD 구현', isCompleted: false, orderIndex: 3, createdAt: DateTime(2026, 2, 18)),
    ],
    tags: [
      Tag(id: _uuid.v4(), name: 'Flutter', colorValue: 0xFF0984E3, createdAt: DateTime.now()),
      Tag(id: _uuid.v4(), name: '개인 프로젝트', colorValue: 0xFF00B894, createdAt: DateTime.now()),
    ],
  ),
  Project(
    id: _uuid.v4(),
    title: '블로그 포스트 작성',
    description: 'PARA 시스템 활용법에 대한 블로그 글을 작성합니다.',
    status: ProjectStatus.active,
    dueDate: DateTime.now().add(const Duration(days: 7)),
    createdAt: DateTime(2026, 2, 15),
    updatedAt: DateTime(2026, 2, 18),
    tasks: [
      Task(id: _uuid.v4(), projectId: '', title: '개요 작성', isCompleted: true, orderIndex: 0, createdAt: DateTime.now()),
      Task(id: _uuid.v4(), projectId: '', title: '본문 작성', isCompleted: false, orderIndex: 1, createdAt: DateTime.now()),
      Task(id: _uuid.v4(), projectId: '', title: '리뷰 & 퍼블리시', isCompleted: false, orderIndex: 2, createdAt: DateTime.now()),
    ],
  ),
  Project(
    id: _uuid.v4(),
    title: '포트폴리오 리뉴얼',
    description: '개인 포트폴리오 웹사이트를 업데이트합니다.',
    status: ProjectStatus.onHold,
    createdAt: DateTime(2026, 1, 10),
    updatedAt: DateTime(2026, 2, 1),
    tasks: [
      Task(id: _uuid.v4(), projectId: '', title: '디자인 시안', isCompleted: true, orderIndex: 0, createdAt: DateTime.now()),
      Task(id: _uuid.v4(), projectId: '', title: '개발', isCompleted: false, orderIndex: 1, createdAt: DateTime.now()),
    ],
  ),
];

final _sampleAreas = [
  Area(id: _uuid.v4(), title: '커리어 개발', description: '기술 역량 향상 및 경력 관리', icon: Icons.work_outline, standard: '매주 학습 5시간 이상', createdAt: DateTime(2026, 1, 1), updatedAt: DateTime(2026, 2, 18)),
  Area(id: _uuid.v4(), title: '건강', description: '운동, 식단, 수면 관리', icon: Icons.favorite_outline, standard: '매주 운동 3회', createdAt: DateTime(2026, 1, 1), updatedAt: DateTime(2026, 2, 18)),
  Area(id: _uuid.v4(), title: '재정 관리', description: '수입/지출 관리, 투자, 저축', icon: Icons.account_balance_wallet_outlined, standard: '매월 가계부 작성', createdAt: DateTime(2026, 1, 1), updatedAt: DateTime(2026, 2, 18)),
];

final _sampleResources = [
  Resource(
    id: _uuid.v4(), title: 'Flutter 아키텍처 패턴',
    content: '# Flutter 아키텍처 패턴\n\nMVVM, Clean Architecture, BLoC 패턴 등의 비교 정리.',
    url: 'https://docs.flutter.dev/',
    createdAt: DateTime(2026, 2, 10), updatedAt: DateTime(2026, 2, 18),
    tags: [
      Tag(id: _uuid.v4(), name: 'Flutter', colorValue: 0xFF0984E3, createdAt: DateTime.now()),
      Tag(id: _uuid.v4(), name: '아키텍처', colorValue: 0xFF6C5CE7, createdAt: DateTime.now()),
    ],
  ),
  Resource(
    id: _uuid.v4(), title: 'PARA 방법론 정리',
    content: '# PARA Method\n\nTiago Forte가 만든 디지털 정보 관리 시스템.',
    createdAt: DateTime(2026, 2, 5), updatedAt: DateTime(2026, 2, 18),
    tags: [Tag(id: _uuid.v4(), name: '생산성', colorValue: 0xFF00B894, createdAt: DateTime.now())],
  ),
];
