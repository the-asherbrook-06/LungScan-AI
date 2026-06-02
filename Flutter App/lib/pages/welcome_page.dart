// Packages
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lungscan_ai/controller/auth_controller.dart';
import 'package:svg_flutter/svg.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness == Brightness.light
        ? 'light'
        : 'dark';

    Future<void> _googleSignIn() async {
      try {
        User? user = await AuthController().signInWithGoogle();
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        log(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }

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
            Expanded(child: SizedBox(), flex: 2),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 52,
              child: ElevatedButton(onPressed: _googleSignIn, child: Text("Get Started")),
            ),
            SizedBox(
              height: MediaQuery.of(context).viewPadding.bottom,
              width: MediaQuery.of(context).size.width,
            ),
          ],
        ),
      ),
    );
  }
}
