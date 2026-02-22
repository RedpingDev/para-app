import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/models.dart';
import '../../providers/para_providers.dart';
import '../../shared/layouts/main_layout.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProjects = ref.watch(activeProjectsProvider);
    final areas = ref.watch(activeAreasProvider);
    final resources = ref.watch(activeResourcesProvider);
    final archivedProjects = ref.watch(archivedProjectsProvider);
    final urgentProjects = ref.watch(urgentProjectsProvider);
    final isDark = ref.watch(themeModeProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '대시보드',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      '오늘도 생산적인 하루를 보내세요 ✨',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const Spacer(),
                // Search Bar
                SizedBox(
                  width: 280,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '검색...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusXl),
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

            const SizedBox(height: AppSizes.xl),

            // ── Overview Cards ────────────────
            Row(
              children: [
                _OverviewCard(
                  title: 'Projects',
                  subtitle: '프로젝트',
                  count: activeProjects.length,
                  icon: Icons.folder,
                  color: AppColors.projects,
                  isDark: isDark,
                  onTap: () => ref.read(selectedNavIndexProvider.notifier).set(1),
                ),
                const SizedBox(width: AppSizes.lg),
                _OverviewCard(
                  title: 'Areas',
                  subtitle: '영역',
                  count: areas.length,
                  icon: Icons.home,
                  color: AppColors.areas,
                  isDark: isDark,
                  onTap: () => ref.read(selectedNavIndexProvider.notifier).set(2),
                ),
                const SizedBox(width: AppSizes.lg),
                _OverviewCard(
                  title: 'Resources',
                  subtitle: '자료',
                  count: resources.length,
                  icon: Icons.book,
                  color: AppColors.resources,
                  isDark: isDark,
                  onTap: () => ref.read(selectedNavIndexProvider.notifier).set(3),
                ),
                const SizedBox(width: AppSizes.lg),
                _OverviewCard(
                  title: 'Archive',
                  subtitle: '보관함',
                  count: archivedProjects.length,
                  icon: Icons.archive,
                  color: AppColors.archive,
                  isDark: isDark,
                  onTap: () => ref.read(selectedNavIndexProvider.notifier).set(4),
                ),
              ]
                  .asMap()
                  .entries
                  .map((e) => Expanded(
                        child: e.value
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 100 * e.key),
                              duration: 500.ms,
                            )
                            .slideY(begin: 0.2, end: 0),
                      ))
                  .toList(),
            ),

            const SizedBox(height: AppSizes.xl),

            // ── Two Column Layout ──────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 진행중인 프로젝트
                Expanded(
                  flex: 3,
                  child: _SectionCard(
                    title: '진행중인 프로젝트',
                    icon: Icons.rocket_launch,
                    isDark: isDark,
                    child: activeProjects.isEmpty
                        ? _buildEmptyState('아직 진행중인 프로젝트가 없습니다')
                        : Column(
                            children: activeProjects
                                .take(5)
                                .map((p) => _ProjectTile(
                                      project: p,
                                      isDark: isDark,
                                      onTap: () => ref
                                          .read(selectedNavIndexProvider
                                              .notifier)
                                          .set(1),
                                    ))
                                .toList(),
                          ),
                  ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                ),

                const SizedBox(width: AppSizes.lg),

                // 마감 임박 / 영역
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // 마감 임박
                      if (urgentProjects.isNotEmpty)
                        _SectionCard(
                          title: '마감 임박 ⚠️',
                          icon: Icons.warning_amber,
                          isDark: isDark,
                          child: Column(
                            children: urgentProjects
                                .map((p) => _DeadlineTile(
                                      project: p,
                                      isDark: isDark,
                                    ))
                                .toList(),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 500.ms),

                      if (urgentProjects.isNotEmpty)
                        const SizedBox(height: AppSizes.lg),

                      // 영역 요약
                      _SectionCard(
                        title: '나의 영역',
                        icon: Icons.space_dashboard_outlined,
                        isDark: isDark,
                        child: areas.isEmpty
                            ? _buildEmptyState('아직 영역이 없습니다')
                            : Column(
                                children: areas
                                    .map((a) =>
                                        _AreaTile(area: a, isDark: isDark))
                                    .toList(),
                              ),
                      )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 500.ms),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: AppColors.darkTextMuted,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// 개요 카드 (Projects, Areas, Resources, Archive)
class _OverviewCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _OverviewCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends State<_OverviewCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          offset: _isHovered ? const Offset(0, -0.05) : Offset.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(AppSizes.xl),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: _isHovered
                    ? widget.color.withValues(alpha: 0.5)
                    : widget.isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.lg),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.count}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 섹션 카드 (그룹을 감싸는 카드)
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSizes.sm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          child,
        ],
      ),
    );
  }
}

/// 프로젝트 타일
class _ProjectTile extends StatefulWidget {
  final Project project;
  final bool isDark;
  final VoidCallback onTap;

  const _ProjectTile({
    required this.project,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ProjectTile> createState() => _ProjectTileState();
}

class _ProjectTileState extends State<_ProjectTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          color: _isHovered
              ? (widget.isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02))
              : Colors.transparent,
          child: Row(
            children: [
              // Status
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: p.status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSizes.md),

              // Title & meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (p.tasks.isNotEmpty)
                      const SizedBox(height: 4),
                    if (p.tasks.isNotEmpty)
                      Text(
                        '${p.tasks.where((t) => t.isCompleted).length}/${p.tasks.length} 완료',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),

              // Progress
              if (p.tasks.isNotEmpty) ...[
                SizedBox(
                  width: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: p.progress,
                      minHeight: 6,
                      backgroundColor: widget.isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        p.status.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  '${(p.progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],

              // Status badge
              const SizedBox(width: AppSizes.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: p.status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  p.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: p.status.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 마감 임박 타일
class _DeadlineTile extends StatelessWidget {
  final Project project;
  final bool isDark;

  const _DeadlineTile({required this.project, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final days = project.daysUntilDue ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.sm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 18,
            color: days <= 1 ? AppColors.error : AppColors.warning,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              project.title,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: (days <= 1 ? AppColors.error : AppColors.warning)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(
              'D-$days',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: days <= 1 ? AppColors.error : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 영역 타일
class _AreaTile extends StatelessWidget {
  final Area area;
  final bool isDark;

  const _AreaTile({required this.area, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.areas.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              area.icon,
              size: 18,
              color: AppColors.areas,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (area.standard != null)
                  Text(
                    area.standard!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
