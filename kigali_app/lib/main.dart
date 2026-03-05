import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as ap;
import 'providers/listing_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'home_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const KigaliApp());
}

class KigaliApp extends StatelessWidget {
  const KigaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ap.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
      ],
      child: MaterialApp(
        title: 'Kigali City Directory',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<ap.AuthProvider>(
      builder: (_, auth, __) {
        switch (auth.status) {
          case ap.AuthStatus.initial:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          case ap.AuthStatus.authenticated:
            return const HomeScreen();
          case ap.AuthStatus.emailNotVerified:
            return const VerifyEmailScreen();
          case ap.AuthStatus.unauthenticated:
          case ap.AuthStatus.error:
          case ap.AuthStatus.loading:
            return const LoginScreen();
        }
      },
    );
  }
}
