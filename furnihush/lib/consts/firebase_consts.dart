import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase instances
final auth = FirebaseAuth.instance;
final firestore = FirebaseFirestore.instance;
User? currentUser = auth.currentUser;

// Collections
const usersCollection = 'users';
const productsCollection = 'products';
const cartCollection = 'cart';
const wishlistCollection = 'wishlist';
const ordersCollection = 'orders';

// Add reCAPTCHA configuration
const reCaptchaKey =
    'your-recaptcha-site-key'; // Get this from Firebase Console
