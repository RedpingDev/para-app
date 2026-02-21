import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ─────────────────────────────────────────
// Table 정의
// ─────────────────────────────────────────

@DataClassName('ProjectRow')
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get areaId => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get title => text()();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AreaRow')
class Areas extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  // IconData.codePoint (int) 으로 저장
  IntColumn get iconCodePoint =>
      integer().withDefault(const Constant(0xe88a))();
  TextColumn get standard => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ResourceRow')
class Resources extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  TextColumn get url => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get colorValue =>
      integer().withDefault(const Constant(0xFF6C5CE7))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProjectTagRow')
class ProjectTags extends Table {
  TextColumn get projectId => text()();
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {projectId, tagId};
}

@DataClassName('ResourceTagRow')
class ResourceTags extends Table {
  TextColumn get resourceId => text()();
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {resourceId, tagId};
}

@DataClassName('InboxRow')
class InboxItems extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get assignedType => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────
// Database 클래스
// ─────────────────────────────────────────

@DriftDatabase(
  tables: [
    Projects,
    Tasks,
    Areas,
    Resources,
    Tags,
    ProjectTags,
    ResourceTags,
    InboxItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── Projects ──────────────────────────
  Future<List<ProjectRow>> getAllProjects() => select(projects).get();

  Future<List<TaskRow>> getTasksByProject(String projectId) =>
      (select(tasks)..where((t) => t.projectId.equals(projectId))).get();

  Future<List<TagRow>> getTagsByProject(String projectId) async {
    final ptRows = await (select(projectTags)
          ..where((pt) => pt.projectId.equals(projectId)))
        .get();
    if (ptRows.isEmpty) return [];
    final ids = ptRows.map((pt) => pt.tagId).toList();
    return (select(tags)..where((t) => t.id.isIn(ids))).get();
  }

  Future<void> upsertProject(ProjectsCompanion companion) =>
      into(projects).insertOnConflictUpdate(companion);

  Future<void> upsertTask(TasksCompanion companion) =>
      into(tasks).insertOnConflictUpdate(companion);

  Future<void> upsertTag(TagsCompanion companion) =>
      into(tags).insertOnConflictUpdate(companion);

  Future<void> upsertProjectTag(ProjectTagsCompanion companion) =>
      into(projectTags).insertOnConflictUpdate(companion);

  Future<void> deleteProject(String id) =>
      (delete(projects)..where((p) => p.id.equals(id))).go();

  Future<void> deleteTasksByProject(String projectId) =>
      (delete(tasks)..where((t) => t.projectId.equals(projectId))).go();

  Future<void> deleteProjectTags(String projectId) =>
      (delete(projectTags)..where((pt) => pt.projectId.equals(projectId)))
          .go();

  // ── Areas ─────────────────────────────
  Future<List<AreaRow>> getAllAreas() => select(areas).get();

  Future<void> upsertArea(AreasCompanion companion) =>
      into(areas).insertOnConflictUpdate(companion);

  Future<void> deleteArea(String id) =>
      (delete(areas)..where((a) => a.id.equals(id))).go();

  // ── Resources ─────────────────────────
  Future<List<ResourceRow>> getAllResources() => select(resources).get();

  Future<List<TagRow>> getTagsByResource(String resourceId) async {
    final rtRows = await (select(resourceTags)
          ..where((rt) => rt.resourceId.equals(resourceId)))
        .get();
    if (rtRows.isEmpty) return [];
    final ids = rtRows.map((rt) => rt.tagId).toList();
    return (select(tags)..where((t) => t.id.isIn(ids))).get();
  }

  Future<void> upsertResource(ResourcesCompanion companion) =>
      into(resources).insertOnConflictUpdate(companion);

  Future<void> upsertResourceTag(ResourceTagsCompanion companion) =>
      into(resourceTags).insertOnConflict
          .update(companion);

  Future<void> deleteResource(String id) =>
      (delete(resources)..where((r) => r.id.equals(id))).go();

  Future<void> deleteResourceTags(String resourceId) =>
      (delete(resourceTags)
            ..where((rt) => rt.resourceId.equals(resourceId)))
          .go();

  // ── Inbox ─────────────────────────────
  Future<List<InboxRow>> getAllInboxItems() =>
      (select(inboxItems)
            ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]))
          .get();

  Future<void> upsertInboxItem(InboxItemsCompanion companion) =>
      into(inboxItems).insertOnConflictUpdate(companion);

  Future<void> deleteInboxItem(String id) =>
      (delete(inboxItems)..where((i) => i.id.equals(id))).go();
}

// ─────────────────────────────────────────
// DB 연결 함수
// ─────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'para_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
