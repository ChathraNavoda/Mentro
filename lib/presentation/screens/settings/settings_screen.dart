import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentro/core/services/auth_service.dart';
import 'package:mentro/core/services/google_service.dart';
import 'package:mentro/presentation/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isReminderOn = true;
  bool isDarkMode = false;
  bool _isArchiveProtected = false;

  @override
  void initState() {
    super.initState();
    _loadArchiveProtection();
  }

  Future<void> _loadArchiveProtection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isArchiveProtected = prefs.getBool('isArchiveProtected') ?? false;
    });
  }

  Future<void> _setArchiveProtection(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isArchiveProtected', value);
    setState(() {
      _isArchiveProtected = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                width: 0,
                //color: Color(0xFF4ECDC4),
                color: Color.fromARGB(255, 0, 0, 0),
              ),
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
                      Text(
                        user?.displayName ?? '',
                        style: GoogleFonts.outfit(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        user?.email ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Mood Reminder
          // SwitchListTile(
          //   activeTrackColor: const Color(0xFF4ECDC4),
          //   value: isReminderOn,
          //   onChanged: (val) {
          //     setState(() => isReminderOn = val);
          //     // TODO: Implement scheduling logic with flutter_local_notifications
          //   },
          //   title: Text(
          //     "Daily Mood Reminder",
          //     style:
          //         GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
          //   ),
          //   subtitle: Text("Get notified to track your emotions"),
          //   secondary: Icon(
          //     Icons.notifications_active_outlined,
          //   ),
          // ),

          // Dark Mode Toggle
          // SwitchListTile(
          //   activeTrackColor: const Color(0xFF4ECDC4),
          //   value: isDarkMode,
          //   onChanged: (val) {
          //     setState(() => isDarkMode = val);
          //     // TODO: Integrate with actual theme provider if needed
          //   },
          //   title: Text(
          //     "Dark Mode",
          //     style:
          //         GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
          //   ),
          //   subtitle: Text("Switch between light and dark themes"),
          //   secondary: Icon(
          //     Icons.dark_mode,
          //   ),
          // ),

          // 🔒 Protect Archived Ripples
          SwitchListTile(
            activeTrackColor: const Color(0xFF4ECDC4),
            value: _isArchiveProtected,
            onChanged: (val) {
              _setArchiveProtection(val);
            },
            title: Text(
              "Protect Archived Ripples",
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              "Require authentication to view archived entries",
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            secondary: const Icon(Icons.lock),
          ),

          const Divider(),

          // About Mentro
          ListTile(
            tileColor: Colors.white,
            leading: Icon(Icons.info_outline),
            title: Text(
              "About Mentro",
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Mentro",
                applicationVersion: "1.0.0",
                applicationIcon: Image.asset(
                  'assets/images/logo3.png',
                ),
                children: [
                  Text(
                    "Mentro is an emotion tracking app that helps you understand your mental state better and build emotional awareness over time.",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              );
            },
          ),

          // Privacy Policy
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text(
              "Privacy Policy",
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text(
                    "Privacy Policy",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  content: Text(
                    "We value your privacy. No data is shared.",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "OK",
                        style: GoogleFonts.outfit(
                          color: Color(0xFF4ECDC4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),

          // Contact Support
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text(
              "Contact Support",
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text("Support"),
                  content: Text("Email us at: support@mentro.app"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: GoogleFonts.outfit(
                          color: Color(0xFF4ECDC4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
              icon: Icon(
                Icons.logout,
                color: Colors.red,
                size: 25,
              ),
              label: Text(
                "Logout",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text(
                      "Confirm Logout",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    content: Text(
                      "Are you sure you want to logout?",
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.outfit(
                            color: Color(0xFF4ECDC4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop(); // close dialog
                          await AuthService().logout();
                          await GoogleService().googleSignOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(
                          "Logout",
                          style: GoogleFonts.outfit(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
