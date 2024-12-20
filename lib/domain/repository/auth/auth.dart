import 'package:algorhymns/data/models/auth/create_user_req.dart';
import 'package:algorhymns/data/models/auth/reset_password_req.dart';
import 'package:algorhymns/data/models/auth/signin_user_req.dart';
import 'package:algorhymns/data/models/auth/user.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository{
  Future<Either> signup(CreateUserReq createUserReq);
  Future<Either> signin(SigninUserReq signinUserReq);
  Future<Either<String, void>> resetPassword(ResetPasswordReq req);
  Future<Either> getUser();
  Future<Either<String, UserModel>> signInWithGoogle();
}