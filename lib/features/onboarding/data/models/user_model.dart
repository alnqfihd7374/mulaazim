import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String firstName;

  @HiveField(1)
  final String secondName;

  @HiveField(2)
  final String? nickname;

  @HiveField(3)
  final bool isDarkMode;

  @HiveField(4)
  final String? surName;

  UserModel({
    required this.firstName,
    required this.secondName,
    this.nickname,
    this.isDarkMode = false,
    this.surName,
  });

  UserModel copyWith({
    String? firstName,
    String? secondName,
    String? nickname,
    bool? isDarkMode,
    String? surName,
  }) {
    return UserModel(
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      nickname: nickname ?? this.nickname,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      surName: surName ?? this.surName,
    );
  }

  String get displayName => (nickname != null && nickname!.isNotEmpty) ? nickname! : firstName;
}

