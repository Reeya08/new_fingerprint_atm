import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart'; // Import the UserModel class with email support

class AuthServices {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  Future<UserCredential> signUp(
      {required String email, required String password}){
    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }
  Future<UserCredential?> loginUser({
    required String email, // Use email for login
    required String pin,
  }) async {
    try {
      // Retrieve the user by email
      final user = await fetchUserByEmail(email);

      if (user != null) {
        // Validate the PIN
        if (user.pin == pin) {
          // If the PIN is correct, sign in the user
          return await FirebaseAuth.instance.signInAnonymously();
        }
      }

      // Return null if login is unsuccessful (wrong email or PIN)
      return null;
    } catch (e) {
      // Handle errors, e.g., user not found, authentication failure, etc.
      print("Login failed: $e");
      return null;
    }

  }

  Future<UserModel?> fetchUserByEmail(String email) async {
    try {
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final userSnapshot = await usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // If a user with the provided email exists, retrieve and return the UserModel.
        final userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      }

      // Return null if no user is found with the specified email.
      return null;
    } catch (e) {
      print("Error fetching user by email: $e");
      return null;
    }
  }
}
