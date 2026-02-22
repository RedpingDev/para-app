import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/models.dart';
import '../../providers/para_providers.dart';

const _uuid = Uuid();

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(activeProjectsProvider);
    final isDark = ref.watch(themeModeProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(isMobile ? AppSizes.md : AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.projects.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: const Icon(
                    Icons.folder,
                    color: AppColors.projects,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Text('프로젝트', style: Theme.of(context).textTheme.displayMedium),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('새 프로젝트'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.projects,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: AppSizes.xl),

            // ── Project List ──────────────────
            Expanded(
              child: projects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 64,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                          const SizedBox(height: AppSizes.lg),
                          Text(
                            '아직 프로젝트가 없습니다',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSizes.sm),
                          TextButton.icon(
                            onPressed: () => _showCreateDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('첫 프로젝트 만들기'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return _ProjectCard(
                              project: project,
                              isDark: isDark,
                              onToggleTask: (taskId) {
                                ref
                                    .read(projectsProvider.notifier)
                                    .toggleTask(project.id, taskId);
                              },
                              onAddTask: (title) {
                                ref
                                    .read(projectsProvider.notifier)
                                    .addTask(project.id, title);
                              },
                              onArchive: () {
                                ref
                                    .read(projectsProvider.notifier)
                                    .archive(project.id);
                              },
                              onDelete: () {
                                ref
                                    .read(projectsProvider.notifier)
                                    .remove(project.id);
                              },
                              onEdit: () => _showEditDialog(context, project),
                            )
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 50 * index),
                              duration: 400.ms,
                            )
                            .slideX(begin: 0.05, end: 0);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Project project) {
    _titleController.text = project.title;
    _descController.text = project.description ?? '';
    ProjectStatus selectedStatus = project.status;
    DateTime? selectedDueDate = project.dueDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('프로젝트 수정'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: '프로젝트 이름'),
                ),
                const SizedBox(height: AppSizes.lg),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: '설명 (선택)'),
                ),
                const SizedBox(height: AppSizes.lg),
                DropdownButtonFormField<ProjectStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: '상태'),
                  items: ProjectStatus.values
                      .where((s) => s != ProjectStatus.archived)
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Icon(s.icon, size: 16, color: s.color),
                              const SizedBox(width: 8),
                              Text(s.label),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedStatus = v);
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDueDate != null
                            ? '마감일: ${selectedDueDate!.year}/${selectedDueDate!.month}/${selectedDueDate!.day}'
                            : '마감일 없음',
                        style: Theme.of(ctx).textTheme.bodyMedium,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDueDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('날짜 선택'),
                    ),
                    if (selectedDueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () =>
                            setDialogState(() => selectedDueDate = null),
                        tooltip: '마감일 제거',
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.trim().isEmpty) return;
                ref
                    .read(projectsProvider.notifier)
                    .update(
                      Project(
                        id: project.id,
                        title: _titleController.text.trim(),
                        description: _descController.text.trim().isEmpty
                            ? null
                            : _descController.text.trim(),
                        status: selectedStatus,
                        areaId: project.areaId,
                        startDate: project.startDate,
                        dueDate: selectedDueDate,
                        createdAt: project.createdAt,
                        updatedAt: DateTime.now(),
                        archivedAt: project.archivedAt,
                        tasks: project.tasks,
                        tags: project.tags,
                      ),
                    );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.projects,
              ),
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    _titleController.clear();
    _descController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('새 프로젝트'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '프로젝트 이름',
                  hintText: '무엇을 달성하고 싶으신가요?',
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '설명 (선택)',
                  hintText: '프로젝트에 대해 간단히 설명해주세요',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.trim().isEmpty) return;
              final now = DateTime.now();
              ref
                  .read(projectsProvider.notifier)
                  .add(
                    Project(
                      id: _uuid.v4(),
                      title: _titleController.text.trim(),
                      description: _descController.text.trim().isEmpty
                          ? null
                          : _descController.text.trim(),
                      createdAt: now,
                      updatedAt: now,
                    ),
                  );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.projects,
            ),
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }
}

/// 프로젝트 카드
class _ProjectCard extends StatefulWidget {
  final Project project;
  final bool isDark;
  final Function(String taskId) onToggleTask;
  final Function(String title) onAddTask;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ProjectCard({
    required this.project,
    required this.isDark,
    required this.onToggleTask,
    required this.onAddTask,
    required this.onArchive,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isExpanded = false;
  bool _isHovered = false;
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: _isHovered
                ? AppColors.projects.withValues(alpha: 0.4)
                : widget.isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.projects.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            // ── Header ────────────────────────
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Row(
                  children: [
                    // Status indicator
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: p.status.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: p.status.color.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),

                    // Title & description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (p.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              p.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Progress
                    if (p.tasks.isNotEmpty) ...[
                      SizedBox(
                        width: 80,
                        child: Column(
                          children: [
                            Text(
                              '${(p.progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: p.status.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: p.progress,
                                minHeight: 6,
                                backgroundColor: widget.isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                                valueColor: AlwaysStoppedAnimation(
                                  p.status.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                    ],

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: p.status.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Text(
                        p.status.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: p.status.color,
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSizes.sm),

                    // Actions
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: widget.isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                        size: 20,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            widget.onEdit();
                            break;
                          case 'archive':
                            widget.onArchive();
                            break;
                          case 'delete':
                            widget.onDelete();
                            break;
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('수정'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('보관함으로 이동'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '삭제',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Expand/collapse
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: widget.isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tasks (expandable) ────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  Divider(
                    height: 1,
                    color: widget.isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                  // Task list
                  ...p.tasks.map(
                    (task) => _TaskTile(
                      task: task,
                      isDark: widget.isDark,
                      onToggle: () => widget.onToggleTask(task.id),
                    ),
                  ),

                  // Add task
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _taskController,
                            decoration: InputDecoration(
                              hintText: '새 태스크 추가...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.sm,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusSm,
                                ),
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                widget.onAddTask(value.trim());
                                _taskController.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        IconButton.filled(
                          onPressed: () {
                            if (_taskController.text.trim().isNotEmpty) {
                              widget.onAddTask(_taskController.text.trim());
                              _taskController.clear();
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.projects,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Tags & Meta ──────────────────
            if (p.tags.isNotEmpty || p.dueDate != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  0,
                  AppSizes.lg,
                  AppSizes.md,
                ),
                child: Row(
                  children: [
                    // Tags
                    ...p.tags.map(
                      (tag) => Padding(
                        padding: const EdgeInsets.only(right: AppSizes.xs),
                        child: Chip(
                          label: Text(
                            tag.name,
                            style: TextStyle(fontSize: 11, color: tag.color),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: tag.color.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Due date
                    if (p.dueDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: p.isOverdue
                                ? AppColors.error
                                : p.isUrgent
                                ? AppColors.warning
                                : (widget.isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${p.dueDate!.month}/${p.dueDate!.day}',
                            style: TextStyle(
                              fontSize: 12,
                              color: p.isOverdue
                                  ? AppColors.error
                                  : p.isUrgent
                                  ? AppColors.warning
                                  : (widget.isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.lightTextMuted),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 태스크 타일
class _TaskTile extends StatelessWidget {
  final Task task;
  final bool isDark;
  final VoidCallback onToggle;

  const _TaskTile({
    required this.task,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppColors.projects
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.projects
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 14,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.isCompleted
                      ? (isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
