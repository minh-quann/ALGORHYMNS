import 'package:algorhymns/core/usecase/usecase.dart';
import 'package:algorhymns/data/models/auth/create_user_req.dart';
import 'package:algorhymns/domain/repository/auth/auth.dart';
import 'package:algorhymns/service_locator.dart';
import 'package:dartz/dartz.dart';
class SignupUserCase implements UseCase<Either, CreateUserReq>{
  @override
  Future<Either> call({CreateUserReq ? params}) {
    return sl<AuthRepository>().signup(params!);
  }

}