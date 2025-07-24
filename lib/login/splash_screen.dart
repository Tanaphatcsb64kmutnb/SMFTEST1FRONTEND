// splash_screen.dart - หน้าจอเริ่มต้นที่ตรวจสอบการเข้าสู่ระบบ
//ใช้ sharedPreferences แชร์ userId,firstname,lastname,points,userId เข้าไปในหน้า home,wishlist,navbar
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home.dart';
import 'login.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(Duration(seconds: 2)); // แสดง splash screen 2 วินาที

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final firstname = prefs.getString('firstname');
      final lastname = prefs.getString('lastname');
      final points = prefs.getInt('points');
      final userId = prefs.getString('userId');

      if (token != null && firstname != null && lastname != null && points != null && userId != null) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage(
        firstname: firstname,
        lastname: lastname,
        points: points,
        token: token,
        userId: userId,
      ),
    ),
  );
} else {
        // ไม่มี token ไปหน้า login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      }
    } catch (e) {
      // เกิดข้อผิดพลาด ไปหน้า login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[600],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.home,
                size: 60,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 32),
            
            // App Name
            Text(
              'Smile Challenge',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            
            Text(
              'ยินดีต้อนรับ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 48),
            
            // Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            
            Text(
              'กำลังตรวจสอบการเข้าสู่ระบบ...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}