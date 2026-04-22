class Comment {
  final int id;
  final int postId;
  final int userId;
  final String userFirstName;
  final String userLastName;
  final String? userProfileImage;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    this.userProfileImage,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      postId: json['postId'] ?? 0,
      userId: json['userId'] ?? 0,
      userFirstName: json['userFirstName'] ?? '',
      userLastName: json['userLastName'] ?? '',
      userProfileImage: json['userProfileImage'],
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
