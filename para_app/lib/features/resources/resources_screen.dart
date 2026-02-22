import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/models.dart';
import '../../providers/para_providers.dart';

const _uuid = Uuid();

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _urlController = TextEditingController();
  String? _selectedResourceId;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resources = ref.watch(activeResourcesProvider);
    final isDark = ref.watch(themeModeProvider);
    final selected = _selectedResourceId != null
        ? resources.where((r) => r.id == _selectedResourceId).firstOrNull
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(isMobile ? AppSizes.md : AppSizes.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.resources.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: const Icon(
                        Icons.book,
                        color: AppColors.resources,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Text(
                      '자료',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('새 자료'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.resources,
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: AppSizes.xl),

                Expanded(
                  child: resources.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 64,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                              const SizedBox(height: AppSizes.lg),
                              Text(
                                '아직 자료가 없습니다',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : isMobile
                      // ── 모바일: 풀 리스트, 탭하면 바텀시트 ──
                      ? ListView.builder(
                          itemCount: resources.length,
                          itemBuilder: (context, index) {
                            final r = resources[index];
                            return _ResourceListTile(
                              resource: r,
                              isDark: isDark,
                              isSelected: false,
                              onTap: () =>
                                  _showDetailBottomSheet(context, r, isDark),
                            ).animate().fadeIn(
                              delay: Duration(milliseconds: 50 * index),
                              duration: 300.ms,
                            );
                          },
                        )
                      // ── 데스크탑: 분할 패널 ──
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 320,
                              child: ListView.builder(
                                itemCount: resources.length,
                                itemBuilder: (context, index) {
                                  final r = resources[index];
                                  final isSelected =
                                      r.id == _selectedResourceId;
                                  return _ResourceListTile(
                                    resource: r,
                                    isDark: isDark,
                                    isSelected: isSelected,
                                    onTap: () => setState(
                                      () => _selectedResourceId = r.id,
                                    ),
                                  ).animate().fadeIn(
                                    delay: Duration(milliseconds: 50 * index),
                                    duration: 300.ms,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: AppSizes.lg),
                            Expanded(
                              child: selected != null
                                  ? _ResourceDetail(
                                      resource: selected,
                                      isDark: isDark,
                                      onArchive: () {
                                        ref
                                            .read(resourcesProvider.notifier)
                                            .archive(selected.id);
                                        setState(
                                          () => _selectedResourceId = null,
                                        );
                                      },
                                      onDelete: () {
                                        ref
                                            .read(resourcesProvider.notifier)
                                            .remove(selected.id);
                                        setState(
                                          () => _selectedResourceId = null,
                                        );
                                      },
                                      onEdit: () =>
                                          _showEditDialog(context, selected),
                                    ).animate().fadeIn(duration: 300.ms)
                                  : Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.touch_app_outlined,
                                            size: 48,
                                            color: isDark
                                                ? AppColors.darkTextMuted
                                                : AppColors.lightTextMuted,
                                          ),
                                          const SizedBox(height: AppSizes.md),
                                          Text(
                                            '자료를 선택하세요',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetailBottomSheet(
    BuildContext context,
    Resource resource,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                resource.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (resource.url != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(
                  resource.url!,
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ],
              if (resource.content != null) ...[
                const SizedBox(height: AppSizes.md),
                Text(
                  resource.content!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: AppSizes.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditDialog(context, resource);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('수정'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(resourcesProvider.notifier)
                            .archive(resource.id);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.archive_outlined, size: 16),
                      label: const Text('보관'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(resourcesProvider.notifier)
                            .remove(resource.id);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('삭제'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Resource resource) {
    _titleController.text = resource.title;
    _urlController.text = resource.url ?? '';
    _contentController.text = resource.content ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('자료 수정'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: '자료 제목'),
              ),
              const SizedBox(height: AppSizes.lg),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL (선택)',
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              TextField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: '메모 (마크다운 지원)',
                  hintText: '자료에 대한 메모를 작성하세요...',
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
                  .read(resourcesProvider.notifier)
                  .update(
                    Resource(
                      id: resource.id,
                      title: _titleController.text.trim(),
                      url: _urlController.text.trim().isEmpty
                          ? null
                          : _urlController.text.trim(),
                      content: _contentController.text.trim().isEmpty
                          ? null
                          : _contentController.text.trim(),
                      createdAt: resource.createdAt,
                      updatedAt: now,
                      tags: resource.tags,
                    ),
                  );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.resources,
              foregroundColor: Colors.black87,
            ),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    _titleController.clear();
    _contentController.clear();
    _urlController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('새 자료'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: '자료 제목'),
              ),
              const SizedBox(height: AppSizes.lg),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL (선택)',
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '메모 (마크다운 지원)',
                  hintText: '자료에 대한 메모를 작성하세요...',
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
              final newRes = Resource(
                id: _uuid.v4(),
                title: _titleController.text.trim(),
                content: _contentController.text.trim().isEmpty
                    ? null
                    : _contentController.text.trim(),
                url: _urlController.text.trim().isEmpty
                    ? null
                    : _urlController.text.trim(),
                createdAt: now,
                updatedAt: now,
              );
              ref.read(resourcesProvider.notifier).add(newRes);
              setState(() => _selectedResourceId = newRes.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.resources,
              foregroundColor: Colors.black87,
            ),
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }
}

class _ResourceListTile extends StatefulWidget {
  final Resource resource;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _ResourceListTile({
    required this.resource,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ResourceListTile> createState() => _ResourceListTileState();
}

class _ResourceListTileState extends State<_ResourceListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: AppSizes.sm),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.resources.withValues(alpha: 0.12)
                : _isHovered
                ? (widget.isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.black.withValues(alpha: 0.02))
                : widget.isDark
                ? AppColors.darkCard
                : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.resources.withValues(alpha: 0.5)
                  : widget.isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.resource.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.resource.content != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.resource.content!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (widget.resource.tags.isNotEmpty) ...[
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: 4,
                  children: widget.resource.tags
                      .map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: t.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            t.name,
                            style: TextStyle(fontSize: 10, color: t.color),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceDetail extends StatelessWidget {
  final Resource resource;
  final bool isDark;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ResourceDetail({
    required this.resource,
    required this.isDark,
    required this.onArchive,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  resource.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
                tooltip: '수정',
              ),
              IconButton(
                icon: const Icon(Icons.archive_outlined, size: 20),
                onPressed: onArchive,
                tooltip: '보관함으로 이동',
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.error,
                ),
                onPressed: onDelete,
                tooltip: '삭제',
              ),
            ],
          ),

          if (resource.url != null) ...[
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                const Icon(Icons.link, size: 16, color: AppColors.areas),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    resource.url!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.areas,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          if (resource.tags.isNotEmpty) ...[
            const SizedBox(height: AppSizes.md),
            Wrap(
              spacing: 6,
              children: resource.tags
                  .map(
                    (t) => Chip(
                      label: Text(
                        t.name,
                        style: TextStyle(fontSize: 12, color: t.color),
                      ),
                      backgroundColor: t.color.withValues(alpha: 0.1),
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: AppSizes.lg),
          Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          const SizedBox(height: AppSizes.lg),

          Expanded(
            child: SingleChildScrollView(
              child: Text(
                resource.content ?? '내용이 없습니다.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
