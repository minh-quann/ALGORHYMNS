import 'package:algorhymns/core/usecase/usecase.dart';
import 'package:algorhymns/data/models/auth/signin_user_req.dart';
import 'package:algorhymns/domain/repository/auth/auth.dart';
import 'package:algorhymns/service_locator.dart';
import 'package:dartz/dartz.dart';
import 'package:algorhymns/data/models/auth/user.dart';

class SigninUseCase implements UseCase<Either, SigninUserReq> {
  @override
  Future<Either> call({SigninUserReq? params}) async {
    return sl<AuthRepository>().signin(params!);
  }

  Future<Either<String, UserModel>> signInWithGoogle() async {
    return sl<AuthRepository>().signInWithGoogle();
  }
}
