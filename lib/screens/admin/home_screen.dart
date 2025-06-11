import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sportify_gym_porject/screens/intro_screen.dart';
import 'package:sportify_gym_porject/utils/cache_helper.dart';
import '../../controllers/admin_controller.dart';
import '../../utils/app_theme.dart';
import 'admin_meals_screen.dart';
import 'admin_users_screen.dart';
import 'admin_notifications_screen.dart';

class AdminHomeScreen extends GetView<AdminController> {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(AdminController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            CacheHelper.delete(key: "login");
            Get.offAll(IntroScreen());
          }, icon: Icon(Icons.logout))
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome, Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildStatsCards(),
              const SizedBox(height: 24),
              _buildMenuGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Meals',
            '${controller.meals.length}',
            Icons.restaurant_menu,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Users',
            '${controller.users.length}',
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Notifications',
            '${controller.notifications.length}',
            Icons.notifications,
            Colors.purple,
          ),
        ),
      ],
    ));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildMenuCard(
          'Manage Meals',
          'Add, edit, or remove meals',
          Icons.restaurant_menu,
          Colors.orange,
              () => Get.to(() => const AdminMealsScreen()),
        ),
        _buildMenuCard(
          'Manage Users',
          'View and manage user accounts',
          Icons.people,
          Colors.blue,
              () => Get.to(() => const AdminUsersScreen()),
        ),
        _buildMenuCard(
          'Notifications',
          'Send notifications to users',
          Icons.notifications,
          Colors.purple,
              () => Get.to(() => const AdminNotificationsScreen()),
        ),
        _buildMenuCard(
          'Reports & Analytics',
          'View app statistics',
          Icons.analytics,
          Colors.green,
              () => Get.snackbar(
            'Coming Soon',
            'This feature will be available soon!',
            snackPosition: SnackPosition.BOTTOM,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}