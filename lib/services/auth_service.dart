import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;
  static String? get currentUserEmail => _auth.currentUser?.email;

  // Vérifier si l'utilisateur est admin
  static bool get isAdmin {
    final email = currentUserEmail?.toLowerCase();
    return email == 'admin@gmail.com';
  }

  static Future<bool> register(String email, String password, String nom) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await userCredential.user?.updateDisplayName(nom);
      return true;
    } catch (e) {
      print('Erreur inscription: $e');
      return false;
    }
  }

  static Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Succès
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Aucun utilisateur trouvé avec cet email.';
      } else if (e.code == 'wrong-password') {
        return 'Mot de passe incorrect.';
      }
      return 'Erreur de connexion: ${e.message}';
    } catch (e) {
      return 'Erreur: $e';
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}