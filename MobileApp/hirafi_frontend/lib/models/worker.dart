class Worker {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? profileImageUrl;
  final String profession;
  final String? phone;
  final String? website;
  final String? bio;
  final String? city;
  final String? country;
  final bool approved;
  final double ratingAvg;
  final int followersCount;
  final int postsCount;
  final int portfolioCount;
  final bool isFollowed;
  final bool verified;
  final bool featured;
  final int reviewsCount;

  Worker({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profileImageUrl,
    required this.profession,
    this.phone,
    this.website,
    this.bio,
    this.city,
    this.country,
    required this.approved,
    required this.ratingAvg,
    required this.followersCount,
    required this.postsCount,
    required this.portfolioCount,
    required this.isFollowed,
    this.verified = false,
    this.featured = false,
    this.reviewsCount = 0,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      profession: json['profession'] ?? '',
      phone: json['phone'],
      website: json['website'],
      bio: json['bio'],
      city: json['city'],
      country: json['country'],
      approved: json['approved'] ?? false,
      ratingAvg: (json['ratingAvg'] ?? 0.0).toDouble(),
      followersCount: json['followersCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      portfolioCount: json['portfolioCount'] ?? 0,
      isFollowed: json['isFollowed'] ?? false,
      verified: json['verified'] ?? false,
      featured: json['featured'] ?? false,
      reviewsCount: json['reviewsCount'] ?? 0,
    );
  }
}
