// Packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// Controllers
import 'package:lungscan_ai/controller/server_controller.dart';
import 'package:lungscan_ai/controller/auth_controller.dart';
import 'package:lungscan_ai/controller/history_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String getFormattedDate() {
    DateTime now = DateTime.now();
    return DateFormat('EEEE, MMMM d').format(now);
  }

  // 🔄 Pull-to-refresh
  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  Widget placeholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: const Icon(Icons.image_not_supported),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = AuthController().currentUser;
    String? username = user?.displayName;
    String? photoURL = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 1,
        title: Text("LungScan AI", style: Theme.of(context).textTheme.titleLarge),
        actions: [
          // 👤 Profile Avatar
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: EdgeInsets.zero),
            child: CircleAvatar(
              radius: 16,
              child: (photoURL != null && photoURL.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(photoURL),
                    )
                  : Text(username != null ? username[0] : "U"),
            ),
          ),

          // ☰ Menu
          PopupMenuButton<String>(
            icon: const Icon(HugeIconsStroke.menuCircle),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            menuPadding: const EdgeInsets.all(8),
            onSelected: (value) async {
              if (value == 'server_check') {
                final result = await ServerController().checkServerStatus();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                );
              }

              if (value == 'logout') {
                AuthController().signOut();
                Navigator.pushReplacementNamed(context, '/welcome');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'server_check',
                child: Row(
                  children: [
                    Icon(HugeIconsStroke.cloud, size: 20),
                    SizedBox(width: 16),
                    Text("Check Server"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      HugeIconsStroke.logoutCircle02,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 16),
                    Text("Logout", style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      // 🔄 Pull-to-refresh
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 16),

              // 📅 Date
              Text(
                getFormattedDate(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),

              // 👋 Greeting
              Text(
                "Hello, ${username ?? 'User'}",
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 24),

              // 🚀 Upload Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/upload');
                },
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Upload New Scan", style: Theme.of(context).textTheme.titleLarge),
                          Text(
                            "Instant AI-powered Analysis",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(HugeIconsStroke.cloudUpload, size: 32),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 📂 HISTORY
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("History", style: Theme.of(context).textTheme.headlineMedium),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/history');
                          },
                          child: Text(
                            "See All",
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 🔥 History List
                    StreamBuilder(
                      stream: HistoryController().getHistory(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Text("Error loading history");
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("No history yet"),
                          );
                        }

                        final docs = snapshot.data!.docs.take(3).toList();

                        return Column(
                          children: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final imagePath = data['imagePath'];

                            final isSafe = data['topDisease'] == "No Finding";

                            Widget imageWidget() {
                              if (imagePath == null) return placeholder();

                              final file = File(imagePath);
                              if (!file.existsSync()) return placeholder();

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(file, width: 60, height: 60, fit: BoxFit.cover),
                              );
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),

                                leading: imageWidget(),

                                title: Text(
                                  data['topDisease'] ?? "Unknown",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),

                                subtitle: Text(
                                  "${(data['topConfidence'] * 100).toStringAsFixed(1)}% confidence",
                                ),

                                trailing: Icon(
                                  isSafe
                                      ? HugeIconsStroke.checkmarkCircle02
                                      : HugeIconsStroke.alert02,
                                  color: isSafe
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.error,
                                ),

                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/results',
                                    arguments: {
                                      'image': File(data['imagePath']),
                                      'result': {
                                        'prediction': data['prediction'],
                                        'details': data['details'],
                                      },
                                    },
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLow),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  HugeIconsStroke.informationCircle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "This AI analysis is not a medical diagnosis. Please consult a healthcare professional.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
