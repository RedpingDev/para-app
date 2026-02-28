import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../services/auth_service.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── 로고 영역 ────────────────────
              Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.layers_outlined,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                  ),

              const SizedBox(height: AppSizes.xl),

              Text(
                'PARA',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 36,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              const SizedBox(height: AppSizes.sm),

              Text(
                'Projects · Areas · Resources · Archive',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkTextMuted,
                  letterSpacing: 1.2,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

              const SizedBox(height: AppSizes.xl * 2),

              // ── 구글 로그인 버튼 ─────────────
              _GoogleSignInButton(
                    onPressed: () async {
                      final service = ref.read(authServiceProvider);
                      await service.signInWithGoogle();
                    },
                  )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSizes.xl),

              Text(
                '개인 생산성 관리 시스템',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.darkTextMuted),
              ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _GoogleSignInButton({required this.onPressed});

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _isLoading
            ? null
            : () async {
                setState(() => _isLoading = true);
                widget.onPressed();
                if (mounted) setState(() => _isLoading = false);
              },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.darkBorder.withValues(alpha: 2)),
          backgroundColor: AppColors.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google 로고 (SVG 대신 텍스트 로고로 표현)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: Color(0xFF4285F4),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Text(
                    'Google 계정으로 로그인',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
