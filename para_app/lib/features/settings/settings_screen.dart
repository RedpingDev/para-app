import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/para_providers.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: SingleChildScrollView(
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
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Text('설정', style: Theme.of(context).textTheme.displayMedium),
              ],
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: AppSizes.xxl),

            // Account
            if (user != null)
              _SettingsSection(
                title: '계정',
                isDark: isDark,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                          child: user.photoURL == null
                              ? const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? '사용자',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                user.email ?? '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('로그아웃'),
                                content: const Text('정말 로그아웃 하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('취소'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                    ),
                                    child: const Text('로그아웃'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await ref.read(authServiceProvider).signOut();
                            }
                          },
                          icon: const Icon(
                            Icons.logout,
                            size: 16,
                            color: AppColors.error,
                          ),
                          label: const Text(
                            '로그아웃',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 50.ms, duration: 400.ms),

            if (user != null) const SizedBox(height: AppSizes.lg),

            // Theme
            _SettingsSection(
              title: '외관',
              isDark: isDark,
              children: [
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  title: '테마',
                  subtitle: isDark ? '다크 모드' : '라이트 모드',
                  isDark: isDark,
                  trailing: Switch(
                    value: isDark,
                    onChanged: (v) =>
                        ref.read(themeModeProvider.notifier).set(v),
                    activeThumbColor: AppColors.primary,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: AppSizes.lg),

            // Data
            _SettingsSection(
              title: '데이터',
              isDark: isDark,
              children: [
                _SettingsTile(
                  icon: Icons.download_outlined,
                  title: '데이터 내보내기',
                  subtitle: 'JSON 형식으로 내보내기',
                  isDark: isDark,
                  trailing: const Icon(Icons.chevron_right, size: 20),
                ),
                _SettingsTile(
                  icon: Icons.upload_outlined,
                  title: '데이터 가져오기',
                  subtitle: 'JSON 파일에서 가져오기',
                  isDark: isDark,
                  trailing: const Icon(Icons.chevron_right, size: 20),
                ),
                _SettingsTile(
                  icon: Icons.backup_outlined,
                  title: '백업',
                  subtitle: '로컬 백업 저장',
                  isDark: isDark,
                  trailing: const Icon(Icons.chevron_right, size: 20),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: AppSizes.lg),

            // About
            _SettingsSection(
              title: '정보',
              isDark: isDark,
              children: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'PARA Management System',
                  subtitle: 'v1.0.0 • Flutter',
                  isDark: isDark,
                ),
                _SettingsTile(
                  icon: Icons.favorite_outline,
                  title: 'PARA 방법론',
                  subtitle: 'by Tiago Forte',
                  isDark: isDark,
                ),
              ],
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSizes.md),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              return Column(
                children: [
                  if (entry.key > 0)
                    Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  entry.value,
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
