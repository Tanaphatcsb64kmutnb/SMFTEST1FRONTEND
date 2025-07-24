//home
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/network_service.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/custom_footer.dart';
import '../widgets/reward_list_widget.dart';
import '../wishlist/wishlist.dart';
import '../dialog/logout_dialog.dart';

class HomePage extends StatefulWidget {
  final String firstname;
  final String lastname;
  final int points;
  final String token;
  final String userId;

  const HomePage({
    Key? key,
    required this.firstname,
    required this.lastname,
    required this.points,
    required this.token,
    required this.userId,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;
  int currentPoints = 0;

  @override
  void initState() {
    super.initState();
    currentPoints = widget.points; // เริ่มต้นจาก widget
    _refreshUserInfo(); // โหลดใหม่จาก backend
    _scrollController = ScrollController();
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        //navbar
        children: [
          SafeArea(
            child: CustomNavbar(
              firstname: widget.firstname,
              lastname: widget.lastname,
              points: currentPoints,
              userId: widget.userId,
              onSignOut: () {
              LogoutDialog.show(context);
            },

            ),
          ),
          //reward
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RewardListWidget(
                  userId: widget.userId,
                  userPoints: currentPoints,
                  isWishlist: false,
                  onPointsChanged: (newPoints) {
                    setState(() {
                      currentPoints = newPoints;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      //footer
      bottomNavigationBar: CustomFooter(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WishlistPage(
                  firstname: widget.firstname,
                  lastname: widget.lastname,
                  points: currentPoints,
                  token: widget.token,
                  userId: widget.userId,
                ),
              ),
            );
          }
        },
      ),
    );
  }


}

