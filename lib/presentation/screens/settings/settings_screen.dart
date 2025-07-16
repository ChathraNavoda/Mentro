import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentro/core/services/auth_service.dart';
import 'package:mentro/presentation/screens/auth/login_screen.dart';
import 'package:mentro/presentation/screens/settings/privacy_webview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';

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

  StreamSubscription? _rippleSubscription;

  @override
  void dispose() {
    _rippleSubscription?.cancel();
    super.dispose();
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
                color: Colors.black,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/default_avatar.png',
                        image: user?.photoURL?.isNotEmpty == true
                            ? user!.photoURL!
                            : 'assets/images/user.png',
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/images/default_avatar.png'),
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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

          // Protect Archived Ripples
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
              style:
                  GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            secondary: const Icon(Icons.lock, color: Color(0xFF4ECDC4)),
          ),

          const Divider(),

          // About Mentro
          ListTile(
            tileColor: Colors.white,
            leading: Icon(Icons.info_outline, color: Color(0xFF4ECDC4)),
            title: Text(
              "About Mentro",
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Mentro",
                applicationVersion: "1.0.0",
                applicationIcon:
                    Image.asset('assets/images/logo3.png', height: 48),
                children: [
                  Text(
                    "Mentro is an emotion tracking app that helps you understand your mental state better and build emotional awareness over time.",
                    style: GoogleFonts.outfit(
                        fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ],
              );
            },
          ),

          // Privacy Policy
          ListTile(
            tileColor: Colors.white,
            leading: Icon(Icons.lock_outline, color: Color(0xFF4ECDC4)),
            title: Text(
              "Privacy Policy",
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text(
                    "Privacy Policy",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                  ),
                  content: Text(
                    "We value your privacy. No data is shared.",
                    style: GoogleFonts.outfit(
                        fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  actions: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyWebView(
                                url:
                                    "https://mentro-31a64.web.app/privacy.html"),
                          ),
                        );
                      },
                      icon: Icon(Icons.open_in_new, color: Color(0xFF4ECDC4)),
                      label: Text(
                        "View Full Policy",
                        style: GoogleFonts.outfit(
                          color: Color(0xFF4ECDC4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: GoogleFonts.outfit(
                          color: Color(0xFF4ECDC4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Contact Support
          ListTile(
            tileColor: Colors.white,
            leading: Icon(Icons.mail_outline, color: Color(0xFF4ECDC4)),
            title: Text(
              "Contact Support",
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text(
                    "Support",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email us\n",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          Navigator.pop(context); // close dialog first

                          // Optional: Show a temporary message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Opening Gmail... Swipe back to return to Mentro.'),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          final Uri emailUri = Uri(
                            scheme: 'mailto',
                            path: 'mentro.ripple@gmail.com',
                            query: Uri.encodeFull('subject=Support Request'),
                          );

                          if (await canLaunchUrl(emailUri)) {
                            await launchUrl(
                              emailUri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Could not open email client')),
                            );
                          }
                        },
                        child: Text(
                          "mentro.ripple@gmail.com",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color(0xFF4ECDC4),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
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

          // Visit Website
          ListTile(
            tileColor: Colors.white,
            leading: Icon(Icons.language, color: Color(0xFF4ECDC4)),
            title: Text(
              "Visit Website",
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              final url = Uri.parse("https://mentro-31a64.web.app/");
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Could not open the website")),
                );
              }
            },
          ),
          // ListTile(
          //   tileColor: Colors.white,
          //   leading: Icon(Icons.language, color: Color(0xFF4ECDC4)),
          //   title: Text(
          //     "Visit Website",
          //     style:
          //         GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
          //   ),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => const PrivacyWebView(
          //             url: "https://mentro-31a64.web.app/"),
          //       ),
          //     );
          //   },
          // ),

          const SizedBox(height: 30),

          // Logout
          Center(
            child: TextButton.icon(
              icon: Icon(Icons.logout, color: Colors.red, size: 25),
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
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                    ),
                    content: Text(
                      "Are you sure you want to logout?",
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
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
                          Navigator.of(context).pop(); // close dialog first
                          await AuthService().logout();
                          if (!mounted) return;

                          scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(content: Text('You are logged out.')),
                          );

                          Future.delayed(Duration(milliseconds: 300), () {
                            navigatorKey.currentState?.pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                              (route) => false,
                            );
                          });
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
