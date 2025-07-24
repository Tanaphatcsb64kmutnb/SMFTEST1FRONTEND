//login
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/network_service.dart';
import '../home/home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isLoginMode = true; // true = Login, false = Register
  bool _obscurePassword = true;

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveUserData(String token, String email, String firstname, String lastname, int points, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('email', email);
      await prefs.setString('firstname', firstname);
      await prefs.setString('lastname', lastname);
      await prefs.setInt('points', points);
      await prefs.setString('userId',userId);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      var response = await NetworkService.loginUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (response['status'] == true) {
        // ดึงข้อมูลจาก response
        String token = response['token'];
        Map<String, dynamic> userData = response['user'];
        
        // ✅ แก้ไขการจัดการ userId
        String userId = '';
        if (userData['_id'] != null) {
          var userIdData = userData['_id'];
          if (userIdData is Map && userIdData.containsKey('\$oid')) {
            userId = userIdData['\$oid'].toString();
          } else if (userIdData is String) {
            userId = userIdData;
          } else {
            userId = userIdData.toString();
          }
        }

        String username = userData['username'] ?? _extractUsernameFromEmail(_emailController.text);
        int points = userData['points'] ?? 10000;
        String email = userData['email'] ?? _emailController.text.trim();
        String firstname = userData['firstname'] ?? '';
        String lastname = userData['lastname'] ?? '';

        

        // บันทึกข้อมูลลง SharedPreferences
        await _saveUserData(token, email, firstname,lastname, points, userId);

        _showSnackBar('เข้าสู่ระบบสำเร็จ');

        if (mounted) {
          // นำทางไปยัง HomePage พร้อมส่งข้อมูล
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
        }
      } else {
        _showSnackBar('Email หรือ Password ไม่ถูกต้อง', isError: true);
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      _showSnackBar('เกิดข้อผิดพลาด: $errorMessage', isError: true);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      var response = await NetworkService.registerUser(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (response['status'] == true) {
        _showSnackBar('สมัครสมาชิกสำเร็จ กรุณาเข้าสู่ระบบ');
        setState(() => _isLoginMode = true);
        _clearForm();
      } else {
        _showSnackBar(response['success'] ?? 'การสมัครสมาชิกล้มเหลว', isError: true);
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      _showSnackBar('เกิดข้อผิดพลาดในการสมัคร: $errorMessage', isError: true);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _extractUsernameFromEmail(String email) {
    return email.split('@')[0];
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
      _clearForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            // ใช้ SingleChildScrollView เพื่อป้องกันปัญหา Overflow เวลาคีย์บอร์ดเด้งขึ้นมา
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top spacing
                  SizedBox(height: 80),
                  
                  // App Title
                  Text(
                    'smileReward',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  // 🔥🔥 แก้ไขตรงนี้: ใช้ SizedBox ควบคุมระยะห่างแทน Expanded 🔥🔥
                  SizedBox(height: 70), // <-- ปรับความสูงตรงนี้ได้ตามต้องการ
                  
                  // Email Field
                  Container(
                    height: 56,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณาใส่ Email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Wrong Email Format!';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  SizedBox(height: 5),
                  
                  // Password Field
                  Container(
                     width: double.infinity,
                      height: 56,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword 
                                ? Icons.visibility_off_outlined 
                                : Icons.visibility_outlined,
                            color: Colors.grey[500],
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาใส่ Password';
                        }
                        if (value.length < 8) {
                          return 'Password at least 8 characters ';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 24),
                  
                  // Sign In Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading 
                          ? null 
                          : (_isLoginMode ? _handleLogin : _handleRegister),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isLoginMode ? 'Sign In' : 'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20), // เพิ่มระยะห่างด้านล่างเผื่อไว้
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}