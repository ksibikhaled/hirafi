class WorkRequest {
  final int id;
  final int userId;
  final String userFirstName;
  final String userLastName;
  final int workerId;
  final String workerFirstName;
  final String workerLastName;
  final String workerProfession;
  final String description;
  final String? preferredDate;
  final String? location;
  final String status;
  final DateTime createdAt;

  WorkRequest({
    required this.id,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    required this.workerId,
    required this.workerFirstName,
    required this.workerLastName,
    required this.workerProfession,
    required this.description,
    this.preferredDate,
    this.location,
    required this.status,
    required this.createdAt,
  });

  factory WorkRequest.fromJson(Map<String, dynamic> json) {
    return WorkRequest(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      userFirstName: json['userFirstName'] ?? '',
      userLastName: json['userLastName'] ?? '',
      workerId: json['workerId'] ?? 0,
      workerFirstName: json['workerFirstName'] ?? '',
      workerLastName: json['workerLastName'] ?? '',
      workerProfession: json['workerProfession'] ?? '',
      description: json['description'] ?? '',
      preferredDate: json['preferredDate'],
      location: json['location'],
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
