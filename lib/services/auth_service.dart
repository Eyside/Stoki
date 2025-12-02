// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream de l'état de connexion
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Inscription avec email/mot de passe
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour le profil
      await credential.user?.updateDisplayName(displayName);

      // Créer le document utilisateur dans Firestore
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('Erreur inscription: ${e.code} - ${e.message}');
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      print('Erreur inscription: $e');
      throw 'Une erreur est survenue lors de l\'inscription';
    }
  }

  // Connexion avec email/mot de passe
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour la dernière connexion
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('Erreur connexion: ${e.code} - ${e.message}');
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      print('Erreur connexion: $e');
      throw 'Une erreur est survenue lors de la connexion';
    }
  }

  // Connexion avec Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Déclencher le flux d'authentification
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // L'utilisateur a annulé la connexion
        return null;
      }

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Créer un nouveau credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Se connecter à Firebase avec le credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Créer ou mettre à jour le document utilisateur
      if (userCredential.user != null) {
        final userDoc = _firestore.collection('users').doc(userCredential.user!.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          // Créer le document pour un nouvel utilisateur
          await userDoc.set({
            'email': userCredential.user!.email,
            'displayName': userCredential.user!.displayName,
            'photoURL': userCredential.user!.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
        } else {
          // Mettre à jour la dernière connexion
          await userDoc.update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      print('Erreur connexion Google: $e');
      throw 'Une erreur est survenue lors de la connexion avec Google';
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Erreur déconnexion: $e');
      throw 'Une erreur est survenue lors de la déconnexion';
    }
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Erreur reset password: ${e.code}');
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      print('Erreur reset password: $e');
      throw 'Une erreur est survenue';
    }
  }

  // Supprimer le compte
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Supprimer le document Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Supprimer le compte Firebase Auth
        await user.delete();
      }
    } catch (e) {
      print('Erreur suppression compte: $e');
      throw 'Une erreur est survenue lors de la suppression du compte';
    }
  }

  // Messages d'erreur en français
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'Email invalide';
      case 'operation-not-allowed':
        return 'Opération non autorisée';
      case 'weak-password':
        return 'Mot de passe trop faible (min. 6 caractères)';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion';
      default:
        return 'Une erreur est survenue';
    }
  }
}