import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, emailNotVerified, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  UserProfile? _userProfile;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _userProfile = null;
    } else if (!user.emailVerified) {
      _status = AuthStatus.emailNotVerified;
    } else {
      _status = AuthStatus.authenticated;
      await _loadUserProfile();
    }
    notifyListeners();
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    _userProfile = await _authService.getUserProfile(_user!.uid);
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _status = AuthStatus.emailNotVerified;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signIn(email: email, password: password);
      await credential.user?.reload();
      _user = credential.user;
      
      if (_user != null && !_user!.emailVerified) {
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return false;
      }
      
      _status = AuthStatus.authenticated;
      await _loadUserProfile();
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> resendVerificationEmail() async {
    await _authService.sendVerificationEmail();
  }

  Future<void> checkEmailVerification() async {
    await _authService.reloadUser();
    _user = _authService.currentUser;
    if (_user?.emailVerified == true) {
      _status = AuthStatus.authenticated;
      await _loadUserProfile();
      notifyListeners();
    }
  }

  Future<void> updateNotifications(bool enabled) async {
    if (_user == null) return;
    await _authService.updateNotificationPreference(_user!.uid, enabled);
    _userProfile = _userProfile?.copyWith(notificationsEnabled: enabled);
    notifyListeners();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No user found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'Email is already registered.';
      case 'weak-password': return 'Password is too weak (min 6 characters).';
      case 'invalid-email': return 'Invalid email address.';
      case 'too-many-requests': return 'Too many attempts. Please try later.';
      default: return e.message ?? 'Authentication failed.';
    }
  }
}
