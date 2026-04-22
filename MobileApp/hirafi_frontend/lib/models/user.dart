class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String role;
  final String? city;
  final String? country;
  final String? phone;
  final String status;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    required this.role,
    this.city,
    this.country,
    this.phone,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'] ?? json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      role: json['role'] ?? 'USER',
      city: json['city'],
      country: json['country'],
      phone: json['phone'],
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'city': city,
      'country': country,
      'phone': phone,
      'status': status,
    };
  }
}
