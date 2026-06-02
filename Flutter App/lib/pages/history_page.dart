// Packages
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

// Controller
import 'package:lungscan_ai/controller/history_controller.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Widget buildImage(String? path) {
    if (path == null) return placeholder();

    final file = File(path);
    if (!file.existsSync()) return placeholder();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(file, height: 70, width: 70, fit: BoxFit.cover),
    );
  }

  Widget placeholder() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: const Icon(Icons.image_not_supported),
    );
  }

  void showDeleteMenu(BuildContext context, String docId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(HugeIconsStroke.delete02, color: Theme.of(context).colorScheme.error),
                title: Text(
                  "Delete Scan",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  await HistoryController().deleteResult(docId);

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Scan deleted")));
                },
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),

      body: StreamBuilder<QuerySnapshot>(
        stream: HistoryController().getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            log(snapshot.error.toString());
            return const Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No history found"));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No scans yet"));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("All Scans", style: Theme.of(context).textTheme.headlineMedium),
                    const Spacer(),
                    Text(
                      "${docs.length} records",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final isSafe = data['topDisease'] == "No Finding";
                      final imagePath = data['imagePath'];

                      return GestureDetector(
                        onLongPress: () => showDeleteMenu(context, doc.id),

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

                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              buildImage(imagePath),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['topDisease'] ?? "Unknown",
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${(data['topConfidence'] * 100).toStringAsFixed(1)}% confidence",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              Icon(
                                isSafe
                                    ? HugeIconsStroke.checkmarkCircle01
                                    : HugeIconsStroke.alert01,
                                color: isSafe
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.error,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
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
