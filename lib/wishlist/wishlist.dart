//wishlist
import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/custom_footer.dart';
import '../home/home.dart';
import '../widgets/reward_list_widget.dart'; // ✅ เพิ่ม import นี้

class WishlistPage extends StatefulWidget {
  final String firstname;
  final String lastname;
  final int points;
  final String token;
  final String userId;

  const WishlistPage({
    Key? key,
    required this.firstname,
    required this.lastname,
    required this.points,
    required this.token,
    required this.userId,
  }) : super(key: key);

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  int currentPoints = 0;

  @override
  void initState() {
    super.initState();
    currentPoints = widget.points;
    _refreshUserInfo();
  }

  Future<void> _refreshUserInfo() async {
    try {
      final user = await NetworkService.fetchUserById(widget.userId);
      setState(() {
        currentPoints = user['points'];
      });
    } catch (e) {
      print("Error refreshing user info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    'Wishlist',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ ใช้ RewardListWidget
          Expanded(
            child: RewardListWidget(
              userId: widget.userId,
              userPoints: currentPoints,
              isWishlist: true,
              onPointsChanged: (newPoints) {
                setState(() {
                  currentPoints = newPoints;
                });
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: CustomFooter(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  userId: widget.userId,
                  firstname: widget.firstname,
                  lastname: widget.lastname,
                  points: currentPoints,
                  token: widget.token,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
