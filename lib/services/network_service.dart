//getapifrombackend and modify in frontend (ตั้งค่าว่าจะใช้ cloud หรือ localhost)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NetworkService {
  
  // ใช้ค่าจาก .env file แทนการ hardcode
  // static const String baseUrl = 'http://localhost:3000'; // เอา comment ออกเพื่อใช้กับ localhost
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  // ฟังก์ชันสำหรับสมัครสมาชิก
  static Future<Map<String, dynamic>> registerUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/registration'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ฟังก์ชันสำหรับเข้าสู่ระบบ - รองรับ response ใหม่ที่มี user data
  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        // Handle different error status codes
        String errorMessage = responseData['error'] ?? 'Login failed';
        
        switch (response.statusCode) {
          case 404:
            errorMessage = 'ไม่พบผู้ใช้งานนี้ในระบบ';
            break;
          case 401:
            errorMessage = 'รหัสผ่านไม่ถูกต้อง';
            break;
          case 500:
            errorMessage = 'เกิดข้อผิดพลาดภายในเซิร์ฟเวอร์';
            break;
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    }
  }

  // ฟังก์ชันสำหรับอัพเดท points (เพิ่มใหม่)
  static Future<Map<String, dynamic>> updateUserPoints(String token, int newPoints) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-points'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'points': newPoints,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['error'] ?? 'Failed to update points');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ฟังก์ชันสำหรับดึงข้อมูล user profile (เพิ่มใหม่)
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['error'] ?? 'Failed to get user profile');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ฟังก์ชันดึง reward ทั้งหมด
  static Future<List<dynamic>> fetchRewards() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rewards'));
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        return responseData['rewards'];
      } else {
        throw Exception(responseData['error'] ?? 'Failed to fetch rewards');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<void> addToSave(String userId, String rewardId) async {
    final url = Uri.parse('$baseUrl/saves');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'user_id': userId,
        'reward_id': rewardId,
      }),
    );

    if (response.statusCode != 201) {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message'] ?? 'Failed to save reward');
    }
  }

  static Future<List<String>> fetchSavedRewardIds(String userId) async {
    final url = Uri.parse('$baseUrl/saves/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['savedRewardIds']);
    } else {
      throw Exception('Failed to fetch saved rewards');
    }
  }

  //ลบได้
  static Future<void> removeFromSave(String userId, String rewardId) async {
    final url = Uri.parse('$baseUrl/saves/$userId/$rewardId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to remove from save');
    }
  }

  // แทนที่เมธอด redeemReward ใน network_service.dart
  static Future<Map<String, dynamic>> redeemReward({
    required String userId,
    required String rewardId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/redeem'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'rewardId': rewardId,
          // ลบ newPoints ออก เพราะ backend จะคำนวณเอง
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['status'] == true) {
        return {
          'success': true,
          'newPoints': responseData['newPoints'], // รับแต้มใหม่จาก backend
          'userReward': responseData['userReward'],
          'message': responseData['message']
        };
      } else {
        throw Exception(responseData['error'] ?? 'Failed to redeem reward');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchUserById(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == true) {
      return data['user'];
    } else {
      throw Exception(data['error'] ?? 'Failed to fetch user');
    }
  }
}