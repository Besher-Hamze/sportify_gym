import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportify_gym_porject/screens/auth/login_screen.dart';
import 'package:sportify_gym_porject/screens/home_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final email = ''.obs;
  final password = ''.obs;
  final name = ''.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  final formKey = GlobalKey<FormState>();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Firebase Sign In
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );

      // Navigate to home screen
      Get.offAll(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      }

      Get.snackbar(
        'Sign In Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign in: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Firebase Sign Up
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );

      // Save additional user information to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name.value,
        'email': email.value,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.offAll(HomeScreen());
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';

      if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists with this email';
      }

      Get.snackbar(
        'Sign Up Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign up: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method to handle sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAll(LoginScreen());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Check if user is already logged in
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}