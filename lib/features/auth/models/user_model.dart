import 'dart:convert';

/// User model for authentication
class UserModel {
  /// Unique identifier for the user
  final String id;
  
  /// User's email address
  final String email;
  
  /// User's full name
  final String name;
  
  /// User's profile image URL
  final String? photoUrl;
  
  /// User's bio or description
  final String? bio;
  
  /// User's password (only used for authentication, not displayed in UI)
  final String? password;

  /// Creates a user model
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.bio,
    this.password,
  });
  
  /// Create a copy of this user with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? bio,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      password: password ?? this.password,
    );
  }
  
  /// Convert this user to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'bio': bio,
      'password': password,
    };
  }
  
  /// Create a user from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      password: map['password'],
    );
  }
  
  /// Convert this user to a JSON string
  String toJson() => json.encode(toMap());
  
  /// Create a user from a JSON string
  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
  
  /// Empty user model
  static UserModel empty = UserModel(
    id: '',
    email: '',
    name: '',
    photoUrl: null,
    bio: null,
    password: null,
  );
  
  /// Check if this user is empty
  bool get isEmpty => id.isEmpty;
  
  /// Check if this user is not empty
  bool get isNotEmpty => !isEmpty;
  
  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, photoUrl: $photoUrl, bio: $bio)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.photoUrl == photoUrl &&
        other.bio == bio &&
        other.password == password;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode ^ name.hashCode ^ photoUrl.hashCode ^ bio.hashCode ^ password.hashCode;
  }
}
