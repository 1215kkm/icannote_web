class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String subscriptionPlan; // 'free', 'pro', 'enterprise'
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoUrl,
    this.subscriptionPlan = 'free',
    required this.createdAt,
  });

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? subscriptionPlan,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'subscriptionPlan': subscriptionPlan,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String? ?? '',
        photoUrl: json['photoUrl'] as String?,
        subscriptionPlan: json['subscriptionPlan'] as String? ?? 'free',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
