class Post {
  final int id;
  final int workerId;
  final int workerUserId;
  final String workerFirstName;
  final String workerLastName;
  final String workerProfession;
  final String? workerProfileImage;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final int reactionCount;
  final int commentCount;
  final bool isLiked;
  final bool workerVerified;

  Post({
    required this.id,
    required this.workerId,
    required this.workerUserId,
    required this.workerFirstName,
    required this.workerLastName,
    required this.workerProfession,
    this.workerProfileImage,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
    this.reactionCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.workerVerified = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      workerId: json['workerId'] ?? 0,
      workerUserId: json['workerUserId'] ?? 0,
      workerFirstName: json['workerFirstName'] ?? '',
      workerLastName: json['workerLastName'] ?? '',
      workerProfession: json['workerProfession'] ?? '',
      workerProfileImage: json['workerProfileImage'],
      content: json['content'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      reactionCount: json['reactionCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      workerVerified: json['workerVerified'] ?? false,
    );
  }
}
