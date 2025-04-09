// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'dart:convert';

// class CameraScreen extends StatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   CameraController? controller;
//   late Future<void> initializeControllerFuture;
//   String? diagnosisResult;
//   File? capturedImage;

//   @override
//   void initState() {
//     super.initState();
//     initCamera();
//   }

//   Future<void> initCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final firstCamera = cameras.first;

//       controller = CameraController(firstCamera, ResolutionPreset.medium);
//       initializeControllerFuture = controller!.initialize();
//       setState(() {});
//     } catch (e) {
//       print("Error initializing camera: $e");
//     }
//   }

//   Future<void> takePictureAndDiagnose() async {
//     try {
//       await initializeControllerFuture;

//       final XFile file = await controller!.takePicture();
//       final File imageFile = File(file.path);

//       if (!mounted) return;

//       setState(() {
//         capturedImage = imageFile;
//         diagnosisResult = null; // clear previous result
//       });

//       await sendImageForDiagnosis(imageFile);
//     } catch (e) {
//       print('Error taking picture: $e');
//     }
//   }

//   Future<void> sendImageForDiagnosis(File imageFile) async {
//     final uri = Uri.parse(
//       'http://<YOUR_BACKEND_URL>/api/diagnose/',
//     ); // <-- replace this

//     try {
//       var request = http.MultipartRequest('POST', uri)
//         ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

//       var response = await request.send();

//       if (response.statusCode == 200) {
//         final responseData = await http.Response.fromStream(response);
//         final jsonData = json.decode(responseData.body);

//         if (!mounted) return;

//         setState(() {
//           diagnosisResult = '''
// 🌿 Plant: ${jsonData["plant_name"]}
// 💧 Watering: ${jsonData["care_instructions"]["watering"]}
// ☀️ Sunlight: ${jsonData["care_instructions"]["sunlight"]}
// 🌡️ Temperature: ${jsonData["care_instructions"]["temperature"]}
// 💦 Humidity: ${jsonData["care_instructions"]["humidity"]}
//           ''';
//         });
//       } else {
//         if (!mounted) return;
//         setState(() {
//           diagnosisResult =
//               "❌ Failed to diagnose plant. [${response.statusCode}]";
//         });
//       }
//     } catch (e) {
//       print("Error sending image: $e");
//       if (!mounted) return;
//       setState(() {
//         diagnosisResult = "❌ Error diagnosing plant.";
//       });
//     }
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Diagnose Plant")),
//       body:
//           controller == null
//               ? Center(child: CircularProgressIndicator())
//               : FutureBuilder<void>(
//                 future: initializeControllerFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState != ConnectionState.done) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   return SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         AspectRatio(
//                           aspectRatio: controller!.value.aspectRatio,
//                           child: CameraPreview(controller!),
//                         ),
//                         SizedBox(height: 10),
//                         ElevatedButton.icon(
//                           onPressed: takePictureAndDiagnose,
//                           icon: Icon(Icons.camera_alt),
//                           label: Text("Take Picture"),
//                         ),
//                         if (capturedImage != null)
//                           Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Image.file(capturedImage!),
//                           ),
//                         if (diagnosisResult != null)
//                           Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Text(
//                               diagnosisResult!,
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }
