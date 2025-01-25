import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furnihush/screens/auth/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Login method
  Future<UserCredential?> loginMethod(String email, String password) async {
    try {
      // Sign in first
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      try {
        // Then check Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();

        if (!userDoc.exists) {
          // Create user document if it doesn't exist
          await _firestore
              .collection('users')
              .doc(userCredential.user?.uid)
              .set({
            'email': email,
            'createdAt': Timestamp.now(),
          });
        }
      } catch (e) {
        debugPrint('Firestore error: $e');
        // Continue even if Firestore fails
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected login error: $e');
      rethrow;
    }
  }

  // Google Sign In method
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Begin interactive sign in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancels sign in, return null
      if (googleUser == null) return null;

      try {
        // Obtain auth details from request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential for Firebase
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        final userCredential = await _auth.signInWithCredential(credential);

        // Store user data in Firestore if it doesn't exist
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();

        if (!userDoc.exists) {
          await _firestore
              .collection('users')
              .doc(userCredential.user?.uid)
              .set({
            'name': googleUser.displayName ?? '',
            'email': googleUser.email,
            'image': googleUser.photoUrl ?? '',
            'createdAt': Timestamp.now(),
          });
        }

        return userCredential;
      } catch (e) {
        debugPrint('Google auth error: $e');
        await googleUser.clearAuthCache();
        rethrow;
      }
    } catch (e) {
      debugPrint('Google Sign In error: $e');
      rethrow;
    }
  }

  // Signup method
  Future<UserCredential?> signupMethod(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential;
    } catch (e) {
      debugPrint('Signup error: $e');
      rethrow;
    }
  }

  // Store user data
  Future<void> storeUserData(
    String name,
    String email,
    String password,
    String image,
    String address,
  ) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser?.uid).set({
        'name': name,
        'email': email,
        'password': password,
        'image': image,
        'address': address,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Store user data error: $e');
      rethrow;
    }
  }

  // Signout method
  Future<void> signOutMethod(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      debugPrint('Signout error: $e');
    }
  }
}
