import 'package:flutter/material.dart';

enum ExerciseType {
  squat,
  pushup,
  butterFly,
  lunge,
  armCircles,
  kneeRaised,
  none
}

class Exercise {
  final ExerciseType type;
  final String name;
  final String description;
  final String imageAsset;
  final List<String> instructions;
  final String targetMuscles;
  final String difficulty;
  final int recommendedReps;
  final int recommendedSets;

  Exercise({
    required this.type,
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.instructions,
    required this.targetMuscles,
    required this.difficulty,
    required this.recommendedReps,
    required this.recommendedSets,
  });
}

class ExerciseState {
  int repCount = 0;
  bool isDown = false;
  ExerciseType currentExercise = ExerciseType.none;
  String message = '';

  void reset() {
    repCount = 0;
    isDown = false;
    message = '';
  }
}

final List<Exercise> availableExercises = [
  Exercise(
    type: ExerciseType.squat,
    name: 'Squats',
    description:
        'A compound exercise that targets multiple muscle groups in your lower body.',
    imageAsset: 'assets/images/squat.png',
    instructions: [
      'Stand with feet shoulder-width apart',
      'Keep your back straight',
      'Lower your body as if sitting back into a chair',
      'Keep knees aligned with toes',
      'Go down until thighs are parallel to ground',
      'Push through heels to return to starting position'
    ],
    targetMuscles: 'Quadriceps, Hamstrings, Glutes',
    difficulty: 'Beginner',
    recommendedReps: 12,
    recommendedSets: 3,
  ),
  Exercise(
    type: ExerciseType.pushup,
    name: 'Push-ups',
    description:
        'A classic upper body exercise that builds chest, shoulder, and arm strength.',
    imageAsset: 'assets/images/pushup.png',
    instructions: [
      'Start in plank position with hands shoulder-width apart',
      'Keep your body in a straight line',
      'Lower your chest to the ground',
      'Keep elbows at 45-degree angle',
      'Push back up to starting position',
      'Maintain core engagement throughout'
    ],
    targetMuscles: 'Chest, Shoulders, Triceps',
    difficulty: 'Intermediate',
    recommendedReps: 10,
    recommendedSets: 3,
  ),
  Exercise(
    type: ExerciseType.butterFly,
    name: 'Butterfly',
    description:
        'An isolation exercise that targets the chest muscles through a wide range of motion.',
    imageAsset: 'assets/images/butterfly.png',
    instructions: [
      'Stand with feet shoulder-width apart',
      'Raise your arms to shoulder height',
      'Keep elbows slightly bent',
      'Bring your arms together in front of your chest',
      'Slowly return to the starting position',
      'Focus on squeezing chest muscles throughout'
    ],
    targetMuscles: 'Chest, Front Deltoids',
    difficulty: 'Intermediate',
    recommendedReps: 15,
    recommendedSets: 3,
  ),
  Exercise(
    type: ExerciseType.lunge,
    name: 'Lunges',
    description:
        'A unilateral exercise that improves balance, flexibility, and leg strength.',
    imageAsset: 'assets/images/lunge.png',
    instructions: [
      'Stand tall with feet hip-width apart',
      'Take a big step forward with one leg',
      'Lower your body until both knees are bent at 90 degrees',
      'Keep your front knee aligned with your ankle',
      'Push off the front foot to return to starting position',
      'Alternate legs with each rep'
    ],
    targetMuscles: 'Quadriceps, Hamstrings, Glutes, Calves',
    difficulty: 'Intermediate',
    recommendedReps: 12,
    recommendedSets: 3,
  ),
  Exercise(
    type: ExerciseType.armCircles,
    name: 'Arm Circles',
    description:
        'A dynamic warm-up exercise that improves shoulder mobility and circulation.',
    imageAsset: 'assets/images/arm_circles.png',
    instructions: [
      'Stand with feet shoulder-width apart',
      'Extend arms out to the sides at shoulder height',
      'Make small circles with your arms',
      'Gradually increase the size of the circles',
      'Maintain controlled movement throughout',
      'Switch between forward and backward circles'
    ],
    targetMuscles: 'Shoulders, Upper Back, Arms',
    difficulty: 'Beginner',
    recommendedReps: 20,
    recommendedSets: 2,
  ),
  Exercise(
    type: ExerciseType.kneeRaised,
    name: 'Knee Raises',
    description:
        'A core-strengthening exercise that targets the lower abdominal muscles.',
    imageAsset: 'assets/images/knee_raises.png',
    instructions: [
      'Stand tall with feet hip-width apart',
      'Engage your core muscles',
      'Lift one knee up towards your chest',
      'Keep your standing leg slightly bent',
      'Lower the knee back down with control',
      'Alternate between legs'
    ],
    targetMuscles: 'Lower Abs, Hip Flexors, Core',
    difficulty: 'Beginner',
    recommendedReps: 15,
    recommendedSets: 3,
  ),
];

// Exercise difficulty levels for reference
const List<String> difficultyLevels = ['Beginner', 'Intermediate', 'Advanced'];

// Helper function to get exercise by type
Exercise getExerciseByType(ExerciseType type) {
  return availableExercises.firstWhere(
    (exercise) => exercise.type == type,
    orElse: () => availableExercises.first,
  );
}

// Helper function to get exercises by difficulty
List<Exercise> getExercisesByDifficulty(String difficulty) {
  return availableExercises
      .where((exercise) => exercise.difficulty == difficulty)
      .toList();
}
