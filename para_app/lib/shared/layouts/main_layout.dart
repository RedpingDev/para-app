import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/para_providers.dart';

/// 현재 선택된 네비게이션 인덱스
final selectedNavIndexProvider = NotifierProvider<SelectedNavIndexNotifier, int>(SelectedNavIndexNotifier.new);

class SelectedNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

/// 메인 레이아웃 - NavigationRail + Content Area
class MainLayout extends ConsumerWidget {
  final List<Widget> pages;

  const MainLayout({super.key, required this.pages});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final isDark = ref.watch(themeModeProvider);
    final inboxCount = ref.watch(inboxProvider).length;

    return Scaffold(
      body: Row(
        children: [
          // ── Navigation Rail ──────────────────
          _buildNavRail(context, ref, selectedIndex, isDark, inboxCount),

          // ── Divider ─────────────────────────
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),

          // ── Content ─────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.02, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(selectedIndex),
                child: pages[selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRail(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
    bool isDark,
    int inboxCount,
  ) {
    return Container(
      width: AppSizes.navRailWidth,
      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      child: Column(
        children: [
          // ── Logo ────────────────────────────
          const SizedBox(height: AppSizes.lg),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'P',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // ── Nav Items ───────────────────────
          _NavItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: '대시보드',
            isSelected: selectedIndex == 0,
            onTap: () => ref.read(selectedNavIndexProvider.notifier).set(0),
          ),

          const SizedBox(height: AppSizes.xs),

          _NavItem(
            icon: Icons.folder_outlined,
            selectedIcon: Icons.folder,
            label: '프로젝트',
            color: AppColors.projects,
            isSelected: selectedIndex == 1,
            onTap: () => ref.read(selectedNavIndexProvider.notifier).set(1),
          ),

          const SizedBox(height: AppSizes.xs),

          _NavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: '영역',
            color: AppColors.areas,
            isSelected: selectedIndex == 2,
            onTap: () => ref.read(selectedNavIndexProvider.notifier).set(2),
          ),

          const SizedBox(height: AppSizes.xs),

          _NavItem(
            icon: Icons.book_outlined,
            selectedIcon: Icons.book,
            label: '자료',
            color: AppColors.resources,
            isSelected: selectedIndex == 3,
            onTap: () => ref.read(selectedNavIndexProvider.notifier).set(3),
          ),

          const SizedBox(height: AppSizes.xs),

          _NavItem(
            icon: Icons.archive_outlined,
            selectedIcon: Icons.archive,
            label: '보관함',
            color: AppColors.archive,
            isSelected: selectedIndex == 4,
            onTap: () => ref.read(selectedNavIndexProvider.notifier).set(4),
          ),

          // ── Divider ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.md,
            ),
            child: Divider(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),

          _NavItem(
            icon: Icons.inbox_outlined,
            selectedIcon: Icons.inbox,
            label: '인박스',
            color: AppColors.inbox,
            isSelected: selectedIndex == 5,
            badgeCount: inboxCount,
            onTap: () => ref.read(selectedNavIndexProvider.notifier).set(5),
          ),

          const Spacer(),

          // ── Theme Toggle ────────────────────
          _NavItem(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            selectedIcon: isDark ? Icons.light_mode : Icons.dark_mode,
            label: isDark ? '라이트' : '다크',
            isSelected: false,
            onTap: () => ref.read(themeModeProvider.notifier).toggle(),
          ),

          // ── Settings ───────────────────────
          _NavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: '설정',
            isSelected: selectedIndex == 6,
            onTap: () => ref.read(selectedNavIndexProvider.notifier).set(6),
          ),

          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }
}

/// 네비게이션 아이템 위젯
class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color? color;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.color,
    required this.isSelected,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? activeColor.withValues(alpha: 0.12)
                : _isHovered
                    ? activeColor.withValues(alpha: 0.06)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: widget.badgeCount > 0,
                label: Text(
                  '${widget.badgeCount}',
                  style: const TextStyle(fontSize: 10),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.isSelected ? widget.selectedIcon : widget.icon,
                    key: ValueKey(widget.isSelected),
                    color: widget.isSelected
                        ? activeColor
                        : Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: widget.isSelected
                      ? activeColor
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
