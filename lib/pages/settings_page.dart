import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _pickAndUploadProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    await user?.updatePhotoURL(file.path);
    setState(() {});
  }

  Future<void> _resetPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;
    await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: TextStyle(fontSize: 25))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<EntryProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (user != null) ...[
                    Center(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: user.photoURL != null
                                    ? (user.photoURL!.startsWith('http')
                                        ? NetworkImage(user.photoURL!)
                                        : FileImage(File(user.photoURL!))
                                            as ImageProvider)
                                    : const AssetImage('assets/images/default_avatar.png'),
                              ),
                              const SizedBox(height: 10),
                              Spacer(),
                              Column(
                                children: [
                                  Text(
                                    user.displayName ?? 'Anonymous User',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    user.email ?? '',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickAndUploadProfilePhoto,
                                icon: Icon(Icons.photo_camera, color: colorScheme.tertiary),
                                label: Text('Change Photo',style: TextStyle(color: colorScheme.tertiary)),
                              ),
                              Spacer(),
                              ElevatedButton.icon(
                                onPressed: _resetPassword,
                                icon: Icon(Icons.lock_reset, color: colorScheme.tertiary),
                                label: Text('Reset Password',style: TextStyle(color: colorScheme.tertiary)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Center(
                      child: Column(
                        children: const [
                          Icon(Icons.person_outline, size: 80, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            "You're not signed in",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ListTile(
                    leading: Icon(user == null ? Icons.login : Icons.logout),
                    title: Text(user == null ? 'Sign In' : 'Sign Out'),
                    subtitle: Text(
                      user == null
                          ? 'Sign in to sync your data to the cloud'
                          : 'Signed in as ${user.email ?? user.displayName}',
                    ),
                    onTap: () {
                      if (user == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      } else {
                        FirebaseAuth.instance.signOut();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Look',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Light Mode'),
                      Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) => themeProvider.toggelTheme(),
                      ),
                      const Text('Dark Mode'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Enable Numbered List'),
                      const Spacer(),
                      Switch(
                        value: context.watch<EntryProvider>().listEnabled,
                        onChanged: (val) {
                          context.read<EntryProvider>().toggleListEnabel(val);
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Privacy',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Local Storage'),
                      Switch(
                        value: provider.useCloud,
                        onChanged: (value) async {
                          if (!value && provider.useCloud) {
                            bool? deleteCloud = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Cloud Data?'),
                                content: const Text(
                                  'Do you want to delete your cloud data after syncing it to local storage?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('Delete Cloud Data'),
                                  ),
                                ],
                              ),
                            );
                            if (deleteCloud == null) return;
                            await provider.mergeCloudToLocal(deleteCloud);
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  deleteCloud
                                      ? 'Cloud data merged and deleted'
                                      : 'Cloud data merged but kept online',
                                ),
                              ),
                            );
                          } else if (value && !provider.useCloud) {
                            await provider.toggelStorage(true);
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Local data merged to Cloud'),
                              ),
                            );
                          }
                        },
                      ),
                      const Text('Cloud Storage'),
                    ],
                  ),
                  Text(
                    'Debugging',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Delete All Entries'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text(
                            'Are you sure you want to delete ALL entries?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        provider.clearAllEntries();
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All entries have been deleted'),
                          ),
                        );
                      }
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      await entryProvider.loadEntries();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Streak reloaded!')),
                      );
                    },
                    child: const Text('Reload Streak Widget'),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          final provider = context.read<EntryProvider>();
                          final date = await showDatePicker(
                            context: context,
                            initialDate: provider.currentTime,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              // ignore: use_build_context_synchronously
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(provider.currentTime),
                            );
                            final newDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time?.hour ?? 0,
                              time?.minute ?? 0,
                            );
                            provider.setMockDate(newDateTime);
                          }
                        },
                        child: const Text('Set Mock Date/Time'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () => context.read<EntryProvider>().clearMockDate(),
                        child: const Text('Reset to Real Time'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
