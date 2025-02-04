import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furnihush/models/cart_item.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    clientId:
        '796653433533-b0g4kb40mrij4jea4gkcas9t8n7mpklp.apps.googleusercontent.com',
  );

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

  // Google Sign In method
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Sign out first to show account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      try {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);

        // Store user data in Firestore
        if (userCredential.user != null) {
          final userDoc = await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          if (!userDoc.exists) {
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'name': googleUser.displayName ?? '',
              'email': googleUser.email,
              'image': googleUser.photoUrl ?? '',
              'createdAt': Timestamp.now(),
              'cart': [],
              'wishlist': [],
              'orders': [],
            });
          }
        }

        notifyListeners();
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
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // store cart data
  Future<void> storeCartData(List<CartItem> cartItems) async {
    await _firestore.collection('cart').doc(_auth.currentUser?.uid).set({
      'items': cartItems
          .map((item) => {
                'id': item.id,
                'name': item.name,
                'price': item.price,
                'image': item.image,
                'quantity': item.quantity,
              })
          .toList(),
    });
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

  //payment method
  Future<void> addPaymentMethod(String cardNumber) async {
    final maskedNumber =
        '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
      'paymentMethods': FieldValue.arrayUnion([maskedNumber])
    });
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Listen to auth state changes
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
