import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import '../config/api_config.dart';

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
  bool _isProcessing = false;
  Map<String, dynamic>? _plantInfo;
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          setState(() {
            _isLoading = false;
            _error = 'Камерын зөвшөөрөл шаардлагатай';
          });
          return;
        }
      }

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'Камер олдсонгүй';
        });
        return;
      }

      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
      setState(() {
        _isLoading = false;
        _error = 'Камерыг эхлүүлэхэд алдаа гарлаа';
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _controller!.takePicture();
      if (!mounted) return;

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
                if (_image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _image!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
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
                      },
                      child: const Text('Цуцлах'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _identifyPlant();
                      },
                      child: const Text('Тодорхойлох'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error taking picture: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Зураг авахад алдаа гарлаа'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _identifyPlant() async {
    if (_image == null) return;

    setState(() {
      _isProcessing = true;
      _plantInfo = null;
    });

    try {
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final requestBody = {
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'LABEL_DETECTION',
                'maxResults': 10,
              },
              {
                'type': 'WEB_DETECTION',
                'maxResults': 10,
              },
              {
                'type': 'OBJECT_LOCALIZATION',
                'maxResults': 5,
              }
            ],
          },
        ],
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.visionApiUrl}?key=${ApiConfig.googleVisionApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final labels = data['responses'][0]['labelAnnotations'] as List;
        final webDetection = data['responses'][0]['webDetection'];
        final objects = data['responses'][0]['localizedObjectAnnotations'] as List?;

        // Enhanced plant detection logic
        final plantLabels = labels.where((label) {
          final description = label['description'].toString().toLowerCase();
          return description.contains('plant') ||
              description.contains('flower') ||
              description.contains('tree') ||
              description.contains('leaf') ||
              description.contains('garden') ||
              description.contains('flora') ||
              description.contains('vegetation') ||
              description.contains('herb') ||
              description.contains('shrub');
        }).toList();

        if (plantLabels.isNotEmpty) {
          setState(() {
            _plantInfo = {
              'name': plantLabels[0]['description'],
              'confidence': plantLabels[0]['score'],
              'labels': plantLabels.map((label) => {
                    'name': label['description'],
                    'confidence': label['score'],
                  }).toList(),
              'webEntities': webDetection['webEntities']?.map((entity) => {
                    'name': entity['description'],
                    'score': entity['score'],
                  }).toList(),
              'objects': objects?.map((obj) => {
                    'name': obj['name'],
                    'confidence': obj['score'],
                  }).toList(),
            };
          });
        } else {
          setState(() {
            _error = 'Ургамал тодорхойлогдоогүй байна. Зураг тодорхой байгаа эсэхийг шалгана уу.';
          });
        }
      } else {
        setState(() {
          _error = 'Ургамал тодорхойлоход алдаа гарлаа. Дараа дахин оролдоно уу.';
        });
      }
    } catch (e) {
      print('Error identifying plant: $e');
      setState(() {
        _error = 'Ургамал тодорхойлоход алдаа гарлаа. Дараа дахин оролдоно уу.';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
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
                onPressed: _initializeCamera,
                child: const Text('Дахин оролдох'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isProcessing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Ургамал тодорхойлж байна...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_plantInfo != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Ургамлын мэдээлэл'),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                _plantInfo!['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Найдвартай байдал: ${(_plantInfo!['confidence'] * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Тодорхойлолт',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ...(_plantInfo!['labels'] as List).map((label) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${label['name']} (${(label['confidence'] * 100).toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              const Text(
                'Холбоотой мэдээлэл',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ...(_plantInfo!['webEntities'] as List).take(5).map((entity) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue.shade400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entity['name'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          CameraPreview(_controller!),
          // Plant Shape Overlay
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Plant Shape Guide
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PlantShapePainter(),
                    ),
                  ),
                  // Focus Guide
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Instructions
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.black.withOpacity(0.5),
              child: const Text(
                'Ургамлыг хүрээнд багтаана уу',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
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

class PlantShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw plant pot shape
    final potPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.7)
      ..lineTo(size.width * 0.8, size.height * 0.7)
      ..lineTo(size.width * 0.9, size.height * 0.9)
      ..lineTo(size.width * 0.1, size.height * 0.9)
      ..close();

    // Draw plant leaves
    final leavesPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.3,
        size.width * 0.5,
        size.height * 0.1,
      )
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.3,
        size.width * 0.5,
        size.height * 0.7,
      );

    canvas.drawPath(potPath, paint);
    canvas.drawPath(leavesPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
