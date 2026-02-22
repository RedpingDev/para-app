import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/para_providers.dart';

/// 현재 선택된 네비게이션 인덱스
final selectedNavIndexProvider =
    NotifierProvider<SelectedNavIndexNotifier, int>(
      SelectedNavIndexNotifier.new,
    );

class SelectedNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

/// 600px 미만 → 모바일 하단 바 / 이상 → 사이드 레일
class MainLayout extends ConsumerWidget {
  final List<Widget> pages;

  const MainLayout({super.key, required this.pages});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return isMobile
        ? _MobileLayout(pages: pages)
        : _DesktopLayout(pages: pages);
  }
}

// ─────────────────────────────────────────
// 모바일 레이아웃 (BottomNavigationBar)
// ─────────────────────────────────────────

class _MobileLayout extends ConsumerWidget {
  final List<Widget> pages;
  const _MobileLayout({required this.pages});

  static const _bottomItems = [
    {
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
      'label': '대시보드',
      'index': 0,
      'color': AppColors.primary,
    },
    {
      'icon': Icons.folder_outlined,
      'activeIcon': Icons.folder,
      'label': '프로젝트',
      'index': 1,
      'color': AppColors.projects,
    },
    {
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
      'label': '영역',
      'index': 2,
      'color': AppColors.areas,
    },
    {
      'icon': Icons.book_outlined,
      'activeIcon': Icons.book,
      'label': '자료',
      'index': 3,
      'color': AppColors.resources,
    },
    {
      'icon': Icons.inbox_outlined,
      'activeIcon': Icons.inbox,
      'label': '인박스',
      'index': 5,
      'color': AppColors.inbox,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final isDark = ref.watch(themeModeProvider);
    final inboxCount = ref.watch(inboxProvider).length;

    // 하단 탭 → 실제 페이지 인덱스 매핑
    final tabToPage = _bottomItems.map((e) => e['index'] as int).toList();
    final currentTab = tabToPage.contains(selectedIndex)
        ? tabToPage.indexOf(selectedIndex)
        : 0;

    // 현재 탭의 색상
    final activeColor = _bottomItems[currentTab]['color'] as Color;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              _bottomItems[currentTab]['label'] as String,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // 다크/라이트 토글
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          // 설정
          IconButton(
            icon: Icon(
              selectedIndex == 6 ? Icons.settings : Icons.settings_outlined,
              color: selectedIndex == 6
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
            ),
            onPressed: () => ref.read(selectedNavIndexProvider.notifier).set(6),
          ),
          // 보관함
          IconButton(
            icon: Icon(
              selectedIndex == 4 ? Icons.archive : Icons.archive_outlined,
              color: selectedIndex == 4
                  ? AppColors.archive
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
            ),
            onPressed: () => ref.read(selectedNavIndexProvider.notifier).set(4),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey(selectedIndex),
          child: pages[selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentTab,
          onTap: (tab) {
            final pageIndex = tabToPage[tab];
            ref.read(selectedNavIndexProvider.notifier).set(pageIndex);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightSurfaceVariant,
          selectedItemColor: activeColor,
          unselectedItemColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: _bottomItems.map((item) {
            final isInbox = item['index'] == 5;
            return BottomNavigationBarItem(
              icon: isInbox && inboxCount > 0
                  ? Badge(
                      label: Text(
                        '$inboxCount',
                        style: const TextStyle(fontSize: 9),
                      ),
                      child: Icon(item['icon'] as IconData),
                    )
                  : Icon(item['icon'] as IconData),
              activeIcon: isInbox && inboxCount > 0
                  ? Badge(
                      label: Text(
                        '$inboxCount',
                        style: const TextStyle(fontSize: 9),
                      ),
                      child: Icon(item['activeIcon'] as IconData),
                    )
                  : Icon(item['activeIcon'] as IconData),
              label: item['label'] as String,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 데스크탑/태블릿 레이아웃 (Side NavRail)
// ─────────────────────────────────────────

class _DesktopLayout extends ConsumerWidget {
  final List<Widget> pages;
  const _DesktopLayout({required this.pages});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final isDark = ref.watch(themeModeProvider);
    final inboxCount = ref.watch(inboxProvider).length;

    return Scaffold(
      body: Row(
        children: [
          _buildNavRail(context, ref, selectedIndex, isDark, inboxCount),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.02, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
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
      color: isDark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      child: Column(
        children: [
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
          _NavItem(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            selectedIcon: isDark ? Icons.light_mode : Icons.dark_mode,
            label: isDark ? '라이트' : '다크',
            isSelected: false,
            onTap: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
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
                        : Theme.of(context).textTheme.bodySmall?.color,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
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
