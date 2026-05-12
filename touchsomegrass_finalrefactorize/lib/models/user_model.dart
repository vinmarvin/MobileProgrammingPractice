  //Model untuk user yang nantinya akan dihubungkan dengan Firestore
class UserModel {
  final String uid;
  final String name;
  final String role;
  final int points;
  final int totalFocusMinutes;
  final String avatarEmoji;

  UserModel({
    required this.uid,
    required this.name,
    required this.role,
    required this.points,
    required this.totalFocusMinutes,
    this.avatarEmoji = '🌿', // default emoji
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      role: map['role'] ?? 'Member',
      points: (map['points'] ?? 0) as int,
      totalFocusMinutes: (map['totalFocusMinutes'] ?? 0) as int,
      avatarEmoji: (map['avatar_emoji'] as String?) ?? '🌿',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'points': points,
      'totalFocusMinutes': totalFocusMinutes,
      'avatar_emoji': avatarEmoji,
    };
  }

  UserModel copyWith({
    String? name,
    String? role,
    int? points,
    int? totalFocusMinutes,
    String? avatarEmoji,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      role: role ?? this.role,
      points: points ?? this.points,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
    );
  }
}
