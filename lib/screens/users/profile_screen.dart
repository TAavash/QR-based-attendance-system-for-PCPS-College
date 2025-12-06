import 'package:flutter/material.dart';
import '../../endpoints/auth_api.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  Map<String, dynamic>? profile;

  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController(); // Optional for future use

  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => loading = true);

    try {
      profile = await AuthAPI.getProfile();

      usernameCtrl.text = profile?["username"] ?? "";
      emailCtrl.text = profile?["email"] ?? ""; // Your backend doesn't send email yet
    } catch (e) {
      _showMessage("Failed to load profile: $e");
    }

    setState(() => loading = false);
  }

  Future<void> _save() async {
    setState(() => saving = true);

    try {
      final success = await AuthAPI.updateProfile(
        username: usernameCtrl.text.trim(),
        email: emailCtrl.text.trim(), // optional
      );

      if (success) {
        _showMessage("Profile updated successfully");
        await _loadProfile();
      } else {
        _showMessage("Update failed");
      }
    } catch (e) {
      _showMessage("Error updating: $e");
    }

    setState(() => saving = false);
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // HEADER WITH AVATAR
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: const Icon(Icons.person, size: 45, color: Colors.deepPurple),
                ),
                const SizedBox(height: 10),
                Text(
                  profile?["username"] ?? "",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  profile?["role"]?.toUpperCase() ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurple.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // FORM FIELDS
          TextField(
            controller: usernameCtrl,
            decoration: InputDecoration(
              labelText: "Username",
              filled: true,
              fillColor: Colors.deepPurple.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: emailCtrl,
            decoration: InputDecoration(
              labelText: "Email (optional)",
              filled: true,
              fillColor: Colors.deepPurple.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 20),

          saving
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Save Changes", style: TextStyle(fontSize: 18)),
                ),

          const SizedBox(height: 20),

          // CHANGE PASSWORD BUTTON
          OutlinedButton.icon(
            icon: const Icon(Icons.lock),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
            label: const Text("Change Password"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              side: BorderSide(color: Colors.deepPurple.shade300),
            ),
          ),

          const SizedBox(height: 30),

          // STATIC INFO (UID, ROLE)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.badge),
              title: const Text("UID"),
              subtitle: Text(profile?["uid"] ?? "—"),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.work),
              title: const Text("Role"),
              subtitle: Text(profile?["role"] ?? "—"),
            ),
          ),
        ],
      ),
    );
  }
}
