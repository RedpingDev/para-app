import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/models.dart';
import '../../providers/para_providers.dart';

const _uuid = Uuid();

class AreasScreen extends ConsumerStatefulWidget {
  const AreasScreen({super.key});

  @override
  ConsumerState<AreasScreen> createState() => _AreasScreenState();
}

class _AreasScreenState extends ConsumerState<AreasScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _standardController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _standardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final areas = ref.watch(activeAreasProvider);
    final isDark = ref.watch(themeModeProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.areas.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: const Icon(
                    Icons.home,
                    color: AppColors.areas,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Text('영역', style: Theme.of(context).textTheme.displayMedium),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('새 영역'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.areas,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: AppSizes.xl),

            Expanded(
              child: areas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.home_outlined,
                            size: 64,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                          const SizedBox(height: AppSizes.lg),
                          Text(
                            '아직 영역이 없습니다',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth < 500
                            ? 1
                            : constraints.maxWidth < 800
                            ? 2
                            : 3;
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                crossAxisSpacing: AppSizes.lg,
                                mainAxisSpacing: AppSizes.lg,
                                childAspectRatio: cols == 1 ? 2.2 : 1.6,
                              ),
                          itemCount: areas.length,
                          itemBuilder: (context, index) {
                            return _AreaCard(
                                  area: areas[index],
                                  isDark: isDark,
                                  onArchive: () => ref
                                      .read(areasProvider.notifier)
                                      .archive(areas[index].id),
                                  onDelete: () => ref
                                      .read(areasProvider.notifier)
                                      .remove(areas[index].id),
                                  onEdit: () =>
                                      _showEditDialog(context, areas[index]),
                                )
                                .animate()
                                .fadeIn(
                                  delay: Duration(milliseconds: 80 * index),
                                  duration: 400.ms,
                                )
                                .scale(
                                  begin: const Offset(0.95, 0.95),
                                  end: const Offset(1, 1),
                                );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Area area) {
    _titleController.text = area.title;
    _descController.text = area.description ?? '';
    _standardController.text = area.standard ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('영역 수정'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: '영역 이름'),
              ),
              const SizedBox(height: AppSizes.lg),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: '설명 (선택)'),
              ),
              const SizedBox(height: AppSizes.lg),
              TextField(
                controller: _standardController,
                decoration: const InputDecoration(
                  labelText: '유지 기준 (선택)',
                  hintText: '예: 매주 운동 3회',
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
              ref
                  .read(areasProvider.notifier)
                  .update(
                    area.copyWith(
                      title: _titleController.text.trim(),
                      description: _descController.text.trim().isEmpty
                          ? null
                          : _descController.text.trim(),
                      standard: _standardController.text.trim().isEmpty
                          ? null
                          : _standardController.text.trim(),
                      updatedAt: DateTime.now(),
                    ),
                  );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.areas),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    _titleController.clear();
    _descController.clear();
    _standardController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('새 영역'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '영역 이름',
                  hintText: '예: 건강, 재정, 커리어',
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: '설명 (선택)'),
              ),
              const SizedBox(height: AppSizes.lg),
              TextField(
                controller: _standardController,
                decoration: const InputDecoration(
                  labelText: '유지 기준 (선택)',
                  hintText: '예: 매주 운동 3회',
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
                  .read(areasProvider.notifier)
                  .add(
                    Area(
                      id: _uuid.v4(),
                      title: _titleController.text.trim(),
                      description: _descController.text.trim().isEmpty
                          ? null
                          : _descController.text.trim(),
                      standard: _standardController.text.trim().isEmpty
                          ? null
                          : _standardController.text.trim(),
                      createdAt: now,
                      updatedAt: now,
                    ),
                  );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.areas),
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }
}

class _AreaCard extends StatefulWidget {
  final Area area;
  final bool isDark;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _AreaCard({
    required this.area,
    required this.isDark,
    required this.onArchive,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_AreaCard> createState() => _AreaCardState();
}

class _AreaCardState extends State<_AreaCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.area;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        offset: _isHovered ? const Offset(0, -0.03) : Offset.zero,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSizes.xl),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: _isHovered
                  ? AppColors.areas.withValues(alpha: 0.5)
                  : widget.isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.areas.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.areas.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Icon(a.icon, color: AppColors.areas, size: 22),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz,
                      color: widget.isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                      size: 20,
                    ),
                    onSelected: (v) {
                      if (v == 'edit') widget.onEdit();
                      if (v == 'archive') widget.onArchive();
                      if (v == 'delete') widget.onDelete();
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
                        child: Text('보관함으로 이동'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          '삭제',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Text(a.title, style: Theme.of(context).textTheme.titleLarge),
              if (a.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  a.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              if (a.standard != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.areas.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.flag_outlined,
                        size: 14,
                        color: AppColors.areas,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          a.standard!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.areas,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
