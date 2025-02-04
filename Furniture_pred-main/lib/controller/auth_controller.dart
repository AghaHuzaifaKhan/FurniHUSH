import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login method
  Future<UserCredential?> loginMethod(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Signup method
  Future<UserCredential?> signupMethod(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Signup error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Store user data
  Future<void> storeUserData(
      String name, String email, String phone, String address) async {
    await _firestore.collection('users').doc(_auth.currentUser?.uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'createdAt': Timestamp.now(),
      'cart': [],
      'wishlist': [],
      'orders': [],
    });
  }

  // Signout method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  //profile data store
  Future<void> storeProfileData(String name, String email, String password,
      String phone, String image, String address) async {
    await _firestore.collection('users').doc(_auth.currentUser?.uid).set({
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'image': image,
      'address': address,
    });
  }

  //forgot password
  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Listen to auth state changes
  Stream<User?> authStateChanges() => _auth.authStateChanges();
  //manage items
  Future<void> addItem(String name, Map<String, dynamic> data) async {
    await _firestore.collection('current_stock').doc(name).set(data);
  }

  //stock management
  Future<void> updateItem(String name, Map<String, dynamic> data) async {
    await _firestore.collection('current_stock').doc(name).update(data);
  }
}
