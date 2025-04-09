// import 'dart:io';
// import 'dart:convert';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart' show kIsWeb;

// class CameraPage extends StatefulWidget {
//   final List<dynamic> plants;

//   const CameraPage({super.key, required this.plants});

//   @override
//   State<CameraPage> createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> {
//   CameraController? _controller;
//   List<CameraDescription>? _cameras;
//   bool _loading = false;
//   String _loadingText = "";
//   XFile? _capturedImage;
//   bool _showFrontCamera = false;

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }

//   Future<void> _initCamera() async {
//     _cameras = await availableCameras();
//     _controller = CameraController(
//       _showFrontCamera ? _cameras![1] : _cameras![0],
//       ResolutionPreset.high,
//     );
//     await _controller!.initialize();
//     setState(() {});
//   }

//   Future<void> _takePicture() async {
//     if (!_controller!.value.isInitialized) return;
//     final image = await _controller!.takePicture();
//     _processImage(File(image.path));
//   }

//   Future<void> _pickFromGallery() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) _processImage(File(picked.path));
//   }

//   Future<void> _processImage(File imageFile) async {
//     setState(() {
//       _loading = true;
//       _loadingText = "Processing image...";
//       _capturedImage = XFile(
//         imageFile.path,
//       ); // ✅ this line ensures preview is valid
//     });

//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse(
//         "https://my-api.plantnet.org/v2/identify/all?api-key=2b10XVXIHqjriKvesfSL12JPpu",
//       ),
//     );
//     request.files.add(
//       await http.MultipartFile.fromPath('images', imageFile.path),
//     );

//     final response = await request.send();
//     final result = jsonDecode(await response.stream.bytesToString());

//     final matched = _matchPlant(result);

//     setState(() {
//       _loading = false;
//     });

//     if (matched != null) {
//       Navigator.pushNamed(context, '/add-plant-form', arguments: matched);
//     } else {
//       _showError("No matching plant found.");
//     }
//   }

//   Map<String, dynamic>? _matchPlant(dynamic result) {
//     if (result['results'] != null && result['results'].isNotEmpty) {
//       final name =
//           result['results'][0]['species']['genus']['scientificNameWithoutAuthor'];
//       return widget.plants.firstWhere(
//         (plant) => plant['latin_name'].toLowerCase() == name.toLowerCase(),
//         orElse: () => null,
//       );
//     }
//     return null;
//   }

//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: const Text("Oops!"),
//             content: Text(message),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("OK"),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:
//           _controller == null || !_controller!.value.isInitialized
//               ? const Center(child: CircularProgressIndicator())
//               : Stack(
//                 children: [
//                   CameraPreview(_controller!),
//                   Align(
//                     alignment: Alignment.topCenter,
//                     child: SafeArea(
//                       child: Column(
//                         children: const [
//                           SizedBox(height: 10),
//                           Text(
//                             "Take a photo of the whole plant",
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.bottomCenter,
//                     child: SafeArea(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16.0,
//                           vertical: 20,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.photo,
//                                 size: 32,
//                                 color: Colors.white,
//                               ),
//                               onPressed: _pickFromGallery,
//                             ),
//                             GestureDetector(
//                               onTap: _takePicture,
//                               child: Container(
//                                 width: 70,
//                                 height: 70,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.help_outline,
//                                 size: 32,
//                                 color: Colors.white,
//                               ),
//                               onPressed: () {},
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (_loading)
//                     Center(
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.black54,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const CircularProgressIndicator(
//                               color: Colors.green,
//                             ),
//                             const SizedBox(height: 10),
//                             Text(
//                               _loadingText,
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//     );
//   }
// }
