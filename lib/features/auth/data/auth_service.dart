import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);

      // Save to Firestore on first login
      if (userCred.additionalUserInfo?.isNewUser ?? false) {
        await _saveUserToFirestore(userCred.user!);
      }

      return userCred.user;
    } catch (e) {
      rethrow;
    }
  }

  // Save user profile to Firestore
  Future<void> _saveUserToFirestore(User user) async {
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'interests': [],
      'savedEvents': [],
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Save interests after interest picker
  Future<void> saveInterests(List<String> interests) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).update({
      'interests': interests,
    });
  }

  // Save an event
  Future<void> saveEvent(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).update({
      'savedEvents': FieldValue.arrayUnion([eventId]),
    });
  }

  // Unsave an event
  Future<void> unsaveEvent(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).update({
      'savedEvents': FieldValue.arrayRemove([eventId]),
    });
  }

  // Get saved event IDs from Firestore
  Future<List<String>> getSavedEvents() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    final doc = await _db.collection('users').doc(user.uid).get();
    return List<String>.from(doc.data()?['savedEvents'] ?? []);
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

// Providers
final authServiceProvider =
    Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});