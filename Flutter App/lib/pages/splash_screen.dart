// Packages
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

// Controller
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      final user = FirebaseAuth.instance.currentUser;
      if (!mounted) return;
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness == Brightness.light
        ? 'light'
        : 'dark';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(child: SizedBox()),
            SvgPicture.asset('assets/$brightness/logo.svg'),
            SizedBox(height: 48),
            Text("LungScan AI", style: Theme.of(context).textTheme.displayMedium),
            Text("AI-powered Chest X-ray Diagnosis", style: Theme.of(context).textTheme.bodyLarge),
            Expanded(child: SizedBox()),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: LinearProgressIndicator(year2023: false),
            ),
            SizedBox(height: 16),
            Text(
              "Initializing...",
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            // Expanded(child: SizedBox()),
            SizedBox(height: 24),
            Text(
              "Version 0.1.0",
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).viewPadding.bottom,
            ),
          ],
        ),
      ),
    );
  }
}
