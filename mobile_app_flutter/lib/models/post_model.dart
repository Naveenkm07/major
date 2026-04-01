/// Community Post model matching CommunityPost Mongoose schema
class PostModel {
  final String id;
  final String content;
  final String? imageUrl;
  final String category;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final List<String> likes;
  final Map<String, dynamic>? author;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.content,
    this.imageUrl,
    this.category = 'general',
    this.tags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.likes = const [],
    this.author,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        id: json['_id'] ?? '',
        content: json['content'] ?? '',
        imageUrl: json['imageUrl'],
        category: json['category'] ?? 'general',
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        likeCount: json['likeCount'] ?? (json['likes'] as List?)?.length ?? 0,
        commentCount: json['commentCount'] ?? 0,
        likes: (json['likes'] as List?)?.map((e) => e.toString()).toList() ?? [],
        author: json['author'] ?? json['farmerId'],
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'content': content,
        'imageUrl': imageUrl,
        'category': category,
        'tags': tags,
      };
}
