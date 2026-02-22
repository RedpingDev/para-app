import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/models.dart';

// ─────────────────────────────────────────
// DB 싱글턴 프로바이더
// ─────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ─────────────────────────────────────────
// Repository 프로바이더
// ─────────────────────────────────────────

final paraRepositoryProvider = Provider<ParaRepository>((ref) {
  return ParaRepository(ref.read(appDatabaseProvider));
});

// ─────────────────────────────────────────
// Repository 클래스
// ─────────────────────────────────────────

class ParaRepository {
  final AppDatabase _db;
  ParaRepository(this._db);

  // ── Projects ──────────────────────────

  Future<List<Project>> getAllProjects() async {
    final projectRows = await _db.getAllProjects();
    final List<Project> result = [];
    for (final row in projectRows) {
      final taskRows = await _db.getTasksByProject(row.id);
      final tagRows = await _db.getTagsByProject(row.id);
      result.add(_toProject(row, taskRows, tagRows));
    }
    return result;
  }

  Future<void> saveProject(Project project) async {
    await _db.upsertProject(ProjectsCompanion.insert(
      id: project.id,
      title: project.title,
      description: Value(project.description),
      status: Value(project.status.name),
      areaId: Value(project.areaId),
      startDate: Value(project.startDate),
      dueDate: Value(project.dueDate),
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      archivedAt: Value(project.archivedAt),
    ));
    // Tasks: 삭제 후 재삽입
    await _db.deleteTasksByProject(project.id);
    for (final task in project.tasks) {
      await _db.upsertTask(TasksCompanion.insert(
        id: task.id,
        projectId: project.id,
        title: task.title,
        isCompleted: Value(task.isCompleted),
        orderIndex: Value(task.orderIndex),
        createdAt: task.createdAt,
      ));
    }
    // Tags: 삭제 후 재삽입
    await _db.deleteProjectTags(project.id);
    for (final tag in project.tags) {
      await _db.upsertTag(TagsCompanion.insert(
        id: tag.id,
        name: tag.name,
        colorValue: Value(tag.colorValue),
        createdAt: tag.createdAt,
      ));
      await _db.upsertProjectTag(ProjectTagsCompanion.insert(
        projectId: project.id,
        tagId: tag.id,
      ));
    }
  }

  Future<void> deleteProject(String id) async {
    await _db.deleteTasksByProject(id);
    await _db.deleteProjectTags(id);
    await _db.deleteProject(id);
  }

  // ── Areas ─────────────────────────────

  Future<List<Area>> getAllAreas() async {
    final rows = await _db.getAllAreas();
    return rows.map(_toArea).toList();
  }

  Future<void> saveArea(Area area) async {
    await _db.upsertArea(AreasCompanion.insert(
      id: area.id,
      title: area.title,
      description: Value(area.description),
      iconCodePoint: Value(area.icon.codePoint),
      standard: Value(area.standard),
      createdAt: area.createdAt,
      updatedAt: area.updatedAt,
      archivedAt: Value(area.archivedAt),
    ));
  }

  Future<void> deleteArea(String id) => _db.deleteArea(id);

  // ── Resources ─────────────────────────

  Future<List<Resource>> getAllResources() async {
    final rows = await _db.getAllResources();
    final List<Resource> result = [];
    for (final row in rows) {
      final tagRows = await _db.getTagsByResource(row.id);
      result.add(_toResource(row, tagRows));
    }
    return result;
  }

  Future<void> saveResource(Resource resource) async {
    await _db.upsertResource(ResourcesCompanion.insert(
      id: resource.id,
      title: resource.title,
      content: Value(resource.content),
      url: Value(resource.url),
      createdAt: resource.createdAt,
      updatedAt: resource.updatedAt,
      archivedAt: Value(resource.archivedAt),
    ));
    await _db.deleteResourceTags(resource.id);
    for (final tag in resource.tags) {
      await _db.upsertTag(TagsCompanion.insert(
        id: tag.id,
        name: tag.name,
        colorValue: Value(tag.colorValue),
        createdAt: tag.createdAt,
      ));
      await _db.upsertResourceTag(ResourceTagsCompanion.insert(
        resourceId: resource.id,
        tagId: tag.id,
      ));
    }
  }

  Future<void> deleteResource(String id) async {
    await _db.deleteResourceTags(id);
    await _db.deleteResource(id);
  }

  // ── Inbox ─────────────────────────────

  Future<List<InboxItem>> getAllInboxItems() async {
    final rows = await _db.getAllInboxItems();
    return rows.map(_toInboxItem).toList();
  }

  Future<void> saveInboxItem(InboxItem item) async {
    await _db.upsertInboxItem(InboxItemsCompanion.insert(
      id: item.id,
      content: item.content,
      createdAt: item.createdAt,
      assignedType: Value(item.assignedType?.name),
    ));
  }

  Future<void> deleteInboxItem(String id) => _db.deleteInboxItem(id);

  // ─────────────────────────────────────
  // Row → Model 변환
  // ─────────────────────────────────────

  Project _toProject(
      ProjectRow row, List<TaskRow> taskRows, List<TagRow> tagRows) {
    return Project(
      id: row.id,
      title: row.title,
      description: row.description,
      status: ProjectStatus.values.firstWhere(
        (s) => s.name == row.status,
        orElse: () => ProjectStatus.active,
      ),
      areaId: row.areaId,
      startDate: row.startDate,
      dueDate: row.dueDate,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
      tasks: taskRows.map(_toTask).toList(),
      tags: tagRows.map(_toTag).toList(),
    );
  }

  Task _toTask(TaskRow row) => Task(
        id: row.id,
        projectId: row.projectId,
        title: row.title,
        isCompleted: row.isCompleted,
        orderIndex: row.orderIndex,
        createdAt: row.createdAt,
      );

  Area _toArea(AreaRow row) => Area(
        id: row.id,
        title: row.title,
        description: row.description,
        icon: IconData(row.iconCodePoint, fontFamily: 'MaterialIcons'),
        standard: row.standard,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        archivedAt: row.archivedAt,
      );

  Resource _toResource(ResourceRow row, List<TagRow> tagRows) => Resource(
        id: row.id,
        title: row.title,
        content: row.content,
        url: row.url,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        archivedAt: row.archivedAt,
        tags: tagRows.map(_toTag).toList(),
      );

  Tag _toTag(TagRow row) => Tag(
        id: row.id,
        name: row.name,
        colorValue: row.colorValue,
        createdAt: row.createdAt,
      );

  InboxItem _toInboxItem(InboxRow row) => InboxItem(
        id: row.id,
        content: row.content,
        createdAt: row.createdAt,
        assignedType: row.assignedType != null
            ? ParaType.values.firstWhere(
                (t) => t.name == row.assignedType,
                orElse: () => ParaType.project,
              )
            : null,
      );
}
