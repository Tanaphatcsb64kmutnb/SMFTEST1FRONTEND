//reward detail page
import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../widgets/custom_navbar.dart';
import '../dialog/redeem_confirm_dialog.dart';

class RewardDetailPage extends StatefulWidget {
  final Map<String, dynamic> reward;
  final String userId;
  final int userPoints;

  const RewardDetailPage({
    Key? key,
    required this.reward,
    required this.userId,
    required this.userPoints,
  }) : super(key: key);

  @override
  _RewardDetailPageState createState() => _RewardDetailPageState();
}

class _RewardDetailPageState extends State<RewardDetailPage> {
  bool isFavorite = false;
  int currentUserPoints = 0;
  bool isRedeeming = false;

  @override
  void initState() {
    super.initState();
    currentUserPoints = widget.userPoints;
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      final savedIds = await NetworkService.fetchSavedRewardIds(widget.userId);
      setState(() {
        isFavorite = savedIds.contains(widget.reward['_id']);
      });
    } catch (e) {
      print("Error checking favorite status: $e");
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (isFavorite) {
        await NetworkService.removeFromSave(widget.userId, widget.reward['_id']);
      } else {
        await NetworkService.addToSave(widget.userId, widget.reward['_id']);
      }
      
      setState(() {
        isFavorite = !isFavorite;
      });
      
      // ส่งผลลัพธ์กลับไปหน้าก่อนหน้า พร้อมสถานะว่ามีการเปลี่ยนแปลงหัวใจ
      Navigator.pop(context, {
        'favoriteChanged': true,
        'rewardId': widget.reward['_id'],
        'isFavorite': isFavorite,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

// แทนที่เมธอด _redeemReward ใน reward_detail.dart

Future<void> _redeemReward() async {
  final rewardPoints = widget.reward['reward_points'] as int;
  
  // ตรวจสอบแต้มก่อน
  if (currentUserPoints < rewardPoints) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('แต้มไม่เพียงพอ! คุณมี $currentUserPoints แต้ม แต่ต้องใช้ $rewardPoints แต้ม'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // แสดง dialog ยืนยัน
  final bool? confirmed = await showRedeemConfirmDialog(context);
  
  if (confirmed == true) {
    setState(() {
      isRedeeming = true;
    });

    try {
      // เรียก API เพื่อ redeem (ไม่ต้องส่ง newPoints)
      final result = await NetworkService.redeemReward(
        userId: widget.userId,
        rewardId: widget.reward['_id'],
      );

      if (result['success'] == true) {
        final newPoints = result['newPoints'] as int;
        
        setState(() {
          currentUserPoints = newPoints; // อัพเดทแต้มจาก backend
          isRedeeming = false;
        });

        // แสดงข้อความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('แลกสำเร็จ! แต้มคงเหลือ: $newPoints'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // รอให้ SnackBar แสดงเสร็จแล้วค่อย redirect
        await Future.delayed(Duration(seconds: 1));

        // กลับไปหน้าก่อนหน้าพร้อมข้อมูลใหม่
        Navigator.pop(context, {
          'success': true,
          'newPoints': newPoints,
          'userReward': result['userReward'],
        });
      }
    } catch (e) {
      setState(() {
        isRedeeming = false;
      });
      
      String errorMessage = 'เกิดข้อผิดพลาด: $e';
      
      // แปลข้อความ error ให้เป็นภาษาไทย
      if (e.toString().contains('Insufficient points')) {
        errorMessage = 'แต้มไม่เพียงพอสำหรับการแลกรางวัลนี้';
      } else if (e.toString().contains('User not found')) {
        errorMessage = 'ไม่พบข้อมูลผู้ใช้';
      } else if (e.toString().contains('Reward not found')) {
        errorMessage = 'ไม่พบรางวัลที่เลือก';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final rewardPoints = widget.reward['reward_points'] as int;
    final canRedeem = currentUserPoints >= rewardPoints;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Top section with image
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reward Image with placeholder
                  Expanded(
  flex: 2,
  child: widget.reward['image_url'] != null
      ? Image.network(
          widget.reward['image_url'],
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        )
      : Container(
          width: double.infinity,
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
        ),
),

                ],
              ),
            ),
          ),
          // Bottom section with details
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and heart icon row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.reward['name'] ?? 'No name',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                     IconButton(
                         icon: isFavorite
                      ? Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black, // กรอบนอกสุดเป็นวงกลมสีดำ
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Colors.white, // ขอบสีขาว
                                size: 30,
                              ),
                              Icon(
                                Icons.favorite,
                                color: Colors.black, // หัวใจสีดำ
                                size: 24,
                              ),
                            ],
                          ),
                        )
                      : Icon(
                          Icons.favorite_border,
                          color: Colors.grey,
                          size: 28,
                        ),
                  onPressed: _toggleFavorite,
                ),

                      ],
                    ),
                    
                    SizedBox(height: 4),
                    
                    // Points
                    Text(
                      '$rewardPoints Points',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Detail section
                    Text(
                      'Detail',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    // Description
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          widget.reward['reward_desc'] ?? 'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using "Content here, content here", making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for "lorem ipsum" will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Redeem Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: canRedeem && !isRedeeming ? _redeemReward : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canRedeem ? Colors.black : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: isRedeeming
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('กำลังแลก...'),
                                ],
                              )
                            : Text(
                                'Redeem',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}