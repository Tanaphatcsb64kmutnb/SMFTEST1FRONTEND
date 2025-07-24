//checkemail and passw in db
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseService {
  static final String connectionString = dotenv.env['MONGO_CONN']!;
  static final String databaseName = dotenv.env['MONGO_DB_NAME']!;
  static const String usersCollection = 'users';
  
  static Db? _db;
  static DbCollection? _usersCollection;

  // เชื่อมต่อฐานข้อมูล
  static Future<void> connect() async {
    try {
      _db = await Db.create('$connectionString$databaseName');
      await _db!.open();
      _usersCollection = _db!.collection(usersCollection);
      print('เชื่อมต่อ MongoDB สำเร็จ');
    } catch (e) {
      print('เชื่อมต่อ MongoDB ไม่สำเร็จ: $e');
      rethrow;
    }
  }

  // ปิดการเชื่อมต่อ
  static Future<void> close() async {
    await _db?.close();
  }



  // สมัครสมาชิค
  static Future<bool> registerUser(String username, String password, String email) async {
    try {
      // ตรวจสอบว่ามี username นี้อยู่แล้วหรือไม่
      var existingUser = await _usersCollection!.findOne(where.eq('username', username));
      if (existingUser != null) {
        print('Username นี้มีอยู่แล้ว');
        return false;
      }

      // บันทึกข้อมูลผู้ใช้ (เก็บ password แบบ plain text)
      await _usersCollection!.insertOne({
        'username': username,
        'password': password, // เก็บ plain text
        'email': email,
        'created_at': DateTime.now(),
      });

      print('สมัครสมาชิกสำเร็จ');
      return true;
    } catch (e) {
      print('สมัครสมาชิกไม่สำเร็จ: $e');
      return false;
    }
  }

  // เข้าสู่ระบบ - ใช้ plain text password
  static Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    try {
      var user = await _usersCollection!.findOne(where
          .eq('username', username)
          .eq('password', password)); // เปรียบเทียบ plain text

      if (user != null) {
        print('เข้าสู่ระบบสำเร็จ');
        return user;
      } else {
        print('Username หรือ Password ไม่ถูกต้อง');
        return null;
      }
    } catch (e) {
      print('เข้าสู่ระบบไม่สำเร็จ: $e');
      return null;
    }
  }

  // ตรวจสอบสถานะการเชื่อมต่อ
  static bool isConnected() {
    return _db != null && _db!.isConnected;
  }
}