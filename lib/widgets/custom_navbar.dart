//navbarshow status of user
import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget {
  final String firstname;
  final String lastname;
  final int points;
  final String userId;
  final VoidCallback onSignOut;

  const CustomNavbar({
    Key? key,
    required this.firstname,
    required this.lastname,
    required this.points,
    required this.userId,
    required this.onSignOut,
  }) : super(key: key);

  String _formatUserId(String userId) {
    
    if (userId.isEmpty || userId == 'null') return 'N/A';
    if (userId.length <= 8) return userId;
    return '${userId.substring(0, 8)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 18,
        left: 16,
        right: 16,
        bottom: 12,
      ),
    
      child: Row(
        children: [
          // Left - Username & Points
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // เพิ่มเพื่อป้องกัน overflow
              children: [
                Text(
                  'คุณ $firstname $lastname',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis, // ป้องกันข้อความยาวเกิน
                ),
                SizedBox(height: 2),
                Text(
                  '$points points',
                  style: TextStyle(
                    color: const Color.fromARGB(179, 0, 0, 0),
                    fontSize: 14,
                  ),
                ),
               
              ],
            ),
          ),
          
        ElevatedButton(
            onPressed: onSignOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size(0, 36),
              shape: RoundedRectangleBorder( // ← เพิ่มส่วนนี้เข้าไป
                borderRadius: BorderRadius.zero, // มุม 0 = สี่เหลี่ยม
              ),
            ),
            child: Text(
              'Sign Out',
              style: TextStyle(fontSize: 14),
            ),
          ),

        ],
      ),
    );
  }
}