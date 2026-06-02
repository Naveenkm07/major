import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isDiscussions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Column(
            children: [
              // ─── Header ────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                color: AppTheme.primaryGreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              },
                              child: const Icon(Icons.arrow_back, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            const Text('Community', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.more_horiz, color: Colors.white),
                            const SizedBox(width: 16),
                            Container(width: 8, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Toggle
                    Container(
                      height: 44,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(22)),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isDiscussions = true),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isDiscussions ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Discussions',
                                  style: TextStyle(
                                    color: _isDiscussions ? AppTheme.primaryGreen : Colors.white,
                                    fontWeight: _isDiscussions ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isDiscussions = false),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !_isDiscussions ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Equipment Map',
                                  style: TextStyle(
                                    color: !_isDiscussions ? AppTheme.primaryGreen : Colors.white,
                                    fontWeight: !_isDiscussions ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Posts List ────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildPostCard(
                      initials: 'SK',
                      avatarColor: AppTheme.primaryGreen,
                      name: 'Suresh Kumar',
                      time: 'Hassan • 2h ago',
                      content: 'My ragi crop is flowering well this season! Used organic compost. Anyone else trying organic?',
                      likes: '124',
                      comments: '38',
                      hasImages: true,
                    ),
                    const SizedBox(height: 16),
                    _buildPostCard(
                      initials: 'LP',
                      avatarColor: AppTheme.accent,
                      name: 'Lakshmi P.',
                      time: 'Mandya • 5h ago',
                      content: 'Renting out my tractor this weekend. ₹500/hour. DM if interested 🚜',
                      likes: '52',
                      comments: '12',
                      hasTractorIcon: true,
                    ),
                    const SizedBox(height: 16),
                    _buildPostCard(
                      initials: 'MK',
                      avatarColor: Colors.teal,
                      name: 'Manjunath K.',
                      time: 'Mysuru • 8h ago',
                      content: 'Has anyone seen the new Mandi prices for onions today? Wondering if I should hold off on selling this week.',
                      likes: '15',
                      comments: '4',
                    ),
                    const SizedBox(height: 16),
                    _buildPostCard(
                      initials: 'RG',
                      avatarColor: Colors.brown,
                      name: 'Ramesh Gowda',
                      time: 'Chitradurga • 1d ago',
                      content: 'My sugarcane yield increased by 20% after switching to the new drip irrigation method. Highly recommend it to everyone facing water scarcity.',
                      likes: '210',
                      comments: '45',
                    ),
                    const SizedBox(height: 16),
                    _buildPostCard(
                      initials: 'AS',
                      avatarColor: Colors.indigo,
                      name: 'Anil Sharma',
                      time: 'Tumkur • 1d ago',
                      content: 'Looking to rent a rotavator for 2 days. Please let me know if anyone nearby has one available.',
                      likes: '8',
                      comments: '3',
                      hasTractorIcon: true,
                    ),
                    const SizedBox(height: 90), // extra padding at bottom
                  ],
                ),
              ),
            ],
          ),
          
          // ─── Floating Button ─────────────────
          Positioned(
            bottom: 100, // moved up further to avoid overlapping with scaffold FAB
            right: 24,
            child: ElevatedButton.icon(
              onPressed: () => _showNewPostBottomSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('New Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard({
    required String initials,
    required Color avatarColor,
    required String name,
    required String time,
    required String content,
    required String likes,
    required String comments,
    bool hasImages = false,
    bool hasTractorIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              if (hasTractorIcon) const Icon(Icons.agriculture, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
          
          // Images Placeholder
          if (hasImages) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(color: const Color(0xFF7CB342), borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(color: const Color(0xFF7CB342), borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          // Action Bar
          Row(
            children: [
              const Icon(Icons.thumb_up_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(likes, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(width: 24),
              const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(comments, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  void _showNewPostBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create New Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post created successfully!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Post'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
