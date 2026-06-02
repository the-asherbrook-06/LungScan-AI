// Packages
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:flutter/material.dart';
import 'package:lungscan_ai/controller/history_controller.dart';
import 'dart:io';

// Controller
import 'package:lungscan_ai/controller/photo_picker_controller.dart';
import 'package:lungscan_ai/controller/server_controller.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final PhotoPickerController _picker = PhotoPickerController();

  File? selectedImage;

  Future<void> pickFromGallery() async {
    final image = await _picker.pickFromGallery();
    if (image != null) {
      setState(() => selectedImage = image);
    }
  }

  Future<void> pickFromCamera() async {
    final image = await _picker.pickFromCamera();
    if (image != null) {
      setState(() => selectedImage = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: false, elevation: 1, title: Text("Upload Data")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            SizedBox(height: 16),
            Text(
              "DIAGNOSTIC PORTAL",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 8),
            Text("Analyze New Scan", style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 4),
            Text(
              "Upload a high-resolution Chest X-ray. Our AI will perfom a multi-layered diagnostic Analysis in seconds",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 32),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              child: Column(
                children: [
                  SizedBox(height: 24),

                  selectedImage == null
                      ? Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withAlpha(100),
                              child: Icon(HugeIconsStroke.fileUpload, size: 32),
                            ),
                            SizedBox(height: 24),
                            Text("Upload X-ray", style: Theme.of(context).textTheme.headlineSmall),
                            Text(
                              "PNG, JPG or JPEG (Max 25 MB)",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(selectedImage!, height: 250, fit: BoxFit.cover),
                        ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 70,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: pickFromGallery,
                      style: ButtonStyle(
                        elevation: WidgetStatePropertyAll(0.2),
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.primaryContainer,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            HugeIconsStroke.album02,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Select from Gallery",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 70,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: pickFromCamera,
                      style: ButtonStyle(
                        elevation: WidgetStatePropertyAll(0.2),
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.surfaceContainerHigh,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            HugeIconsStroke.camera03,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Capture Image",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
            SizedBox(height: 8),
            selectedImage != null
                ? SizedBox(
                    width: MediaQuery.of(context).size.width - 70,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedImage == null) return;
                        final result = await ServerController().uploadXray(selectedImage!);
                        if (result != null) {
                          final savedPath = await saveImageLocally(selectedImage!);

                          await HistoryController().saveResult(
                            result: result,
                            imagePath: savedPath,
                          );

                          Navigator.pushNamed(
                            context,
                            '/results',
                            arguments: {'image': selectedImage, 'result': result},
                          );
                        } else {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text("Upload failed")));
                        }
                      },
                      style: ButtonStyle(
                        elevation: WidgetStatePropertyAll(0.2),
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.secondaryContainer,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            HugeIconsStroke.album02,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Analyze the Image",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(),
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
                    "Your Data is Protected. Images are automatically de-identified to maintain HIPAA Clinical Compliance.",
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
