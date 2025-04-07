import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      Fluttertoast.showToast(msg: 'Нууц үг таарахгүй байна');
      return;
    }

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'password2': confirmPasswordController.text,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Fluttertoast.showToast(msg: 'Амжилттай бүртгэгдлээ');
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Fluttertoast.showToast(msg: 'Бүртгэхэд алдаа гарлаа');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Бүртгүүлэх')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Хэрэглэгчийн нэр'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Имэйл'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Нууц үг'),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Нууц үг давтах'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : register,
              child:
                  isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Бүртгүүлэх'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
