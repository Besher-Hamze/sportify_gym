import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/exercise.dart';

class PoseDetectionService {
  void _setWrongForm(ExerciseState state, String message) {
    state.isFormWrong = true;
    state.formMessage = message;
  }

  void _clearWrongForm(ExerciseState state) {
    state.isFormWrong = false;
    state.formMessage = '';
  }

  double _calculateAngle(
      PoseLandmark first, PoseLandmark middle, PoseLandmark last) {
    final radians = math.atan2(last.y - middle.y, last.x - middle.x) -
        math.atan2(first.y - middle.y, first.x - middle.x);
    var angle = (radians * 180.0 / math.pi).abs();
    if (angle > 180.0) angle = 360.0 - angle;
    return angle;
  }

  double _calculateDistance(PoseLandmark point1, PoseLandmark point2) {
    return math.sqrt(
        math.pow(point1.x - point2.x, 2) + math.pow(point1.y - point2.y, 2));
  }

  bool _checkHanding(double leftHand, double rightHand, double threshold) {
    return leftHand < threshold && rightHand < threshold;
  }

  void detectExercise(Pose pose, ExerciseState state) {
    switch (state.currentExercise) {
      case ExerciseType.squat:
        _detectSquat(pose, state);
        break;
      case ExerciseType.pushup:
        _detectPushup(pose, state);
        break;
      case ExerciseType.butterFly:
        _detectButterFly(pose, state);
        break;
      case ExerciseType.lunge:
        _detectLunges(pose, state);
        break;
      case ExerciseType.armCircles:
        _detectArmCircles(pose, state);
        break;
      case ExerciseType.kneeRaised:
        _detectKneeRaises(pose, state);
        break;
      case ExerciseType.none:
        break;
    }
  }

  void _detectSquat(Pose pose, ExerciseState state) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (_areLandmarksValid([
      leftHip, leftKnee, leftAnkle, rightHip, rightKnee, rightAnkle,
      leftShoulder, leftElbow, leftWrist, rightShoulder, rightElbow, rightWrist
    ])) {
      final leftAngle = _calculateAngle(leftHip!, leftKnee!, leftAnkle!);
      final rightAngle = _calculateAngle(rightHip!, rightKnee!, rightAnkle!);
      final leftHand = _calculateAngle(leftShoulder!, leftElbow!, leftWrist!);
      final rightHand = _calculateAngle(rightShoulder!, rightElbow!, rightWrist!);
      final handsNotInFront = !_checkHanding(leftHand, rightHand, 100);

      if (leftAngle < 100 &&
          rightAngle < 100 &&
          !state.isDown &&
          !handsNotInFront) {
        _clearWrongForm(state);
        state.isDown = true;
        state.message = 'Good! Now stand up';
      } else if (leftAngle > 150 &&
          rightAngle > 150 &&
          state.isDown &&
          !handsNotInFront) {
        _clearWrongForm(state);
        state.isDown = false;
        state.repCount++;
        state.message = 'Rep ${state.repCount} completed!';
      } else if (handsNotInFront) {
        _setWrongForm(state, 'Keep both hands in front of your chest');
      } else if (leftAngle > 120 || rightAngle > 120) {
        _setWrongForm(state, 'Go lower, keep knees bent for a full squat');
      }
    }
  }

  void _detectPushup(Pose pose, ExerciseState state) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];

    if (_areLandmarksValid([leftShoulder, leftElbow, leftWrist])) {
      final angle = _calculateAngle(leftShoulder!, leftElbow!, leftWrist!);

      if (angle < 90 && !state.isDown) {
        _clearWrongForm(state);
        state.isDown = true;
        state.message = 'Good! Now push up';
      } else if (angle > 160 && state.isDown) {
        _clearWrongForm(state);
        state.isDown = false;
        state.repCount++;
        state.message = 'Rep ${state.repCount} completed!';
      } else if (angle >= 90 && angle <= 160) {
        _setWrongForm(state, 'Lower your chest more and keep elbows controlled');
      }
    }
  }

  void _detectButterFly(Pose pose, ExerciseState state) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final leftSide = pose.landmarks[PoseLandmarkType.leftHip];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rightSide = pose.landmarks[PoseLandmarkType.rightHip];

    if (_areLandmarksValid([
      leftShoulder, leftElbow, leftWrist, leftSide,
      rightShoulder, rightElbow, rightWrist, rightSide
    ])) {
      final leftHand = _calculateAngle(leftShoulder!, leftElbow!, leftWrist!);
      final rightHand = _calculateAngle(rightShoulder!, rightElbow!, rightWrist!);
      final leftSideAngle = _calculateAngle(
        leftSide as PoseLandmark,
        leftShoulder,
        leftElbow,
      );
      final rightSideAngle = _calculateAngle(
        rightSide as PoseLandmark,
        rightShoulder,
        rightElbow,
      );

      if (leftHand > 160 &&
          rightHand > 160 &&
          leftSideAngle > 80 &&
          rightSideAngle > 80 &&
          !state.isDown) {
        _clearWrongForm(state);
        state.isDown = true;
        state.message = 'Good! Now close your arms wide!';
      } else if (leftHand > 160 &&
          rightHand > 160 &&
          leftSideAngle < 80 &&
          rightSideAngle < 80 &&
          state.isDown) {
        _clearWrongForm(state);
        state.isDown = false;
        state.repCount++;
        state.message = 'Rep ${state.repCount} completed!';
      } else if (leftHand <= 160 || rightHand <= 160) {
        _setWrongForm(state, 'Keep your arms straighter during butterfly reps');
      } else {
        _setWrongForm(state, 'Open and close symmetrically at shoulder height');
      }
    }
  }

  void _detectLunges(Pose pose, ExerciseState state) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (_areLandmarksValid([
      leftHip, leftKnee, leftAnkle,
      rightHip, rightKnee, rightAnkle
    ])) {
      final frontLegAngle = _calculateAngle(leftHip!, leftKnee!, leftAnkle!);
      final backLegAngle = _calculateAngle(rightHip!, rightKnee!, rightAnkle!);
      final kneeDistance = _calculateDistance(
            leftKnee,
            rightKnee,
          ) /
          100;

      if (frontLegAngle < 100 &&
          backLegAngle < 120 &&
          backLegAngle > 80 &&
          kneeDistance > 1.5 &&
          !state.isDown) {
        _clearWrongForm(state);
        state.isDown = true;
        state.message = 'Good! Now stand up';
      } else if (frontLegAngle > 160 &&
          backLegAngle > 160 &&
          kneeDistance > 1.5 &&
          state.isDown) {
        _clearWrongForm(state);
        state.isDown = false;
        state.repCount++;
        state.message = 'Rep ${state.repCount} completed!';
      } else if (kneeDistance <= 1.5) {
        _setWrongForm(state, 'Take a wider step for a stable lunge');
      } else {
        _setWrongForm(state, 'Bend both knees to around 90 degrees');
      }
    }
  }

  void _detectArmCircles(Pose pose, ExerciseState state) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final nose = pose.landmarks[PoseLandmarkType.nose];

    if (_areLandmarksValid([
      leftShoulder, leftElbow, leftWrist,
      rightShoulder, rightElbow, rightWrist, nose
    ])) {
      final leftArmRaised = leftWrist!.y < nose!.y;
      final rightArmRaised = rightWrist!.y < nose.y;
      final leftArmAngle = _calculateAngle(leftShoulder!, leftElbow!, leftWrist);
      final rightArmAngle = _calculateAngle(rightShoulder!, rightElbow!, rightWrist);

      if (leftArmRaised &&
          rightArmRaised &&
          leftArmAngle > 150 &&
          rightArmAngle > 150 &&
          !state.isDown) {
        _clearWrongForm(state);
        state.isDown = true;
        state.message = 'Good! Now bring arms down';
      } else if (!leftArmRaised &&
          !rightArmRaised &&
          leftArmAngle > 150 &&
          rightArmAngle > 150 &&
          state.isDown) {
        _clearWrongForm(state);
        state.isDown = false;
        state.repCount++;
        state.message = 'Rep ${state.repCount} completed!';
      } else if (leftArmAngle <= 150 || rightArmAngle <= 150) {
        _setWrongForm(state, 'Straighten both arms while rotating');
      } else {
        _setWrongForm(state, 'Raise both arms together over shoulder level');
      }
    }
  }

  void _detectKneeRaises(Pose pose, ExerciseState state) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final nose = pose.landmarks[PoseLandmarkType.nose];

    if (_areLandmarksValid([leftHip, leftKnee, leftAnkle, nose])) {
      final kneeHeight = leftKnee!.y;
      final hipHeight = leftHip!.y;
      final kneeHipDiff = hipHeight - kneeHeight;
      final legAngle = _calculateAngle(leftHip, leftKnee, leftAnkle!);

      if (kneeHipDiff > 0.2 && legAngle > 150 && !state.isDown) {
        _clearWrongForm(state);
        state.isDown = true;
        state.message = 'Good! Now lower your knee';
      } else if (kneeHipDiff < 0.05 && legAngle > 160 && state.isDown) {
        _clearWrongForm(state);
        state.isDown = false;
        state.repCount++;
        state.message = 'Rep ${state.repCount} completed!';
      } else if (legAngle <= 150) {
        _setWrongForm(state, 'Keep your standing leg straighter');
      } else {
        _setWrongForm(state, 'Lift your knee higher toward your chest');
      }
    }
  }

  bool _areLandmarksValid(List<PoseLandmark?> landmarks) {
    return landmarks.every((landmark) => landmark != null);
  }
}