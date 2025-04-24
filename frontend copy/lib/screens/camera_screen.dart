import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isLoading = true;
  String? _error;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkCameraPermission();
    }
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        setState(() {
          _isLoading = false;
          _isCameraInitialized = true;
        });
        _initializeCamera();
      } else {
        final result = await Permission.camera.request();
        if (result.isGranted) {
          setState(() {
            _isLoading = false;
            _isCameraInitialized = true;
          });
          _initializeCamera();
        } else {
          setState(() {
            _isLoading = false;
            _error = 'Камерын зөвшөөрөл шаардлагатай';
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Камерын зөвшөөрөл шалгахад алдаа гарлаа';
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        setState(() {
          _image = File(photo.path);
        });

        // Show the captured image
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Зураг'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.file(
                    _image!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _image = null;
                          });
                          _initializeCamera();
                        },
                        child: const Text('Цуцлах'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Send image to backend for plant identification
                        },
                        child: const Text('Тодорхойлох'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      print('Error initializing camera: $e');
      setState(() {
        _error = 'Камерыг эхлүүлэхэд алдаа гарлаа';
      });
    }
  }

  Future<void> _takePicture() async {
    if (_error != null) {
      await _checkCameraPermission();
      if (_error != null) return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        setState(() {
          _image = File(photo.path);
        });

        // Show the captured image
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Зураг'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.file(
                    _image!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _image = null;
                          });
                          _initializeCamera();
                        },
                        child: const Text('Цуцлах'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Send image to backend for plant identification
                        },
                        child: const Text('Тодорхойлох'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      print('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Зураг авахад алдаа гарлаа'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.no_photography,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkCameraPermission,
                child: const Text('Дахин оролдох'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview (using a placeholder for now)
          Container(
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 100,
              ),
            ),
          ),
          // Camera Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Take Picture Button
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                // Close Button
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
