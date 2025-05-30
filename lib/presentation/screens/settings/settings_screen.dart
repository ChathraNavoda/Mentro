import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentro/core/services/auth_service.dart';
import 'package:mentro/core/services/google_service.dart';
import 'package:mentro/presentation/screens/auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isReminderOn = true;
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: const Color.fromARGB(115, 0, 0, 0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user?.photoURL ?? ''),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? '',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(user?.email ?? '',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          // Mood Reminder
          SwitchListTile(
            value: isReminderOn,
            onChanged: (val) {
              setState(() => isReminderOn = val);
              // TODO: Implement scheduling logic with flutter_local_notifications
            },
            title: Text("Daily Mood Reminder"),
            subtitle: Text("Get notified to track your emotions"),
            secondary: Icon(Icons.notifications_active_outlined),
          ),

          // Dark Mode Toggle
          SwitchListTile(
            value: isDarkMode,
            onChanged: (val) {
              setState(() => isDarkMode = val);
              // TODO: Integrate with actual theme provider if needed
            },
            title: Text("Dark Mode"),
            subtitle: Text("Switch between light and dark themes"),
            secondary: Icon(Icons.dark_mode),
          ),

          const Divider(),

          // About Mentro
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About Mentro"),
            onTap: () {
              // Show a dialog or navigate to about page
              showAboutDialog(
                context: context,
                applicationName: "Mentro",
                applicationVersion: "1.0.0",
                applicationIcon: Icon(Icons.self_improvement, size: 40),
                children: [
                  Text(
                    "Mentro is an emotion tracking app that helps you understand your mental state better and build emotional awareness over time.",
                  )
                ],
              );
            },
          ),

          // Privacy Policy
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text("Privacy Policy"),
            onTap: () {
              // Open policy page or external link
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Privacy Policy"),
                  content: Text("We value your privacy. No data is shared."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("OK"),
                    )
                  ],
                ),
              );
            },
          ),

          // Contact Support
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text("Contact Support"),
            onTap: () {
              // Implement email launcher or contact form
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Support"),
                  content: Text("Email us at: support@mentro.app"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"),
                    )
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // Logout
          Center(
            child: TextButton.icon(
              icon: Icon(Icons.logout, color: Colors.redAccent),
              label: Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () async {
                await AuthService().logout();
                await GoogleService().googleSignOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
