import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.firebaseReady = true});

  final bool firebaseReady;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _authenticate(Future<void> Function() action) async {
    if (!widget.firebaseReady) {
      _showError('Firebase iOS 설정이 필요해요. GoogleService-Info.plist를 추가해 주세요.');
      return;
    }
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      if (mounted) _showError(_messageFor(error));
    } catch (_) {
      if (mounted) _showError('로그인 중 문제가 발생했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'account-exists-with-different-credential':
        return '같은 이메일로 가입된 다른 로그인 방식이 있어요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해 주세요.';
      case 'popup-closed-by-user':
      case 'canceled':
        return '로그인이 취소됐어요.';
      default:
        return error.message ?? '로그인에 실패했어요.';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFFF26B38),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Expoodie',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '맛있는 경험을 발견하고\n친구들과 나눠보세요.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: Colors.black54, height: 1.5),
              ),
              const Spacer(flex: 3),
              _SocialButton(
                label: 'Google로 계속하기',
                leading: const Text(
                  'G',
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: _loading
                    ? null
                    : () => _authenticate(() async {
                        await AuthService.instance.signInWithGoogle();
                      }),
              ),
              const SizedBox(height: 22),
              const Text(
                '계속하면 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.leading,
    required this.onPressed,
  });

  final String label;
  final Widget leading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE7E2DD)),
          ),
          elevation: 0,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(alignment: Alignment.centerLeft, child: leading),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
