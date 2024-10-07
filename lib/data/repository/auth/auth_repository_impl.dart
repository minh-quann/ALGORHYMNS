import 'package:algorhymns/data/models/auth/create_user_req.dart';
import 'package:algorhymns/data/models/auth/reset_password_req.dart';
import 'package:algorhymns/data/models/auth/signin_user_req.dart';
import 'package:algorhymns/data/sources/auth/auth_firebase_service.dart';
import 'package:algorhymns/domain/repository/auth/auth.dart';
import 'package:algorhymns/service_locator.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl extends AuthRepository{
  @override
  Future<Either> signin(SigninUserReq signinUserReq) async{
    return await sl<AuthFirebaseService>().signin(signinUserReq);
  }
  @override
  Future<Either> signup(CreateUserReq createUserReq) async{
    return await sl<AuthFirebaseService>().signup(createUserReq);
  }
 @override
Future<Either<String, void>> resetPassword(ResetPasswordReq req) async {
  return await sl<AuthFirebaseService>().resetPassword(req);
}
 @override
  Future<Either> getUser() async {
    return await sl<AuthFirebaseService>().getUser();
  }
}