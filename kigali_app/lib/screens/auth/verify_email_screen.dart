import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../theme.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    // Poll every 3 seconds — calls reload() on the Firebase user,
    // then notifyListeners() if verified. The Consumer below will rebuild.
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      await context.read<ap.AuthProvider>().checkEmailVerification();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use watch (not read) so this widget rebuilds when AuthProvider notifies.
    // When checkEmailVerification sets status = authenticated, the AuthGate
    // in main.dart will swap to HomeScreen automatically.
    final auth = context.watch<ap.AuthProvider>();
    final email = auth.user?.email ?? 'your email';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Icon ──────────────────────────────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.mark_email_unread_rounded,
                      color: AppColors.primary, size: 38),
                ),
              ),
              const SizedBox(height: 28),

              // ── Title ─────────────────────────────────────────────
              const Text(
                'Check your inbox',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a verification link to\n$email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Click the link in the email, then return here — this page will update automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 13, height: 1.5),
              ),

              const SizedBox(height: 40),

              // ── Polling indicator ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Waiting for verification…',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Resend ────────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: () async {
                  await context.read<ap.AuthProvider>().resendVerificationEmail();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification email resent!'),
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Resend verification email'),
              ),
              const SizedBox(height: 12),

              // ── Back to login ─────────────────────────────────────
              TextButton(
                onPressed: () => context.read<ap.AuthProvider>().signOut(),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}