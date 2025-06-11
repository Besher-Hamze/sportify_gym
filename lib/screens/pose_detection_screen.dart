import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:sportify_gym_porject/widget/exercise_guide.dart';
import '../models/exercise.dart';
import '../services/pose_detection_exercise.dart';
import '../utils/app_theme.dart';
import '../widget/pose_pointer.dart';

class PoseDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final ExerciseType initialExercise;

  const PoseDetectionScreen({
    Key? key,
    required this.cameras,
    required this.initialExercise,
  }) : super(key: key);

  @override
  State<PoseDetectionScreen> createState() => _PoseDetectionScreenState();
}

class _PoseDetectionScreenState extends State<PoseDetectionScreen> with WidgetsBindingObserver {
  late CameraController _cameraController;
  late PoseDetector _poseDetector;
  late PoseDetectionService _poseDetectionService;
  bool _isBusy = false;
  bool _isFrontCamera = true;
  List<Pose>? _poses;
  String? _errorMessage;
  ExerciseState _exerciseState = ExerciseState();
  bool _showGuide = false;

  static const _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    _poseDetectionService = PoseDetectionService();
    WidgetsBinding.instance.addObserver(this);
    _initializePoseDetection();
    _setExerciseType(widget.initialExercise);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPoseDetection();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _stopPoseDetection();
    } else if (state == AppLifecycleState.resumed) {
      _initializePoseDetection();
    }
  }

  void _setExerciseType(ExerciseType type) {
    setState(() {
      _exerciseState.currentExercise = type;
      _exerciseState.reset();
      _exerciseState.message = 'Starting ${type.toString().split('.').last}';
    });
  }

  Future<void> _initializePoseDetection() async {
    try {
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
          model: PoseDetectionModel.accurate,
        ),
      );

      final camera = widget.cameras.firstWhere(
            (camera) => camera.lensDirection ==
            (_isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
        orElse: () => widget.cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController.initialize();

      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
        await _cameraController.startImageStream(_processCameraImage);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  void _stopPoseDetection() {
    _cameraController.dispose();
    _poseDetector.close();
  }

  Future<void> _toggleCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    await _initializePoseDetection();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy) return;

    _isBusy = true;
    try {
      final inputImage = _getInputImage(image);
      if (inputImage != null) {
        final poses = await _poseDetector.processImage(inputImage);
        if (mounted && poses.isNotEmpty) {
          setState(() {
            _poses = poses;
            _errorMessage = null;
          });
          _poseDetectionService.detectExercise(poses.first, _exerciseState);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error processing image: $e';
      });
    } finally {
      _isBusy = false;
    }
  }

  InputImage? _getInputImage(CameraImage image) {
    final camera = _cameraController.description;
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
      _orientations[_cameraController.value.deviceOrientation];
      if (rotationCompensation == null) return null;

      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_exerciseState.currentExercise.toString().split('.').last),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: _toggleCamera,
          ),
          IconButton(
            icon: Icon(_showGuide ? Icons.close : Icons.help_outline),
            onPressed: () => setState(() => _showGuide = !_showGuide),
          ),
        ],
      ),
      body: _errorMessage != null
          ? Center(
          child: Text(_errorMessage!,
              style: const TextStyle(color: AppColors.error)))
          : Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          if (_showGuide)
            ExerciseGuide(type: _exerciseState.currentExercise),
          _buildExerciseOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController),
          if (_poses != null)
            CustomPaint(
              painter: PosePainter(
                Size(
                  _cameraController.value.previewSize!.height,
                  _cameraController.value.previewSize!.width,
                ),
                _poses!,
                _cameraController.description.lensDirection,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseOverlay() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reps: ${_exerciseState.repCount}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _exerciseState.message,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}