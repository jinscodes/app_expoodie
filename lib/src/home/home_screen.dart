import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final name = user.displayName?.trim();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expoodie'),
        actions: [
          PopupMenuButton<_AccountAction>(
            onSelected: (action) => _handleAction(context, action),
            itemBuilder: (context) => const [
              PopupMenuItem(value: _AccountAction.signOut, child: Text('로그아웃')),
              PopupMenuItem(value: _AccountAction.delete, child: Text('계정 탈퇴')),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundImage: user.photoURL == null
                  ? null
                  : NetworkImage(user.photoURL!),
              child: user.photoURL == null
                  ? const Icon(Icons.person_rounded, size: 42)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              name == null || name.isEmpty ? '환영합니다!' : '$name님, 반가워요!',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (user.email != null)
              Text(user.email!, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    _AccountAction action,
  ) async {
    if (action == _AccountAction.signOut) {
      await AuthService.instance.signOut();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정을 탈퇴할까요?'),
        content: const Text('계정과 연결된 정보가 삭제되며 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await AuthService.instance.deleteAccount();
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;
      final message = error.code == 'requires-recent-login'
          ? '보안을 위해 로그아웃 후 다시 로그인한 뒤 탈퇴해 주세요.'
          : '계정 탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

enum _AccountAction { signOut, delete }
