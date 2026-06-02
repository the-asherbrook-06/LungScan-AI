// Packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// Pages
import 'package:lungscan_ai/pages/splash_screen.dart';
import 'package:lungscan_ai/pages/welcome_page.dart';
import 'package:lungscan_ai/pages/history_page.dart';
import 'package:lungscan_ai/pages/results_page.dart';
import 'package:lungscan_ai/pages/upload_page.dart';
import 'package:lungscan_ai/pages/home_page.dart';

// Themes
import 'package:lungscan_ai/themes/theme.dart';
import 'package:lungscan_ai/themes/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LungScan_AI());
}

class LungScan_AI extends StatelessWidget {
  const LungScan_AI({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "Nunito");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.light(),
      darkTheme: theme.dark(),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/welcome': (_) => const WelcomePage(),
        '/home': (_) => const HomePage(),
        '/upload': (_) => const UploadPage(),
        '/results': (_) => const ResultsPage(),
        '/history': (_) => const HistoryPage(),
      },
    );
  }
}
