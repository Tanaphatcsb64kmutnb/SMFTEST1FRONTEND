import 'package:flutter/material.dart';
import 'package:myproject/login/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login/login.dart';
import 'login/splash_screen.dart';
import 'home/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // สำคัญสำหรับ async operations
  await dotenv.load(fileName: ".env"); // โหลดไฟล์ .env
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MongoDB App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: SplashScreen(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        // '/home': (context) => HomePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}