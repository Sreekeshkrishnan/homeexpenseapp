import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ForgotEmailPage extends StatefulWidget {
  const ForgotEmailPage({super.key});

  @override
  State<ForgotEmailPage> createState() => _ForgotEmailPageState();
}

class _ForgotEmailPageState extends State<ForgotEmailPage> {

  TextEditingController nameController = TextEditingController();
  String result = "";
  bool loading = false;

  /// 🔥 FIND EMAIL FROM SHAREDPREFERENCES
  void findEmail() async {

    if(nameController.text.trim().isEmpty){
      setState(() => result = "Enter your name");
      return;
    }

    setState(()=>loading=true);

    var user = await DatabaseService()
        .findEmailByName(nameController.text.trim());

    if(user != null){
      setState(() {
        result = "Your email: ${user['email']}";
      });
    } else {
      setState(() {
        result = "User not found";
      });
    }

    setState(()=>loading=false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Forgot Email"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const Text(
              "Find your registered email",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter registered name",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.person,color: Colors.green),
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
                onPressed: findEmail,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Find Email",
                    style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              result,
              style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}