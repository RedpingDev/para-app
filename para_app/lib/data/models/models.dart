import 'package:flutter/material.dart';

/// 프로젝트 상태
enum ProjectStatus {
  active('진행중', Color(0xFF00B894), Icons.play_circle_outline),
  onHold('대기중', Color(0xFFFDCB6E), Icons.pause_circle_outline),
  completed('완료', Color(0xFF0984E3), Icons.check_circle_outline),
  archived('보관됨', Color(0xFF636E72), Icons.archive_outlined);

  const ProjectStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

/// PARA 카테고리 타입
enum ParaType {
  project('프로젝트', Color(0xFF00B894), Icons.folder_outlined),
  area('영역', Color(0xFF0984E3), Icons.home_outlined),
  resource('자료', Color(0xFFFDCB6E), Icons.book_outlined),
  archive('보관함', Color(0xFF636E72), Icons.archive_outlined);

  const ParaType(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

/// 프로젝트 모델
class Project {
  final String id;
  final String title;
  final String? description;
  final ProjectStatus status;
  final String? areaId;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final List<Task> tasks;
  final List<Tag> tags;

  const Project({
    required this.id,
    required this.title,
    this.description,
    this.status = ProjectStatus.active,
    this.areaId,
    this.startDate,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.tasks = const [],
    this.tags = const [],
  });

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((t) => t.isCompleted).length;
    return completed / tasks.length;
  }

  /// 마감일까지 남은 일수
  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// 마감 임박 여부 (3일 이내)
  bool get isUrgent {
    final days = daysUntilDue;
    return days != null && days <= 3 && days >= 0;
  }

  /// 마감일 경과 여부
  bool get isOverdue {
    final days = daysUntilDue;
    return days != null && days < 0;
  }

  Project copyWith({
    String? id,
    String? title,
    String? description,
    ProjectStatus? status,
    String? areaId,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    List<Task>? tasks,
    List<Tag>? tags,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      areaId: areaId ?? this.areaId,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      tasks: tasks ?? this.tasks,
      tags: tags ?? this.tags,
    );
  }
}

/// 영역 모델
class Area {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final String? standard;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final List<Tag> tags;

  const Area({
    required this.id,
    required this.title,
    this.description,
    this.icon = Icons.home_outlined,
    this.standard,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.tags = const [],
  });

  Area copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    String? standard,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    List<Tag>? tags,
  }) {
    return Area(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      standard: standard ?? this.standard,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      tags: tags ?? this.tags,
    );
  }
}

/// 자료 모델
class Resource {
  final String id;
  final String title;
  final String? content;
  final String? url;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final List<Tag> tags;

  const Resource({
    required this.id,
    required this.title,
    this.content,
    this.url,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.tags = const [],
  });

  Resource copyWith({
    String? id,
    String? title,
    String? content,
    String? url,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    List<Tag>? tags,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      tags: tags ?? this.tags,
    );
  }
}

/// 태스크 모델
class Task {
  final String id;
  final String projectId;
  final String title;
  final bool isCompleted;
  final int orderIndex;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.isCompleted = false,
    this.orderIndex = 0,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    bool? isCompleted,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 태그 모델
class Tag {
  final String id;
  final String name;
  final int colorValue;
  final DateTime createdAt;

  const Tag({
    required this.id,
    required this.name,
    this.colorValue = 0xFF6C5CE7,
    required this.createdAt,
  });

  Color get color => Color(colorValue);
}

/// 인박스 아이템 모델
class InboxItem {
  final String id;
  final String content;
  final DateTime createdAt;
  final ParaType? assignedType;

  const InboxItem({
    required this.id,
    required this.content,
    required this.createdAt,
    this.assignedType,
  });
}
