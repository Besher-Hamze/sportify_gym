import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../utils/app_theme.dart';

class PosePainter extends CustomPainter {
  final Size absoluteImageSize;
  final List<Pose> poses;
  final CameraLensDirection cameraLensDirection;

  PosePainter(this.absoluteImageSize, this.poses, this.cameraLensDirection);

  static const Map<PoseLandmarkType, List<PoseLandmarkType>> connections = {
    PoseLandmarkType.leftShoulder: [
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightShoulder
    ],
    PoseLandmarkType.leftElbow: [PoseLandmarkType.leftWrist],
    PoseLandmarkType.rightShoulder: [
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightHip
    ],
    PoseLandmarkType.rightElbow: [PoseLandmarkType.rightWrist],
    PoseLandmarkType.leftHip: [
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightHip
    ],
    PoseLandmarkType.leftKnee: [PoseLandmarkType.leftAnkle],
    PoseLandmarkType.rightHip: [PoseLandmarkType.rightKnee],
    PoseLandmarkType.rightKnee: [PoseLandmarkType.rightAnkle],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final pose in poses) {
      connections.forEach((startPoint, endPoints) {
        final startLandmark = pose.landmarks[startPoint];
        if (startLandmark != null) {
          final startX = startLandmark.x * scaleX;
          final startY = startLandmark.y * scaleY;

          for (final endPoint in endPoints) {
            final endLandmark = pose.landmarks[endPoint];
            if (endLandmark != null) {
              final endX = endLandmark.x * scaleX;
              final endY = endLandmark.y * scaleY;

              // Set color based on body side
              paint.color = startPoint.toString().contains('left')
                  ? AppColors.leftSidePose
                  : AppColors.rightSidePose;

              // Draw connection line
              canvas.drawLine(
                Offset(startX, startY),
                Offset(endX, endY),
                paint,
              );

              // Draw joint points
              final jointRadius = endLandmark.likelihood > 0.5 ? 4.0 : 2.0;
              canvas.drawCircle(
                Offset(endX, endY),
                jointRadius,
                paint..style = PaintingStyle.fill,
              );
            }
          }

          // Draw starting joint point
          canvas.drawCircle(
            Offset(startX, startY),
            4.0,
            paint..style = PaintingStyle.fill,
          );
        }
      });

      // Draw nose point
      final nose = pose.landmarks[PoseLandmarkType.nose];
      if (nose != null) {
        canvas.drawCircle(
          Offset(nose.x * scaleX, nose.y * scaleY),
          6.0,
          Paint()
            ..style = PaintingStyle.fill
            ..color = AppColors.poseLandmark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}