import 'package:flutter/material.dart';
import 'package:homeexpenseapp/views/login_page.dart';
import 'package:homeexpenseapp/views/main_navigation.dart';
import 'package:homeexpenseapp/services/database_service.dart';
import 'package:lottie/lottie.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  @override
  void initState() {
    super.initState();
    _homenavigation();
  }

  void _homenavigation() async {
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    final user = await DatabaseService().getLoggedUser();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
        user != null
            ? MainNavigation(user: user)
            : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightGreen, Colors.green],
          ),
        ),
        child: Center(
          child: Lottie.asset(
            "assets/animations/Finance app blue color.json",
            width: 250,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}