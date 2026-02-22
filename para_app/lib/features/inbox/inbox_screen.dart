import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/para_providers.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inboxItems = ref.watch(inboxProvider);
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
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.inbox.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: const Icon(Icons.inbox, color: AppColors.inbox, size: 22),
                ),
                const SizedBox(width: AppSizes.md),
                Text('인박스', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(width: AppSizes.md),
                if (inboxItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.inbox.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text('${inboxItems.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inbox)),
                  ),
              ],
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: AppSizes.xl),

            // Quick capture input
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: AppColors.inbox),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '떠오르는 생각을 빠르게 기록하세요...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          ref.read(inboxProvider.notifier).add(value.trim());
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        ref.read(inboxProvider.notifier).add(_controller.text.trim());
                        _controller.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.inbox),
                    child: const Text('캡처'),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSizes.xl),

            Expanded(
              child: inboxItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          const SizedBox(height: AppSizes.lg),
                          Text('인박스가 비어있습니다', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: AppSizes.sm),
                          Text('떠오르는 생각을 빠르게 여기에 기록하고\n나중에 적절한 카테고리로 분류하세요.',
                            style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: inboxItems.length,
                      itemBuilder: (context, index) {
                        final item = inboxItems[index];
                        return Dismissible(
                          key: Key(item.id),
                          background: Container(
                            margin: const EdgeInsets.only(bottom: AppSizes.sm),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: AppSizes.xl),
                            child: const Icon(Icons.delete, color: AppColors.error),
                          ),
                          onDismissed: (_) => ref.read(inboxProvider.notifier).remove(item.id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: AppSizes.sm),
                            padding: const EdgeInsets.all(AppSizes.lg),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.inbox,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.md),
                                Expanded(child: Text(item.content, style: Theme.of(context).textTheme.bodyLarge)),
                                const SizedBox(width: AppSizes.md),
                                Text(
                                  _formatTime(item.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(width: AppSizes.sm),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => ref.read(inboxProvider.notifier).remove(item.id),
                                  tooltip: '삭제',
                                ),
                              ],
                            ),
                          ).animate()
                              .fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms)
                              .slideX(begin: 0.05, end: 0),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}
