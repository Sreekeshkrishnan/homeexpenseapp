import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'register_page.dart';
import 'forgotemail_page.dart';
import 'forgotpassword_page.dart';
import 'main_navigation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool hidePass = true;
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    var user = await DatabaseService().loginUser(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigation(user: user),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email or password")),
      );
    }
    setState(() => loading = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 80),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [Color(0xff16a34a), Color(0xff22c55e)]),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.green.withOpacity(.6),
                          blurRadius: 25)
                    ],
                  ),
                  child: const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 25),
                const Text("Welcome",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                buildField("Email", emailController, icon: Icons.email),
                const SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePass,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.lock,color: Colors.green),
                    suffixIcon: IconButton(
                      icon: Icon(hidePass
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: (){
                        setState(()=>hidePass=!hidePass);
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xff0f172a),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  validator: (v){
                    if(v!.isEmpty) return "Enter password";
                    if(v.length<4) return "Minimum 4 chars";
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
                      },
                      child: const Text("Forgot Password?",
                          style: TextStyle(color: Colors.white70)),
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ForgotEmailPage()));
                      },
                      child: const Text("Forgot Email?",
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff16a34a),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    onPressed: login,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("LOGIN",
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New User?",
                        style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const RegisterPage()));
                      },
                      child: const Text("Register",
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget buildField(String label, TextEditingController controller,
      {IconData? icon}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon,color: Colors.green),
        filled: true,
        fillColor: const Color(0xff0f172a),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15)),
      ),
      validator: (v){
        if(v!.isEmpty) return "$label required";
        return null;
      },
    );
  }
}
