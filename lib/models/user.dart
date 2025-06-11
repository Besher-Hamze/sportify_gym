class User {
  final String id;
  final String name;
  final String email;
  final DateTime joinDate;
  final String? profileImageUrl;
  final List<String>? roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.joinDate,
    this.profileImageUrl,
    this.roles,
  });

  // Convert Firestore document to User object
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      joinDate: (data['joinDate'] is DateTime)
          ? data['joinDate']
          : DateTime.now(), // Fallback to current date
      profileImageUrl: data['profileImageUrl'],
      roles: data['roles'] != null
          ? List<String>.from(data['roles'])
          : null,
    );
  }

  // Convert User object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'joinDate': joinDate,
      'profileImageUrl': profileImageUrl,
      'roles': roles,
    };
  }
}

