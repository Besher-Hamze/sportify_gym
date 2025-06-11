import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sportify_gym_porject/utils/cache_helper.dart';
import '../../utils/app_theme.dart';
import '../../widget/custom_input.dart';
import '../admin/home_screen.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isLoading = false.obs;

    Future<void> handleAdminLogin() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      // Static admin credentials
      if (usernameController.text == 'admin' &&
          passwordController.text == 'admin') {
       await CacheHelper.putData(key: "login", value: "admin");
        Future.delayed(const Duration(seconds: 1), () {
          isLoading.value = false;
          Get.to(AdminHomeScreen());
        });
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Invalid admin credentials',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        });
      }
    }

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Admin Login',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your admin credentials',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    CustomInput(
                      label: 'Username',
                      hint: 'Enter admin username',
                      controller: usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomInput(
                      label: 'Password',
                      hint: 'Enter admin password',
                      obscureText: true,
                      controller: passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Obx(() => ElevatedButton(
                          onPressed: isLoading.value ? null : handleAdminLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Login as Admin',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        )),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Back to Selection',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
