import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/meal.dart';
import '../models/notification.dart';
import '../models/user.dart';

class AdminController extends GetxController {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instanceFor(bucket: "car-shop-2a53b.appspot.com");

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  // Collections references
  late CollectionReference<Map<String, dynamic>> _mealsCollection;
  late CollectionReference<Map<String, dynamic>> _usersCollection;
  late CollectionReference<Map<String, dynamic>> _notificationsCollection;

  // Observable lists
  final RxList<Meal> meals = <Meal>[].obs;
  final RxList<User> users = <User>[].obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  // Loading states
  final RxBool isLoadingMeals = false.obs;
  final RxBool isLoadingUsers = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isSendingNotification = false.obs;

  // Search states
  final RxString searchQuery = ''.obs;
  final RxString userSearchQuery = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);

  // Form Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final caloriesController = TextEditingController();
  final timeController = TextEditingController();
  final ingredientsController = TextEditingController();
  final notificationTitleController = TextEditingController();
  final notificationMessageController = TextEditingController();
  final proteinController = TextEditingController();
  final fiberController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeFirebase();
    fetchMeals();
    fetchUsers();
    fetchNotifications();
  }

  void _initializeFirebase() {
    _mealsCollection = _firestore.collection('meals');
    _usersCollection = _firestore.collection('users');
    _notificationsCollection = _firestore.collection('notifications');
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      _handleError('Failed to pick image', e);
    }
  }

  void showImageSourceDialog() {
    print("object");
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    pickImage(ImageSource.camera);
                  },
                ),
                _buildImageSourceButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade50,
            child: Icon(
              icon,
              color: Colors.blue,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage(File image, String mealId) async {
    try {
      final ref = _storage.ref().child('meals/$mealId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      _handleError('Failed to upload image', e);
      return null;
    }
  }

  // Meals Management Methods
  Future<void> fetchMeals() async {
    try {
      isLoadingMeals.value = true;
      final snapshot = await _firestore.collection('meals').get();

      meals.value = snapshot.docs.map((doc) {
        return Meal.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print(e);
      _handleError('Failed to fetch meals', e);
    } finally {
      isLoadingMeals.value = false;
    }
  }

  Future<void> addMeal() async {
    if (!_validateMealForm()) return;

    try {
      isProcessing.value = true;

      // Create new document reference
      final docRef = _firestore.collection('meals').doc();
      String imageUrl = 'assets/images/default_meal.jpg';

      // Upload image if selected
      if (selectedImage.value != null) {
        final uploadedUrl = await _uploadImage(selectedImage.value!, docRef.id);
        if (uploadedUrl != null) imageUrl = uploadedUrl;
      }

      // Prepare meal data
      final mealData = {
        'image': imageUrl,
        'title': titleController.text,
        'meal': titleController.text,
        'calories': caloriesController.text,
        'time': timeController.text,
        'ingredients':
            ingredientsController.text.split(',').map((e) => e.trim()).toList(),
        'price': double.parse(priceController.text),
        'rating': 0.0,
        'reviews': 0,
        'protein': proteinController.text,
        'fiber': fiberController.text,
        'carbs': carbsController.text,
        'fat': fatController.text,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      await docRef.set(mealData);

      // Update local state
      final newMeal = Meal.fromFirestore(mealData, docRef.id);
      meals.add(newMeal);

      // Reset form and image
      clearForm();
      Get.back(); // Close dialog
      _showSuccessSnackbar('Meal added successfully');
    } catch (e) {
      _handleError('Failed to add meal', e);
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> updateMeal(String mealId) async {
    if (!_validateMealForm()) return;

    try {
      isProcessing.value = true;

      // Find existing meal
      final existingMeal = meals.firstWhere((m) => m.id == mealId);
      String imageUrl = existingMeal.image;

      // Upload new image if selected
      if (selectedImage.value != null) {
        final uploadedUrl = await _uploadImage(selectedImage.value!, mealId);
        if (uploadedUrl != null) imageUrl = uploadedUrl;
      }

      // Prepare update data
      final updateData = {
        'image': imageUrl,
        'title': titleController.text,
        'meal': titleController.text,
        'calories': caloriesController.text,
        'time': timeController.text,
        'ingredients':
            ingredientsController.text.split(',').map((e) => e.trim()).toList(),
        'price': double.parse(priceController.text),
        'protein': proteinController.text,
        'fiber': fiberController.text,
        'carbs': carbsController.text,
        'fat': fatController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update in Firestore
      await _firestore.collection('meals').doc(mealId).update(updateData);

      // Update local state
      final index = meals.indexWhere((meal) => meal.id == mealId);
      if (index != -1) {
        meals[index] = Meal(
          id: mealId,
          image: imageUrl,
          title: titleController.text,
          meal: titleController.text,
          calories: caloriesController.text,
          time: timeController.text,
          ingredients: ingredientsController.text
              .split(',')
              .map((e) => e.trim())
              .toList(),
          price: double.parse(priceController.text),
          rating: existingMeal.rating,
          reviews: existingMeal.reviews,
          protein: proteinController.text,
          fiber: fiberController.text,
          carbs: carbsController.text,
          fat: fatController.text,
        );
      }

      // Reset form and image
      clearForm();
      Get.back(); // Close dialog
      _showSuccessSnackbar('Meal updated successfully');
    } catch (e) {
      _handleError('Failed to update meal', e);
    } finally {
      isProcessing.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    caloriesController.clear();
    timeController.clear();
    priceController.clear();
    ingredientsController.clear();
    proteinController.clear();
    fiberController.clear();
    carbsController.clear();
    fatController.clear();
    selectedImage.value = null;
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      // Delete from Firestore
      await _mealsCollection.doc(mealId).delete();

      // Delete image from storage
      try {
        await _storage.ref().child('meals/$mealId.jpg').delete();
      } catch (e) {
        // Ignore if image doesn't exist
      }

      // Update local state
      meals.removeWhere((meal) => meal.id == mealId);
      _showSuccessSnackbar('Meal deleted successfully');
    } catch (e) {
      _handleError('Failed to delete meal', e);
    }
  }

  // Users Management Methods
  Future<void> fetchUsers() async {
    try {
      isLoadingUsers.value = true;
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _usersCollection.get();

      users.value = snapshot.docs.map((doc) {
        return User.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      _handleError('Failed to fetch users', e);
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // Delete from Firestore
      await _usersCollection.doc(userId).delete();

      // Update local state
      users.removeWhere((user) => user.id == userId);
      _showSuccessSnackbar('User deleted successfully');
    } catch (e) {
      _handleError('Failed to delete user', e);
    }
  }

// Notification Methods in AdminController class

// Notification states
  final isLoadingNotifications = false.obs;
  final selectedNotificationType = 'all'.obs;

  Future<void> fetchNotifications() async {
    try {
      isLoadingNotifications.value = true;
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _notificationsCollection
              .orderBy('sentDate', descending: true)
              .get();

      notifications.value = snapshot.docs.map((doc) {
        return NotificationModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      _handleError('Failed to fetch notifications', e);
    } finally {
      isLoadingNotifications.value = false;
    }
  }

  Future<void> sendNotification() async {
    if (!_validateNotificationForm()) return;

    try {
      isSendingNotification.value = true;

      // Create notification data
      final notificationData = {
        'title': notificationTitleController.text.trim(),
        'message': notificationMessageController.text.trim(),
        'type': selectedNotificationType.value,
        'sentDate': FieldValue.serverTimestamp(),
        'sentBy': _auth.currentUser?.uid,
        'readBy': [],
        'status': 'sent',
      };

      // Add to Firestore
      await _notificationsCollection.add(notificationData);

      clearNotificationForm();
      Get.back();
      _showSuccessSnackbar('Notification sent successfully');
      fetchNotifications();
    } catch (e) {
      _handleError('Failed to send notification', e);
    } finally {
      isSendingNotification.value = false;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Notification'),
          content:
              const Text('Are you sure you want to delete this notification?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Delete from Firestore
      await _notificationsCollection.doc(notificationId).delete();

      // Update local state
      notifications
          .removeWhere((notification) => notification.id == notificationId);
      _showSuccessSnackbar('Notification deleted successfully');
    } catch (e) {
      _handleError('Failed to delete notification', e);
    }
  }

  Future<void> updateNotificationStatus(
      String notificationId, String status) async {
    try {
      // Update in Firestore
      await _notificationsCollection.doc(notificationId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updatedNotification =
            notifications[index].copyWith(status: status);
        notifications[index] = updatedNotification;
      }

      _showSuccessSnackbar('Notification status updated');
    } catch (e) {
      _handleError('Failed to update notification status', e);
    }
  }

  Future<void> markNotificationAsRead(
      String notificationId, String userId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'readBy': FieldValue.arrayUnion([userId]),
      });

      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final currentReadBy = List<String>.from(notifications[index].readBy);
        if (!currentReadBy.contains(userId)) {
          currentReadBy.add(userId);
          final updatedNotification =
              notifications[index].copyWith(readBy: currentReadBy);
          notifications[index] = updatedNotification;
        }
      }
    } catch (e) {
      _handleError('Failed to mark notification as read', e);
    }
  }

  int getTodayNotificationsCount() {
    final now = DateTime.now();
    return notifications.where((notification) {
      final notificationDate = notification.sentDate;
      return notificationDate.year == now.year &&
          notificationDate.month == now.month &&
          notificationDate.day == now.day;
    }).length;
  }

  bool _validateNotificationForm() {
    if (notificationTitleController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a notification title',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (notificationMessageController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a notification message',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  void clearNotificationForm() {
    notificationTitleController.clear();
    notificationMessageController.clear();
    selectedNotificationType.value = 'all';
  }

  // Helper Methods
  void setMealForEdit(Meal meal) {
    titleController.text = meal.title;
    caloriesController.text = meal.calories;
    timeController.text = meal.time;
    ingredientsController.text = meal.ingredients.join(', ');
    priceController.text = meal.price.toString();
    fatController.text = meal.fat.toString();
    proteinController.text = meal.protein.toString();
    fiberController.text = meal.fiber.toString();
    carbsController.text = meal.carbs.toString();
  }

  bool _validateMealForm() {
    if (titleController.text.isEmpty ||
        caloriesController.text.isEmpty ||
        timeController.text.isEmpty ||
        ingredientsController.text.isEmpty ||
        priceController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  // Search Methods
  void updateSearchQuery(String query) => searchQuery.value = query;

  void updateUserSearchQuery(String query) => userSearchQuery.value = query;

  List<Meal> get filteredMeals {
    if (searchQuery.value.isEmpty) return meals;
    return meals
        .where((meal) =>
            meal.title.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  List<User> get filteredUsers {
    if (userSearchQuery.value.isEmpty) return users;
    return users
        .where((user) =>
            user.name
                .toLowerCase()
                .contains(userSearchQuery.value.toLowerCase()) ||
            user.email
                .toLowerCase()
                .contains(userSearchQuery.value.toLowerCase()))
        .toList();
  }

  // Error Handling Helper
  void _handleError(String message, dynamic error) {
    print('$message: $error');
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Success Snackbar Helper
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Cleanup method to dispose controllers
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    caloriesController.dispose();
    timeController.dispose();
    ingredientsController.dispose();
    notificationTitleController.dispose();
    notificationMessageController.dispose();
    super.onClose();
  }
}
