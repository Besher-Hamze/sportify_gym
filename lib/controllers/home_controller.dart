import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/meal_controller.dart';
import '../models/meal.dart';

class HomeController extends GetxController {
  final MealController mealController = Get.put(MealController());

  // Observable list of today's meals
  final RxList<Meal> todaysMeals = <Meal>[].obs;

  // Search query observable
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    Get.put(MealController());
    _loadTodaysMeals();

    // Listen to meal controller's meals for automatic updates
    ever(mealController.meals, (_) => _loadTodaysMeals());
  }

  // Load meals for today
  void _loadTodaysMeals() {
    try {
      // Simply get all meals
      todaysMeals.value = mealController.meals;
    } catch (e) {
      // Handle error if meals can't be loaded
      Get.snackbar(
        'Error',
        'Could not load meals',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get recommended meals based on user preferences
  List<Meal> getRecommendedMeals() {
    // Return first 3 meals or all if less than 3
    return mealController.meals.take(3).toList();
  }

  // Add to favorites
  Future<void> addToFavorites(String mealId) async {
    await mealController.toggleFavorite(mealId);
  }

  // Add to cart
  Future<void> addToCart(String mealId) async {
    await mealController.addToCart(mealId);
  }

  // Get total number of meals
  int get totalMealsCount => mealController.meals.length;

  // Search meals
  void searchMeals(String query) {
    searchQuery.value = query;

    // Filter meals based on search query
    todaysMeals.value = mealController.meals.where((meal) {
      return meal.meal.toLowerCase().contains(query.toLowerCase()) ||
          meal.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
