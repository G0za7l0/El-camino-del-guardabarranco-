enum ExplorerType { male, female }

class UserModel {
  final String fullName;
  final String email;
  final ExplorerType explorerType;

  const UserModel({
    required this.fullName,
    required this.email,
    required this.explorerType,
  });

  UserModel copyWith({
    String? fullName,
    String? email,
    ExplorerType? explorerType,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      explorerType: explorerType ?? this.explorerType,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'explorerType': explorerType.name,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        explorerType: ExplorerType.values.firstWhere(
          (e) => e.name == json['explorerType'],
          orElse: () => ExplorerType.male,
        ),
      );
}
