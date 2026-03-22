import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final Map user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late String name;
  late String email;
  late String imagePath;
  late int userId;

  @override
  void initState() {
    super.initState();
    name = widget.user['name'];
    email = widget.user['email'];
    imagePath = widget.user['image'] ?? "";
    userId = widget.user['id'];
  }
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? picked =
    await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await DatabaseService()
          .updateProfileImage(userId, picked.path);
      setState(() {
        imagePath = picked.path;
      });
      Navigator.pop(context, true);
    }
  }
  void logout() async {
    await DatabaseService().logout();   // 🔥 ONLY CHANGE

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }
  void editName() {
    TextEditingController controller =
    TextEditingController(text: name);
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Edit Name"),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () async {
                    await DatabaseService()
                        .updateUserName(userId, controller.text);
                    setState(() {
                      name = controller.text;
                    });
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  child: const Text("Save"))
            ],
          );
        });
  }
  void changePassword() {
    TextEditingController controller = TextEditingController();
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Change Password"),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () async {
                    await DatabaseService()
                        .updateUserPassword(userId, controller.text);
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Password Updated")));
                  },
                  child: const Text("Update"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.green,
                  backgroundImage: imagePath.isNotEmpty
                      ? FileImage(File(imagePath))
                      : null,
                  child: imagePath.isEmpty
                      ? const Icon(Icons.person,
                      size: 60, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 20),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),
            Text(name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(email,
                style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 30),
            buildTile(Icons.edit, "Edit Name", editName),
            buildTile(Icons.lock, "Change Password", changePassword),
            buildTile(Icons.logout, "Logout", logout,
                color: Colors.redAccent),
          ],
        ),
      ),
    );
  }
  Widget buildTile(IconData icon, String title, VoidCallback tap,
      {Color color = Colors.white}) {
    return Card(
      color: const Color(0xff111827),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.white54),
        onTap: tap,
      ),
    );
  }
}
