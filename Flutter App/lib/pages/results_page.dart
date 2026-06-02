import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  // 🎨 Color logic
  Color getColor(String disease, double confidence) {
    if (disease == "No Finding") return Colors.blue;

    if (confidence >= 0.75) return Colors.red;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.green;
  }

  // 📊 Result Card
  Widget buildResultItem(Map item, BuildContext context) {
    final double confidence = item['confidence'];
    final String disease = item['disease'];
    final String percent = (confidence * 100).toStringAsFixed(1);
    final color = getColor(disease, confidence);

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(disease, style: Theme.of(context).textTheme.bodyLarge)),
                Text("$percent%", style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 8,
                color: color,
                backgroundColor: color.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 Section Color
  Color _getSectionColor(String title) {
    if (title.contains("High")) return Colors.red;
    if (title.contains("Medium")) return Colors.orange;
    if (title.contains("Low")) return Colors.green;
    if (title.contains("Finding")) return Colors.blue;
    return Colors.grey;
  }

  // 📂 Accordion Section
  Widget buildSection(String title, List items, BuildContext context, {bool expanded = false}) {
    if (items.isEmpty) return const SizedBox();

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          title: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: _getSectionColor(title), shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _getSectionColor(title).withOpacity(0.1),
                ),
                child: Text(
                  "${items.length}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: _getSectionColor(title)),
                ),
              ),
            ],
          ),
          children: items.map<Widget>((item) => buildResultItem(item, context)).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    final File image = args['image'];
    final Map<String, dynamic> result = args['result'];

    List details = List.from(result['details']);
    details.sort((a, b) => b['confidence'].compareTo(a['confidence']));

    final top = details.first;

    // ✅ CORRECT LOGIC
    final bool isAbnormal = top['disease'] != "No Finding";
    final bool isNoFindingTop = !isAbnormal;

    final String predictionText = isAbnormal
        ? "Abnormal Findings Detected"
        : "No Findings Detected";

    final Color predictionColor = isAbnormal ? Theme.of(context).colorScheme.error : Colors.green;

    final filtered = details.where((d) => d['disease'] != "No Finding").toList();
    final noFinding = details.where((d) => d['disease'] == "No Finding").toList();

    List high = [];
    List medium = [];
    List low = [];

    for (var item in filtered) {
      double c = item['confidence'];

      if (c >= 0.75) {
        high.add(item);
      } else if (c >= 0.6) {
        medium.add(item);
      } else {
        low.add(item);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Analysis Results")),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
          children: [
            // 🖼️ Image
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.file(image, height: 300, fit: BoxFit.cover),
            ),

            const SizedBox(height: 16),

            // 🧠 Result Text (FIXED)
            Row(
              children: [
                Text("Result: ", style: Theme.of(context).textTheme.headlineSmall),
                Expanded(
                  child: Text(
                    predictionText,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: predictionColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 🥇 Top Result
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(HugeIconsStroke.cardiogram02),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Most Likely: ${top['disease']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text("${(top['confidence'] * 100).toStringAsFixed(1)}%"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text("Detailed Analysis", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),

            // 📂 Sections
            if (!isNoFindingTop) ...[
              buildSection("High Confidence", high, context, expanded: true),
              buildSection("Medium Confidence", medium, context),
              buildSection("Low Confidence", low, context),
            ] else ...[
              buildSection("Finding", noFinding, context, expanded: true),
              buildSection("Medium Confidence", medium, context),
              buildSection("Low Confidence", low, context),
            ],
          ],
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
