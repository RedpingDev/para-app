import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

/// SQLite 대신 Firestore를 사용하는 Repository.
/// 사용자별 데이터는 users/{uid}/ 하위에 저장됩니다.
class FirestoreRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  FirestoreRepository(this.uid);

  // ── 컬렉션 참조 헬퍼 ───────────────────
  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _db.collection('users/$uid/$name');

  // Firestore Timestamp → DateTime
  DateTime _dt(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return DateTime.now();
  }

  // ── Projects ──────────────────────────

  Future<List<Project>> getAllProjects() async {
    final snap = await _col('projects').get();
    final List<Project> result = [];
    for (final doc in snap.docs) {
      final tasks = await getTasksByProject(doc.id);
      final tags = await getTagsByProject(doc.id);
      result.add(_projectFromMap(doc.data(), tasks, tags));
    }
    return result;
  }

  Future<List<Task>> getTasksByProject(String projectId) async {
    final snap = await _col(
      'tasks',
    ).where('projectId', isEqualTo: projectId).get();
    final tasks = snap.docs.map((d) => _taskFromMap(d.data())).toList();
    tasks.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return tasks;
  }

  Future<List<Tag>> getTagsByProject(String projectId) async {
    final ptSnap = await _col(
      'projectTags',
    ).where('projectId', isEqualTo: projectId).get();
    if (ptSnap.docs.isEmpty) return [];
    return _fetchTagsByIds(
      ptSnap.docs.map((d) => d.data()['tagId'] as String).toList(),
    );
  }

  Future<void> saveProject(Project project) async {
    await _col('projects').doc(project.id).set({
      'id': project.id,
      'title': project.title,
      'description': project.description,
      'status': project.status.name,
      'areaId': project.areaId,
      'startDate': project.startDate != null
          ? Timestamp.fromDate(project.startDate!)
          : null,
      'dueDate': project.dueDate != null
          ? Timestamp.fromDate(project.dueDate!)
          : null,
      'createdAt': Timestamp.fromDate(project.createdAt),
      'updatedAt': Timestamp.fromDate(project.updatedAt),
      'archivedAt': project.archivedAt != null
          ? Timestamp.fromDate(project.archivedAt!)
          : null,
    });

    // Tasks: 기존 삭제 후 재저장
    final existingTasks = await _col(
      'tasks',
    ).where('projectId', isEqualTo: project.id).get();
    final batch1 = _db.batch();
    for (final doc in existingTasks.docs) {
      batch1.delete(doc.reference);
    }
    await batch1.commit();

    for (final task in project.tasks) {
      await _col('tasks').doc(task.id).set({
        'id': task.id,
        'projectId': project.id,
        'title': task.title,
        'isCompleted': task.isCompleted,
        'orderIndex': task.orderIndex,
        'createdAt': Timestamp.fromDate(task.createdAt),
      });
    }

    // Tags: 기존 삭제 후 재저장
    final existingPtags = await _col(
      'projectTags',
    ).where('projectId', isEqualTo: project.id).get();
    final batch2 = _db.batch();
    for (final doc in existingPtags.docs) {
      batch2.delete(doc.reference);
    }
    await batch2.commit();

    for (final tag in project.tags) {
      await _saveTag(tag);
      await _col('projectTags').doc('${project.id}_${tag.id}').set({
        'projectId': project.id,
        'tagId': tag.id,
      });
    }
  }

  Future<void> deleteProject(String id) async {
    final tasks = await _col('tasks').where('projectId', isEqualTo: id).get();
    final ptags = await _col(
      'projectTags',
    ).where('projectId', isEqualTo: id).get();
    final batch = _db.batch();
    for (final doc in tasks.docs) {
      batch.delete(doc.reference);
    }
    for (final doc in ptags.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_col('projects').doc(id));
    await batch.commit();
  }

  // ── Areas ─────────────────────────────

  Future<List<Area>> getAllAreas() async {
    final snap = await _col('areas').get();
    return snap.docs.map((d) => _areaFromMap(d.data())).toList();
  }

  Future<void> saveArea(Area area) async {
    await _col('areas').doc(area.id).set({
      'id': area.id,
      'title': area.title,
      'description': area.description,
      'iconCodePoint': area.icon.codePoint,
      'standard': area.standard,
      'createdAt': Timestamp.fromDate(area.createdAt),
      'updatedAt': Timestamp.fromDate(area.updatedAt),
      'archivedAt': area.archivedAt != null
          ? Timestamp.fromDate(area.archivedAt!)
          : null,
    });
  }

  Future<void> deleteArea(String id) async {
    await _col('areas').doc(id).delete();
  }

  // ── Resources ─────────────────────────

  Future<List<Resource>> getAllResources() async {
    final snap = await _col('resources').get();
    final List<Resource> result = [];
    for (final doc in snap.docs) {
      final tags = await getTagsByResource(doc.id);
      result.add(_resourceFromMap(doc.data(), tags));
    }
    return result;
  }

  Future<List<Tag>> getTagsByResource(String resourceId) async {
    final rtSnap = await _col(
      'resourceTags',
    ).where('resourceId', isEqualTo: resourceId).get();
    if (rtSnap.docs.isEmpty) return [];
    return _fetchTagsByIds(
      rtSnap.docs.map((d) => d.data()['tagId'] as String).toList(),
    );
  }

  Future<void> saveResource(Resource resource) async {
    await _col('resources').doc(resource.id).set({
      'id': resource.id,
      'title': resource.title,
      'content': resource.content,
      'url': resource.url,
      'createdAt': Timestamp.fromDate(resource.createdAt),
      'updatedAt': Timestamp.fromDate(resource.updatedAt),
      'archivedAt': resource.archivedAt != null
          ? Timestamp.fromDate(resource.archivedAt!)
          : null,
    });

    // Tags
    final existingRtags = await _col(
      'resourceTags',
    ).where('resourceId', isEqualTo: resource.id).get();
    final batch = _db.batch();
    for (final doc in existingRtags.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    for (final tag in resource.tags) {
      await _saveTag(tag);
      await _col('resourceTags').doc('${resource.id}_${tag.id}').set({
        'resourceId': resource.id,
        'tagId': tag.id,
      });
    }
  }

  Future<void> deleteResource(String id) async {
    final rtags = await _col(
      'resourceTags',
    ).where('resourceId', isEqualTo: id).get();
    final batch = _db.batch();
    for (final doc in rtags.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_col('resources').doc(id));
    await batch.commit();
  }

  // ── Inbox ─────────────────────────────

  Future<List<InboxItem>> getAllInboxItems() async {
    final snap = await _col(
      'inbox',
    ).orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => _inboxFromMap(d.data())).toList();
  }

  Future<void> saveInboxItem(InboxItem item) async {
    await _col('inbox').doc(item.id).set({
      'id': item.id,
      'content': item.content,
      'createdAt': Timestamp.fromDate(item.createdAt),
      'assignedType': item.assignedType?.name,
    });
  }

  Future<void> deleteInboxItem(String id) async {
    await _col('inbox').doc(id).delete();
  }

  // ── 내부 헬퍼 ──────────────────────────

  Future<void> _saveTag(Tag tag) async {
    await _col('tags').doc(tag.id).set({
      'id': tag.id,
      'name': tag.name,
      'colorValue': tag.colorValue,
      'createdAt': Timestamp.fromDate(tag.createdAt),
    });
  }

  Future<List<Tag>> _fetchTagsByIds(List<String> ids) async {
    final tags = <Tag>[];
    for (final id in ids) {
      final doc = await _col('tags').doc(id).get();
      if (doc.exists) tags.add(_tagFromMap(doc.data()!));
    }
    return tags;
  }

  // ── 모델 변환 ──────────────────────────

  Project _projectFromMap(
    Map<String, dynamic> data,
    List<Task> tasks,
    List<Tag> tags,
  ) => Project(
    id: data['id'] as String,
    title: data['title'] as String,
    description: data['description'] as String?,
    status: ProjectStatus.values.firstWhere(
      (s) => s.name == data['status'],
      orElse: () => ProjectStatus.active,
    ),
    areaId: data['areaId'] as String?,
    startDate: data['startDate'] != null ? _dt(data['startDate']) : null,
    dueDate: data['dueDate'] != null ? _dt(data['dueDate']) : null,
    createdAt: _dt(data['createdAt']),
    updatedAt: _dt(data['updatedAt']),
    archivedAt: data['archivedAt'] != null ? _dt(data['archivedAt']) : null,
    tasks: tasks,
    tags: tags,
  );

  Task _taskFromMap(Map<String, dynamic> data) => Task(
    id: data['id'] as String,
    projectId: data['projectId'] as String,
    title: data['title'] as String,
    isCompleted: data['isCompleted'] as bool? ?? false,
    orderIndex: data['orderIndex'] as int? ?? 0,
    createdAt: _dt(data['createdAt']),
  );

  Area _areaFromMap(Map<String, dynamic> data) => Area(
    id: data['id'] as String,
    title: data['title'] as String,
    description: data['description'] as String?,
    icon: IconData(
      data['iconCodePoint'] as int? ?? 0xe88a,
      fontFamily: 'MaterialIcons',
    ),
    standard: data['standard'] as String?,
    createdAt: _dt(data['createdAt']),
    updatedAt: _dt(data['updatedAt']),
    archivedAt: data['archivedAt'] != null ? _dt(data['archivedAt']) : null,
  );

  Resource _resourceFromMap(Map<String, dynamic> data, List<Tag> tags) =>
      Resource(
        id: data['id'] as String,
        title: data['title'] as String,
        content: data['content'] as String?,
        url: data['url'] as String?,
        createdAt: _dt(data['createdAt']),
        updatedAt: _dt(data['updatedAt']),
        archivedAt: data['archivedAt'] != null ? _dt(data['archivedAt']) : null,
        tags: tags,
      );

  Tag _tagFromMap(Map<String, dynamic> data) => Tag(
    id: data['id'] as String,
    name: data['name'] as String,
    colorValue: data['colorValue'] as int? ?? 0xFF6C5CE7,
    createdAt: _dt(data['createdAt']),
  );

  InboxItem _inboxFromMap(Map<String, dynamic> data) => InboxItem(
    id: data['id'] as String,
    content: data['content'] as String,
    createdAt: _dt(data['createdAt']),
    assignedType: data['assignedType'] != null
        ? ParaType.values.firstWhere(
            (t) => t.name == data['assignedType'],
            orElse: () => ParaType.project,
          )
        : null,
  );
}
