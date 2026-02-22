import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/para_providers.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedProjects = ref.watch(archivedProjectsProvider);
    final archivedAreas = ref.watch(archivedAreasProvider);
    final archivedResources = ref.watch(archivedResourcesProvider);
    final isDark = ref.watch(themeModeProvider);
    final totalArchived = archivedProjects.length + archivedAreas.length + archivedResources.length;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.archive.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: const Icon(Icons.archive, color: AppColors.archive, size: 22),
                ),
                const SizedBox(width: AppSizes.md),
                Text('보관함', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(width: AppSizes.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.archive.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text('$totalArchived개', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.archive)),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: AppSizes.xl),

            Expanded(
              child: totalArchived == 0
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.archive_outlined, size: 64, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          const SizedBox(height: AppSizes.lg),
                          Text('보관함이 비어있습니다', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: AppSizes.sm),
                          Text('완료된 프로젝트나 더 이상 필요 없는 항목이\n여기에 보관됩니다.',
                            style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        if (archivedProjects.isNotEmpty) ...[
                          _SectionHeader(title: '프로젝트', count: archivedProjects.length, color: AppColors.projects),
                          ...archivedProjects.asMap().entries.map((e) =>
                            _ArchiveTile(
                              title: e.value.title, subtitle: e.value.description,
                              icon: Icons.folder, color: AppColors.projects, isDark: isDark,
                              onRestore: () => ref.read(projectsProvider.notifier).restore(e.value.id),
                              onDelete: () => ref.read(projectsProvider.notifier).remove(e.value.id),
                            ).animate().fadeIn(delay: Duration(milliseconds: 50 * e.key), duration: 300.ms),
                          ),
                          const SizedBox(height: AppSizes.lg),
                        ],
                        if (archivedAreas.isNotEmpty) ...[
                          _SectionHeader(title: '영역', count: archivedAreas.length, color: AppColors.areas),
                          ...archivedAreas.asMap().entries.map((e) =>
                            _ArchiveTile(
                              title: e.value.title, subtitle: e.value.description,
                              icon: Icons.home, color: AppColors.areas, isDark: isDark,
                              onRestore: () => ref.read(areasProvider.notifier).restore(e.value.id),
                              onDelete: () => ref.read(areasProvider.notifier).remove(e.value.id),
                            ).animate().fadeIn(delay: Duration(milliseconds: 50 * e.key), duration: 300.ms),
                          ),
                          const SizedBox(height: AppSizes.lg),
                        ],
                        if (archivedResources.isNotEmpty) ...[
                          _SectionHeader(title: '자료', count: archivedResources.length, color: AppColors.resources),
                          ...archivedResources.asMap().entries.map((e) =>
                            _ArchiveTile(
                              title: e.value.title, subtitle: e.value.content,
                              icon: Icons.book, color: AppColors.resources, isDark: isDark,
                              onRestore: () => ref.read(resourcesProvider.notifier).restore(e.value.id),
                              onDelete: () => ref.read(resourcesProvider.notifier).remove(e.value.id),
                            ).animate().fadeIn(delay: Duration(milliseconds: 50 * e.key), duration: 300.ms),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: AppSizes.sm),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: AppSizes.sm),
          Text('($count)', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ArchiveTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _ArchiveTile({
    required this.title, this.subtitle, required this.icon, required this.color,
    required this.isDark, required this.onRestore, required this.onDelete,
  });

  @override
  State<_ArchiveTile> createState() => _ArchiveTileState();
}

class _ArchiveTileState extends State<_ArchiveTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(widget.icon, color: widget.color.withValues(alpha: 0.5), size: 18),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: TextStyle(
                    color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  )),
                  if (widget.subtitle != null)
                    Text(widget.subtitle!, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (_isHovered) ...[
              TextButton.icon(
                onPressed: widget.onRestore,
                icon: const Icon(Icons.restore, size: 16),
                label: const Text('복원', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: AppSizes.xs),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_forever, size: 18, color: AppColors.error),
                tooltip: '영구 삭제',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
