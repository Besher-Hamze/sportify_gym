import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sportify_gym_porject/screens/auth/login_screen.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/app_theme.dart';
import '../../widget/custom_input.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({Key? key}) : super(key: key);

  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
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
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Get.to(LoginScreen()),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start your fitness journey today',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // // Profile Picture Selection
                    // Center(
                    //   child: Stack(
                    //     children: [
                    //       CircleAvatar(
                    //         radius: 50,
                    //         backgroundColor: AppColors.primary.withOpacity(0.1),
                    //         child: Icon(
                    //           Icons.person_outline,
                    //           size: 50,
                    //           color: AppColors.primary,
                    //         ),
                    //       ),
                    //       Positioned(
                    //         bottom: 0,
                    //         right: 0,
                    //         child: Container(
                    //           padding: const EdgeInsets.all(4),
                    //           decoration: BoxDecoration(
                    //             color: AppColors.primary,
                    //             shape: BoxShape.circle,
                    //             border: Border.all(
                    //               color: AppColors.background,
                    //               width: 2,
                    //             ),
                    //           ),
                    //           child: const Icon(
                    //             Icons.camera_alt,
                    //             size: 20,
                    //             color: Colors.white,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 32),

                    // Name Input
                    CustomInput(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      validator: controller.validateName,
                      onChanged: (value) => controller.name.value = value,
                      keyboardType: TextInputType.name,
                      suffixIcon: const Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email Input
                    CustomInput(
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validator: controller.validateEmail,
                      onChanged: (value) => controller.email.value = value,
                      suffixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Password Input
                    Obx(() => CustomInput(
                      label: 'Password',
                      hint: 'Choose a password',
                      obscureText: !controller.isPasswordVisible.value,
                      validator: controller.validatePassword,
                      onChanged: (value) => controller.password.value = value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    )),
                    const SizedBox(height: 16),

                    // Password Strength Indicator
                    Obx(() => _buildPasswordStrengthIndicator(
                      controller.password.value,
                    )),
                    const SizedBox(height: 24),

                    // Sign Up Button
                    Obx(() => ElevatedButton(
                      onPressed: (controller.isLoading.value)
                          ? null
                          : controller.signUp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.3),
                      ),
                      child: controller.isLoading.value
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
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                    const SizedBox(height: 24),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.to(LoginScreen()),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildPasswordStrengthIndicator(String password) {
    int strength = 0;
    String message = '';
    Color color = Colors.red;

    if (password.isEmpty) {
      message = 'Please enter a password';
    } else {
      if (password.length >= 8) strength++;
      if (password.contains(RegExp(r'[A-Z]'))) strength++;
      if (password.contains(RegExp(r'[0-9]'))) strength++;
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

      switch (strength) {
        case 1:
          message = 'Weak';
          color = Colors.red;
          break;
        case 2:
          message = 'Fair';
          color = Colors.orange;
          break;
        case 3:
          message = 'Good';
          color = Colors.yellow;
          break;
        case 4:
          message = 'Strong';
          color = Colors.green;
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 4,
                backgroundColor: Colors.white.withOpacity(0.1),
                color: color,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Password must contain uppercase, number & special character',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}