import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();

  File? selectedImage;

  /// PICK PROFILE IMAGE
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    bool success = await DatabaseService().registerUser(
      name.text.trim(),
      email.text.trim(),
      pass.text.trim(),
      selectedImage?.path ?? "",
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered Successfully")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email already registered")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xff020617),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            "Register",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  /// PROFILE IMAGE PICKER
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green.withOpacity(.2),
                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage!)
                          : null,
                      child: selectedImage == null
                          ? const Icon(Icons.camera_alt,
                          color: Colors.green)
                          : null,
                    ),
                  ),

                  const SizedBox(height: 30),

                  field("Name", name),
                  const SizedBox(height: 15),

                  field("Email", email),
                  const SizedBox(height: 15),

                  field("Password", pass, isPassword: true),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: register,
                      child: const Text("Register"),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget field(String hint, TextEditingController c,
      {bool isPassword = false}) {
    return TextFormField(
      controller: c,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xff0f172a),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15)),
      ),
      validator: (v) {
        if (v!.isEmpty) return "Enter $hint";
        if (hint == "Email" && !v.contains("@")) {
          return "Enter valid email";
        }
        if (hint == "Password" && v.length < 4) {
          return "Minimum 4 characters";
        }
        return null;
      },
    );
  }
}