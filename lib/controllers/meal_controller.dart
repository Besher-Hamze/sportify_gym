import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportify_gym_porject/screens/order_history.dart';

import '../models/meal.dart';

class MealController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final meals = <Meal>[].obs;
  final favoriteIds = <String>{}.obs;
  final cartItems = <String, int>{}.obs;
  final orderHistory = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;
  final totalAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMeals();
    _loadFavorites();
    _loadCartItems();
    _loadOrderHistory();
  }

  Future<void> _loadMeals() async {
    try {
      isLoading.value = true;

      final mealsSnapshot = await _firestore.collection('meals').get();
      meals.value = mealsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Meal(
          id: doc.id,
          image: data['image'] ?? '',
          title: data['title'] ?? '',
          meal: data['meal'] ?? '',
          calories: data['calories'] ?? '',
          time: data['time'] ?? '',
          ingredients: List<String>.from(data['ingredients'] ?? []),
          price: (data['price'] ?? 0.0).toDouble(),
          rating: (data['rating'] ?? 0.0).toDouble(),
          reviews: data['reviews'] ?? 0,
          carbs: data['carbs'],
          fat: data['fat'],
          fiber: data['fiber'],
          protein: data['protein'],
        );
      }).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load meals. Using default data.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final favoritesDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      favoriteIds.value = favoritesDoc.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _loadCartItems() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final cartDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      cartItems.value = {
        for (var doc in cartDoc.docs) doc.id: doc.data()['quantity'] ?? 0
      };
      _updateTotalAmount();
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }

// Add this to your MealController class

  Future<void> _loadOrderHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final ordersSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .orderBy('date', descending: true)
          .get();

      orderHistory.value = ordersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'orderId': doc.id,
        };
      }).toList();
    } catch (e) {
      print('Error loading order history: $e');
      Get.snackbar(
        'Error',
        'Failed to load order history',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Favorite functionality
  Future<void> toggleFavorite(String mealId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'Please log in to use favorites',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final favoriteRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(mealId);

      if (favoriteIds.contains(mealId)) {
        await favoriteRef.delete();
        favoriteIds.remove(mealId);
      } else {
        await favoriteRef.set({'addedAt': FieldValue.serverTimestamp()});
        favoriteIds.add(mealId);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool isFavorite(String mealId) => favoriteIds.contains(mealId);

  Future<void> addToCart(String mealId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'Please log in to use cart',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Get meal information
      final meal = meals.firstWhere(
        (m) => m.id == mealId,
        orElse: () => throw Exception('Meal not found'),
      );

      // Reference to user's cart
      final cartRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(mealId);

      // Get current cart item
      final cartDoc = await cartRef.get();
      int currentQuantity = 0;

      if (cartDoc.exists) {
        currentQuantity = cartDoc.data()?['quantity'] ?? 0;
      }

      currentQuantity++;

      // Prepare cart item data
      final cartItemData = {
        'quantity': currentQuantity,
        'mealId': mealId,
        'name': meal.meal,
        'price': meal.price,
        'lastUpdated': DateTime.now(),
      };

      // Update Firestore
      await cartRef.set(cartItemData, SetOptions(merge: true));

      // Update local state
      cartItems[mealId] = currentQuantity;

      // Update total amount
      _updateTotalAmount();
    } catch (e) {
      print('Error adding to cart: $e');
      Get.snackbar(
        'Error',
        'Failed to add to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _updateTotalAmount() {
    try {
      double total = 0;
      cartItems.forEach((mealId, quantity) {
        final meal = meals.firstWhere(
          (m) => m.id == mealId,
          orElse: () => throw Exception('Meal not found'),
        );
        total += meal.price * quantity;
      });
      totalAmount.value = total;
    } catch (e) {
      print('Error updating total amount: $e');
      totalAmount.value = 0;
    }
  }

// Helper method to check if item can be added to cart
  bool canAddToCart(String mealId) {
    final currentQuantity = cartItems[mealId] ?? 0;
    return currentQuantity < 99; // Maximum quantity limit
  }

  Future<void> removeFromCart(String mealId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final cartRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(mealId);

      int currentQuantity = cartItems[mealId] ?? 0;
      if (currentQuantity > 1) {
        currentQuantity--;
        await cartRef.update({'quantity': currentQuantity});
        cartItems[mealId] = currentQuantity;
      } else {
        await cartRef.delete();
        cartItems.remove(mealId);
      }

      _updateTotalAmount();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove from cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> clearCart() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final cartCollection =
          _firestore.collection('users').doc(user.uid).collection('cart');

      // Delete all cart items
      final batch = _firestore.batch();
      final cartDocs = await cartCollection.get();
      for (var doc in cartDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      cartItems.clear();
      totalAmount.value = 0;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> processPayment(Map<String, dynamic> order) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      isLoading.value = true;

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Update order status in Firestore
      final orderRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(order['orderId']);

      final updatedOrder = Map<String, dynamic>.from(order);
      updatedOrder['status'] = 'confirmed';
      updatedOrder['paymentDate'] = DateTime.now();

      // Update in Firestore
      await orderRef.update(updatedOrder);

      // Update local order history
      final orderIndex =
          orderHistory.indexWhere((o) => o['orderId'] == order['orderId']);
      if (orderIndex != -1) {
        orderHistory[orderIndex] = updatedOrder;
      }

      Get.snackbar(
        'Success',
        'Payment processed successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // After 5 seconds, update to delivered
      Future.delayed(const Duration(seconds: 5), () {
        updateOrderStatus(order['orderId'], 'delivered');
      });
    } catch (e) {
      print('Error processing payment: $e');
      Get.snackbar(
        'Error',
        'Failed to process payment. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Update in Firestore
      final orderRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(orderId);

      await orderRef.update({
        'status': newStatus,
        'lastUpdated': DateTime.now(),
      });

      // Update local order history
      final orderIndex =
          orderHistory.indexWhere((order) => order['orderId'] == orderId);
      if (orderIndex != -1) {
        final updatedOrder =
            Map<String, dynamic>.from(orderHistory[orderIndex]);
        updatedOrder['status'] = newStatus;
        updatedOrder['lastUpdated'] = DateTime.now();
        orderHistory[orderIndex] = updatedOrder;
      }

      // Show success message for status update
      Get.snackbar(
        'Status Updated',
        'Order status changed to $newStatus',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error updating order status: $e');
      Get.snackbar(
        'Error',
        'Failed to update order status',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> placeOrder() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'Please log in to place an order',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (cartItems.isEmpty) {
        Get.snackbar(
          'Error',
          'Your cart is empty',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      // Create order in Firestore
      final ordersRef =
          _firestore.collection('users').doc(user.uid).collection('orders');

      // Create order object
      dynamic orderData = {
        'orderId': DateTime.now().millisecondsSinceEpoch.toString(),
        'date': DateTime.now(),
        'items': cartItems.entries.map((entry) {
          final meal = meals.firstWhere((m) => m.id == entry.key);
          return {
            'mealId': entry.key,
            'name': meal.meal,
            'quantity': entry.value,
            'price': meal.price,
          };
        }).toList(),
        'status': 'pending',
        'totalAmount': totalAmount.value,
        'userId': user.uid,
      };

      // Add to Firestore
      await ordersRef.doc(orderData['orderId']).set(orderData);

      // Add to local order history
      orderHistory.add(orderData);

      // Clear cart after successful order creation
      await clearCart();

      Get.snackbar(
        'Success',
        'Order placed successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate to order history
      Get.to(OrderHistoryScreen());
    } catch (e) {
      print('Error placing order: $e');
      Get.snackbar(
        'Error',
        'Failed to place order. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Existing filtering and getter methods remain the same
  List<Meal> get filteredMeals {
    return meals.where((meal) {
      final matchesSearch =
          meal.meal.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesCategory = selectedCategory.value == 'All' ||
          meal.title == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<Meal> get favoriteMeals {
    return meals.where((meal) => favoriteIds.contains(meal.id)).toList();
  }

  List<Map<String, dynamic>> get cartMeals {
    return cartItems.entries.map((entry) {
      final meal = meals.firstWhere((m) => m.id == entry.key);
      return {
        'meal': meal,
        'quantity': entry.value,
        'total': meal.price * entry.value,
      };
    }).toList();
  }

  // Rating functionality
  Future<void> rateMeal(String mealId, double rating, String review) async {
    try {
      isLoading.value = true;

      // Update meal rating in Firestore
      final mealRef = _firestore.collection('meals').doc(mealId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(mealRef);

        if (!snapshot.exists) {
          throw Exception('Meal does not exist!');
        }

        final currentRating = snapshot.data()?['rating'] ?? 0.0;
        final currentReviews = snapshot.data()?['reviews'] ?? 0;

        final totalRating = currentRating * currentReviews + rating;
        final totalReviews = currentReviews + 1;
        final newRating = totalRating / totalReviews;

        transaction.update(mealRef, {
          'rating': newRating,
          'reviews': totalReviews,
        });

        // Update local meal data
        final index = meals.indexWhere((meal) => meal.id == mealId);
        if (index != -1) {
          final meal = meals[index];
          meals[index] = Meal(
              id: meal.id,
              image: meal.image,
              title: meal.title,
              meal: meal.meal,
              calories: meal.calories,
              time: meal.time,
              ingredients: meal.ingredients,
              price: meal.price,
              rating: newRating,
              reviews: totalReviews,
              carbs: meal.carbs,
              fat: meal.fat,
              fiber: meal.fiber,
              protein: meal.protein);
        }
      });

      // Optionally save review details
      await _firestore
          .collection('meals')
          .doc(mealId)
          .collection('reviews')
          .add({
        'userId': _auth.currentUser?.uid,
        'rating': rating,
        'review': review,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Thank you for your rating!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit rating. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF5252),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
