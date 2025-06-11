import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../screens/notifications_screen.dart';
import '../controllers/meal_controller.dart';
import '../screens/favorite_screen.dart';
import '../screens/my_cart.dart';
import '../screens/order_history.dart';
import '../utils/app_theme.dart';
import '../screens/intro_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final MealController mealController;

  const CustomAppBar({
    Key? key,
    required this.mealController,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => AppBar(
        title: Row(
          children: [
            Icon(
              Icons.fitness_center,
              size: 30,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Fitness App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          _buildActionButton(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            count: 0, // You can add notification count here if needed
            label: 'Notifications',
            onPressed: () => Get.to(() => const UserNotificationsScreen()),
            badgeColor: AppColors.primary,
          ),
          _buildActionButton(
            icon: Icons.shopping_cart_outlined,
            activeIcon: Icons.shopping_cart,
            count: mealController.cartItems.length,
            label: 'Cart',
            onPressed: () => Get.to(() => CartScreen()),
            badgeColor: Colors.blue,
          ),
          _buildActionButton(
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite,
            count: mealController.favoriteIds.length,
            label: 'Favorites',
            onPressed: () => Get.to(() => FavoritesScreen()),
            badgeColor: Colors.red,
          ),
          _buildActionButton(
            icon: Icons.receipt_outlined,
            activeIcon: Icons.receipt,
            count: mealController.orderHistory.length,
            label: 'Orders',
            onPressed: () => Get.to(() => OrderHistoryScreen()),
            badgeColor: Colors.green,
          ),
          const SizedBox(width: 12),
        ],
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Get.offAll(IntroScreen());
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required IconData activeIcon,
    required int count,
    required String label,
    required VoidCallback onPressed,
    required Color badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              HapticFeedback.lightImpact();
              onPressed();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Badge(
                label: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: badgeColor,
                isLabelVisible: count > 0,
                child: Center(
                  child: Icon(
                    count > 0 ? activeIcon : icon,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}