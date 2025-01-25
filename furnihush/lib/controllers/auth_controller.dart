import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furnihush/consts/firebase_consts.dart';
import 'package:furnihush/screens/auth/login_screen.dart';

class AuthController {
  //login method
  Future<UserCredential?> loginMethod(String email, String password) async {
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
    }
    return userCredential;
  }
  //signup method

  Future<UserCredential?> signupMethod(String email, String password) async {
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
    }
    return userCredential;
  }

  //storing user data
  storeUserData(name, email, password, image, address) async {
    DocumentReference store =
        firestore.collection(usersCollection).doc(currentUser!.uid);
    await store.set({
      'name': name,
      'email': email,
      'password': password,
      'image': image,
      'address': address,
    });
  }

  //signout method
  signOutMethod(context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
