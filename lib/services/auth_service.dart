import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isLoggedIn => _auth.currentUser != null;

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await credential.user?.updateDisplayName(name);

      await credential.user?.reload();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getMessage(e);
    } catch (_) {
      throw "Something went wrong.";
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _getMessage(e);
    } catch (_) {
      throw "Unable to login.";
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _getMessage(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _getMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';

      case 'email-already-in-use':
        return 'Email already exists';

      case 'weak-password':
        return 'Password is too weak';

      case 'user-not-found':
        return 'User not found';

      case 'wrong-password':
        return 'Incorrect password';

      case 'invalid-credential':
        return 'Invalid email or password';

      case 'network-request-failed':
        return 'No internet connection';

      case 'too-many-requests':
        return 'Too many attempts. Try again later.';

      default:
        return e.message ?? 'Authentication failed';
    }
  }
}