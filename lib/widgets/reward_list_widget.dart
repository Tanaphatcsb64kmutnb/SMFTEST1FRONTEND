//geteveryrewardindatabase and modify for home and wishlist
import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../reward_detail/reward_detail.dart';

class RewardListWidget extends StatefulWidget {
  final String userId;
  final int userPoints;
  final bool isWishlist;
  final Function(int)? onPointsChanged;

  const RewardListWidget({
    Key? key,
    required this.userId,
    required this.userPoints,
    this.isWishlist = false,
    this.onPointsChanged,
  }) : super(key: key);

  @override
  _RewardListWidgetState createState() => _RewardListWidgetState();
}

class _RewardListWidgetState extends State<RewardListWidget> {
  List<dynamic> rewards = [];
  Set<String> favoriteRewardIds = {};
  bool isLoading = true;
  int currentPoints = 0;

  @override
  void initState() {
    super.initState();
    currentPoints = widget.userPoints;
    _loadRewards();
  }

  // Logic การดึงข้อมูลของคุณยังอยู่เหมือนเดิม
  Future<void> _loadRewards() async {
    try {
      final allRewards = await NetworkService.fetchRewards();
      final savedIds = await NetworkService.fetchSavedRewardIds(widget.userId);

      final filtered = widget.isWishlist
          ? allRewards.where((r) => savedIds.contains(r['_id'])).toList()
          : allRewards;

      setState(() {
        rewards = filtered;
        favoriteRewardIds = savedIds.toSet();
        isLoading = false;
      });
    } catch (e) {
      print("Error loading rewards: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    if (rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              widget.isWishlist ? "ไม่มีรางวัลใน Wishlist" : "ไม่มีรางวัล",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // ⭐ ปรับ GridView เป็น .builder เพื่อประสิทธิภาพที่ดีขึ้น และปรับสัดส่วน
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75, // ปรับสัดส่วนการ์ดให้สูงขึ้นเล็กน้อย
        ),
        itemCount: rewards.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final reward = rewards[index];
          final isFavorite = favoriteRewardIds.contains(reward['_id']);

          return GestureDetector(
            onTap: () async {
               final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RewardDetailPage(
                        reward: reward,
                        userId: widget.userId,
                        userPoints: currentPoints,
                      ),
                    ),
                  );

                  // Logic การจัดการผลลัพธ์ของคุณยังอยู่เหมือนเดิม
                  if (result != null) {
                    if (result is Map && result['success'] == true) {
                      setState(() {
                        currentPoints = result['newPoints'];
                      });
                      widget.onPointsChanged?.call(currentPoints);
                      await _loadRewards();
                    }
                    else if (result is Map && result['favoriteChanged'] == true) {
                      final rewardId = result['rewardId'];
                      final newFavoriteState = result['isFavorite'];
                      
                      setState(() {
                        if (newFavoriteState) {
                          favoriteRewardIds.add(rewardId);
                        } else {
                          favoriteRewardIds.remove(rewardId);
                        }
                        
                        if (widget.isWishlist && !newFavoriteState) {
                          rewards.removeWhere((r) => r['_id'] == rewardId);
                        }
                      });
                    }
                  }
            },
            // ⭐ ปรับแก้ Container และเนื้อหาภายในทั้งหมด
            child: Container(
             
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ส่วนของรูปภาพ
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                             color: Colors.grey.shade200, // พื้นหลัง placeholder
                             borderRadius: BorderRadius.circular(8),
                          ),
                          child: reward['image_url'] != null && reward['image_url'].isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    reward['image_url'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey.shade500);
                                    },
                                  ),
                                )
                              // Placeholder กรณีไม่มี URL หรือ URL เป็นค่าว่าง
                              : Icon(Icons.photo_size_select_actual_outlined, size: 40, color: Colors.grey.shade500),
                        ),
                      ),
                      // ส่วนของข้อความ
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          reward['name'] ?? 'Reward Name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
                        child: Text(
                          "${reward['reward_points'] ?? 'XXX'} Points",
                          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  // ปุ่มหัวใจ
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        // Logic การกดหัวใจของคุณยังอยู่เหมือนเดิม
                        final id = reward['_id'];
                        final wasLiked = isFavorite;
                        
                        setState(() {
                          if (wasLiked) {
                            favoriteRewardIds.remove(id);
                            if (widget.isWishlist) {
                              rewards.removeWhere((r) => r['_id'] == id);
                            }
                          } else {
                            favoriteRewardIds.add(id);
                          }
                        });

                        try {
                          if (wasLiked) {
                            await NetworkService.removeFromSave(widget.userId, id);
                          } else {
                            await NetworkService.addToSave(widget.userId, id);
                          }
                        } catch (e) {
                          print("❌ Error updating favorite: $e");
                          setState(() {
                            if (wasLiked) {
                              favoriteRewardIds.add(id);
                              if (widget.isWishlist) {
                                _loadRewards();
                              }
                            } else {
                              favoriteRewardIds.remove(id);
                            }
                          });
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                            );
                          }
                          
                        }
                      },
                   child: Container(
  padding: EdgeInsets.all(4),
  decoration: BoxDecoration(
    color: isFavorite ? Colors.black : Colors.white.withOpacity(0.7),
    shape: BoxShape.circle,
  ),
  child: isFavorite
      ? Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.favorite,
              color: Colors.white,
              size: 26, // ใหญ่กว่าไอคอนจริง
            ),
            Icon(
              Icons.favorite,
              color: Colors.black,
              size: 22, // เล็กกว่านิดนึง
            ),
          ],
        )
      : Icon(
          Icons.favorite_border,
          color: Colors.black,
          size: 24,
        ),
),

                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}