class Review {
  final int id;
  final int userId;
  final String userFirstName;
  final String userLastName;
  final String? userProfileImage;
  final int workerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    this.userProfileImage,
    required this.workerId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      userFirstName: json['userFirstName'] ?? '',
      userLastName: json['userLastName'] ?? '',
      userProfileImage: json['userProfileImage'],
      workerId: json['workerId'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}
