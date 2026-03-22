import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController newPassController = TextEditingController();

  String result = "";
  void resetPassword() async {

    if(emailController.text.isEmpty || newPassController.text.isEmpty){
      setState(()=> result="Enter all fields");
      return;
    }

    int updated = await DatabaseService().resetPassword(
        emailController.text.trim(),
        newPassController.text.trim());

    if(updated > 0){
      setState(()=> result="Password updated successfully");
    } else {
      setState(()=> result="Email not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Reset Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text("Forgot Password",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter registered email",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.email,color: Colors.green),
                  filled: true,
                  fillColor: const Color(0xff0f172a),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: newPassController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter new password",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.lock,color: Colors.green),
                  filled: true,
                  fillColor: const Color(0xff0f172a),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  child: const Text("Reset Password",
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 25),
              Text(result,
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }
}
