class FeedPost {
  final String id;
  final String caption;
  final String createdAt;
  final String userUid;
  final String publicUrl;
  final String profileImageUrl;

  FeedPost({
    required this.id,
    required this.caption,
    required this.createdAt,
    required this.userUid,
    required this.publicUrl,
    required this.profileImageUrl,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json["id"] ?? "",
      caption: json["caption"] ?? "",
      createdAt: json["created_at"] ?? "",
      userUid: json["user_uid"] ?? "",
      publicUrl: json["public_url"] ?? "",
      profileImageUrl: json["profileImageUrl"] ?? "",  // IMPORTANTE
    );
  }
}
