import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../utils/app_theme.dart';
import '../widget/exercise_card.dart';
import 'pose_detection_screen.dart';

class ExerciseSelectionScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const ExerciseSelectionScreen({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final crossAxisCount = isTablet ? 3 : 2;

    // Calculate the ideal width for each card
    final cardWidth = (screenWidth - (32 + (16 * (crossAxisCount - 1)))) / crossAxisCount;
    final cardHeight = cardWidth * 1.5;
    final aspectRatio = cardWidth / cardHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Exercise'),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select an exercise to begin',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose from our collection of exercises',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final exercise = availableExercises[index];
                    return ExerciseCard(
                      exercise: exercise,
                      onTap: () => _navigateToExercise(context, exercise),
                    );
                  },
                  childCount: availableExercises.length,
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
          ],
        ),
      ),
    );
  }

  void _navigateToExercise(BuildContext context, Exercise exercise) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => PoseDetectionScreen(
    //       cameras: cameras,
    //       initialExercise: exercise.type,
    //     ),
    //   ),
    // );
  }
}