import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedCategory = 'all';

  final _categories = [
    {'key': 'all', 'label': 'all', 'icon': Icons.apps_rounded},
    {'key': 'crop_advice', 'label': 'crop_advice', 'icon': Icons.eco_rounded},
    {'key': 'market_discussion', 'label': 'market_discussion', 'icon': Icons.trending_up_rounded},
    {'key': 'success_story', 'label': 'success_story', 'icon': Icons.emoji_events_rounded},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<CommunityProvider>(context, listen: false).fetchPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.t(context, 'farmer_community')),
        actions: [const LanguageToggle(), const SizedBox(width: 10)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewPostDialog(context),
        icon: const Icon(Icons.edit_rounded),
        label: Text(AppLocale.t(context, 'post')),
      ),
      body: Column(
        children: [
          // ─── Category Chips ────────────────────
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _categories.map((cat) {
                final selected = _selectedCategory == cat['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(cat['icon'] as IconData, size: 16,
                        color: selected ? AppTheme.communityTeal : AppTheme.textHint),
                    label: Text(AppLocale.t(context, cat['label'] as String)),
                    selected: selected,
                    selectedColor: AppTheme.communityTeal.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: selected ? AppTheme.communityTeal : AppTheme.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat['key'] as String);
                      Provider.of<CommunityProvider>(context, listen: false)
                          .fetchPosts(category: _selectedCategory == 'all' ? null : _selectedCategory);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // ─── Posts Feed ────────────────────────
          Expanded(
            child: Consumer<CommunityProvider>(
              builder: (_, community, __) {
                if (community.isLoading) return const Center(child: CircularProgressIndicator());
                if (community.posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_rounded, size: 56, color: AppTheme.textHint),
                        const SizedBox(height: 12),
                        Text(AppLocale.t(context, 'no_posts')),
                        Text(AppLocale.t(context, 'be_first'), style: const TextStyle(color: AppTheme.textHint)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => community.fetchPosts(category: _selectedCategory == 'all' ? null : _selectedCategory),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: community.posts.length,
                    itemBuilder: (_, i) => _PostCard(post: community.posts[i], community: community),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNewPostDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocale.t(context, 'share_post'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(hintText: AppLocale.t(context, 'post_hint')),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Provider.of<CommunityProvider>(context, listen: false).createPost(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: Text(AppLocale.t(context, 'post')),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final CommunityProvider community;

  const _PostCard({required this.post, required this.community});

  @override
  Widget build(BuildContext context) {
    final likes = (post['likes'] as List?)?.length ?? post['likeCount'] ?? 0;
    final comments = (post['comments'] as List?)?.length ?? post['commentCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.communityTeal.withOpacity(0.15),
                child: const Icon(Icons.person_rounded, color: AppTheme.communityTeal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['author']?['name'] ?? 'Farmer', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(post['category'] ?? 'general', style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          Text(post['content'] ?? '', style: const TextStyle(fontSize: 14, height: 1.5)),

          // Tags
          if (post['tags'] != null && (post['tags'] as List).isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: (post['tags'] as List).map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.communityTeal.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                    child: Text('#$t', style: const TextStyle(fontSize: 11, color: AppTheme.communityTeal)),
                  )).toList(),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () => community.toggleLike(post['_id']),
                child: Row(
                  children: [
                    Icon(Icons.thumb_up_rounded, size: 18, color: AppTheme.textHint),
                    const SizedBox(width: 4),
                    Text('$likes', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Icon(Icons.comment_rounded, size: 18, color: AppTheme.textHint),
                  const SizedBox(width: 4),
                  Text('$comments', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
              const Spacer(),
              Icon(Icons.share_rounded, size: 18, color: AppTheme.textHint),
            ],
          ),
        ],
      ),
    );
  }
}
