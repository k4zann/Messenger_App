import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseStore = FirebaseFirestore.instance;

  Future<UserCredential> login(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': userCredential.user!.displayName,
        'email': email,
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<UserCredential> register(String name, String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get a reference to the 'users' collection
      CollectionReference users = _firebaseStore.collection('users');

      // Add user data to Firestore with an auto-generated document ID
      DocumentReference userDocRef = await users.add({
        'name': name,
        'email': email,
      });

      // Get the auto-generated document ID and use it as an integer ID
      int userId = userDocRef.id as int;

      // Update the document with the integer ID
      await userDocRef.update({'id': userId});

      return userCredential;

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }



  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}