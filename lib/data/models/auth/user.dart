import 'package:algorhymns/domain/entities/auth/user.dart';

class UserModel {
  String? fullName;
  String? email;
  String? imageURL;

  UserModel({
    this.fullName,
    this.email,
    this.imageURL,
  });

  UserModel.fromJson(Map<String, dynamic> data) {
    fullName = data['name'] as String?;
    email = data['email'] as String?;
    imageURL = data['imageURL'] as String?;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': fullName,
      'email': email,
      'imageURL': imageURL,
    };
  }
}
extension UserModelX on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      email: email ?? '',
      fullName: fullName ?? '',
      imageURL: imageURL ?? 'default_image_url', 
    );
  }
}
