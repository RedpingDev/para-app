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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? AppSizes.md : AppSizes.xl),
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
                        // Search Bar (데스크탑만)
                        if (!isMobile)
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
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusXl,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1, end: 0),

                const SizedBox(height: AppSizes.xl),

                // ── Overview Cards ────────────────
                if (isMobile)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSizes.md,
                    mainAxisSpacing: AppSizes.md,
                    childAspectRatio: 1.6,
                    children: [
                      _OverviewCard(
                        title: 'Projects',
                        subtitle: '프로젝트',
                        count: activeProjects.length,
                        icon: Icons.folder,
                        color: AppColors.projects,
                        isDark: isDark,
                        onTap: () =>
                            ref.read(selectedNavIndexProvider.notifier).set(1),
                      ),
                      _OverviewCard(
                        title: 'Areas',
                        subtitle: '영역',
                        count: areas.length,
                        icon: Icons.home,
                        color: AppColors.areas,
                        isDark: isDark,
                        onTap: () =>
                            ref.read(selectedNavIndexProvider.notifier).set(2),
                      ),
                      _OverviewCard(
                        title: 'Resources',
                        subtitle: '자료',
                        count: resources.length,
                        icon: Icons.book,
                        color: AppColors.resources,
                        isDark: isDark,
                        onTap: () =>
                            ref.read(selectedNavIndexProvider.notifier).set(3),
                      ),
                      _OverviewCard(
                        title: 'Archive',
                        subtitle: '보관함',
                        count: archivedProjects.length,
                        icon: Icons.archive,
                        color: AppColors.archive,
                        isDark: isDark,
                        onTap: () =>
                            ref.read(selectedNavIndexProvider.notifier).set(4),
                      ),
                    ],
                  )
                else
                  Row(
                    children:
                        [
                              _OverviewCard(
                                title: 'Projects',
                                subtitle: '프로젝트',
                                count: activeProjects.length,
                                icon: Icons.folder,
                                color: AppColors.projects,
                                isDark: isDark,
                                onTap: () => ref
                                    .read(selectedNavIndexProvider.notifier)
                                    .set(1),
                              ),
                              const SizedBox(width: AppSizes.lg),
                              _OverviewCard(
                                title: 'Areas',
                                subtitle: '영역',
                                count: areas.length,
                                icon: Icons.home,
                                color: AppColors.areas,
                                isDark: isDark,
                                onTap: () => ref
                                    .read(selectedNavIndexProvider.notifier)
                                    .set(2),
                              ),
                              const SizedBox(width: AppSizes.lg),
                              _OverviewCard(
                                title: 'Resources',
                                subtitle: '자료',
                                count: resources.length,
                                icon: Icons.book,
                                color: AppColors.resources,
                                isDark: isDark,
                                onTap: () => ref
                                    .read(selectedNavIndexProvider.notifier)
                                    .set(3),
                              ),
                              const SizedBox(width: AppSizes.lg),
                              _OverviewCard(
                                title: 'Archive',
                                subtitle: '보관함',
                                count: archivedProjects.length,
                                icon: Icons.archive,
                                color: AppColors.archive,
                                isDark: isDark,
                                onTap: () => ref
                                    .read(selectedNavIndexProvider.notifier)
                                    .set(4),
                              ),
                            ]
                            .asMap()
                            .entries
                            .map(
                              (e) => e.key % 2 == 1
                                  ? e.value
                                  : Expanded(child: e.value),
                            )
                            .toList(),
                  ),

                const SizedBox(height: AppSizes.xl),

                // ── PARA Guide ────────────────────
                _ParaGuideCard(
                  isDark: isDark,
                ).animate().fadeIn(delay: 350.ms, duration: 500.ms),

                const SizedBox(height: AppSizes.xl),

                // ── Two Column Layout ──────────────
                if (isMobile)
                  Column(
                    children: [
                      _SectionCard(
                        title: '진행중인 프로젝트',
                        icon: Icons.rocket_launch,
                        isDark: isDark,
                        child: activeProjects.isEmpty
                            ? _buildEmptyState('아직 진행중인 프로젝트가 없습니다')
                            : Column(
                                children: activeProjects
                                    .take(5)
                                    .map(
                                      (p) => _ProjectTile(
                                        project: p,
                                        isDark: isDark,
                                        onTap: () => ref
                                            .read(
                                              selectedNavIndexProvider.notifier,
                                            )
                                            .set(1),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                      if (urgentProjects.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.md),
                        _SectionCard(
                          title: '마감 임박 ⚠️',
                          icon: Icons.warning_amber,
                          isDark: isDark,
                          child: Column(
                            children: urgentProjects
                                .map(
                                  (p) =>
                                      _DeadlineTile(project: p, isDark: isDark),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSizes.md),
                      _SectionCard(
                        title: '나의 영역',
                        icon: Icons.space_dashboard_outlined,
                        isDark: isDark,
                        child: areas.isEmpty
                            ? _buildEmptyState('아직 영역이 없습니다')
                            : Column(
                                children: areas
                                    .map(
                                      (a) => _AreaTile(area: a, isDark: isDark),
                                    )
                                    .toList(),
                              ),
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                      .map(
                                        (p) => _ProjectTile(
                                          project: p,
                                          isDark: isDark,
                                          onTap: () => ref
                                              .read(
                                                selectedNavIndexProvider
                                                    .notifier,
                                              )
                                              .set(1),
                                        ),
                                      )
                                      .toList(),
                                ),
                        ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                      ),
                      const SizedBox(width: AppSizes.lg),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            if (urgentProjects.isNotEmpty)
                              _SectionCard(
                                title: '마감 임박 ⚠️',
                                icon: Icons.warning_amber,
                                isDark: isDark,
                                child: Column(
                                  children: urgentProjects
                                      .map(
                                        (p) => _DeadlineTile(
                                          project: p,
                                          isDark: isDark,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ).animate().fadeIn(
                                delay: 500.ms,
                                duration: 500.ms,
                              ),
                            if (urgentProjects.isNotEmpty)
                              const SizedBox(height: AppSizes.lg),
                            _SectionCard(
                              title: '나의 영역',
                              icon: Icons.space_dashboard_outlined,
                              isDark: isDark,
                              child: areas.isEmpty
                                  ? _buildEmptyState('아직 영역이 없습니다')
                                  : Column(
                                      children: areas
                                          .map(
                                            (a) => _AreaTile(
                                              area: a,
                                              isDark: isDark,
                                            ),
                                          )
                                          .toList(),
                                    ),
                            ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 14),
        ),
      ),
    );
  }
}

/// PARA 방법론 가이드 카드
class _ParaGuideCard extends StatefulWidget {
  final bool isDark;
  const _ParaGuideCard({required this.isDark});

  @override
  State<_ParaGuideCard> createState() => _ParaGuideCardState();
}

class _ParaGuideCardState extends State<_ParaGuideCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;

  static const _items = [
    _GuideItem(
      letter: 'P',
      title: 'Projects',
      subtitle: '프로젝트',
      color: AppColors.projects,
      icon: Icons.folder_outlined,
      description: '명확한 마감일과 결과물이 있는 일련의 작업',
      tip: '예) "앱 출시", "보고서 제출", "이사 준비"',
    ),
    _GuideItem(
      letter: 'A',
      title: 'Areas',
      subtitle: '영역',
      color: AppColors.areas,
      icon: Icons.home_outlined,
      description: '지속적으로 관리해야 하는 책임 범위',
      tip: '예) "건강", "재정", "커리어", "가족"',
    ),
    _GuideItem(
      letter: 'R',
      title: 'Resources',
      subtitle: '자료',
      color: AppColors.resources,
      icon: Icons.book_outlined,
      description: '미래에 유용할 수 있는 정보와 참고 자료',
      tip: '예) "Flutter 팁", "독서 노트", "레시피"',
    ),
    _GuideItem(
      letter: 'A',
      title: 'Archive',
      subtitle: '보관함',
      color: AppColors.archive,
      icon: Icons.archive_outlined,
      description: '더 이상 활성화되지 않은 항목들의 보관소',
      tip: '완료된 프로젝트, 중단된 영역 등이 자동 이동됩니다',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusLg),
              bottom: Radius.circular(AppSizes.radiusLg),
            ),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    'PARA 방법론 가이드',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      'Tiago Forte',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable body
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(
                    children: [
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '모든 정보를 4가지 카테고리로 분류하여 체계적으로 관리하세요.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                            ),
                            const SizedBox(height: AppSizes.lg),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobile = constraints.maxWidth < 500;
                                if (isMobile) {
                                  // 모바일: 2×2 그리드
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _GuideItemCard(
                                              item: _items[0],
                                              isDark: isDark,
                                            ),
                                          ),
                                          const SizedBox(width: AppSizes.sm),
                                          Expanded(
                                            child: _GuideItemCard(
                                              item: _items[1],
                                              isDark: isDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSizes.sm),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _GuideItemCard(
                                              item: _items[2],
                                              isDark: isDark,
                                            ),
                                          ),
                                          const SizedBox(width: AppSizes.sm),
                                          Expanded(
                                            child: _GuideItemCard(
                                              item: _items[3],
                                              isDark: isDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                                // 데스크탑: 4열 가로
                                return Row(
                                  children: _items
                                      .map(
                                        (item) => Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: AppSizes.md,
                                            ),
                                            child: _GuideItemCard(
                                              item: item,
                                              isDark: isDark,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            ),
                            const SizedBox(height: AppSizes.md),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                                const SizedBox(width: AppSizes.xs),
                                Expanded(
                                  child: Text(
                                    '핵심 원칙: 항목을 추가할 때 "가장 가까운 미래에 어디서 이것이 필요할까?"를 먼저 질문하세요.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? AppColors.darkTextMuted
                                              : AppColors.lightTextMuted,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _GuideItem {
  final String letter;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final String description;
  final String tip;

  const _GuideItem({
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.description,
    required this.tip,
  });
}

class _GuideItemCard extends StatelessWidget {
  final _GuideItem item;
  final bool isDark;

  const _GuideItemCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: isDark ? 0.07 : 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: item.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Center(
                  child: Text(
                    item.letter,
                    style: TextStyle(
                      color: item.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: item.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: item.color.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            item.description,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            item.tip,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
              fontSize: 11,
            ),
          ),
        ],
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
                  child: Icon(widget.icon, color: widget.color, size: 24),
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
                        style: Theme.of(context).textTheme.headlineMedium
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
                Text(title, style: Theme.of(context).textTheme.titleMedium),
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
                    if (p.tasks.isNotEmpty) const SizedBox(height: 4),
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
                      valueColor: AlwaysStoppedAnimation<Color>(p.status.color),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  '${(p.progress * 100).toInt()}%',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
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
            child: Icon(area.icon, size: 18, color: AppColors.areas),
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
