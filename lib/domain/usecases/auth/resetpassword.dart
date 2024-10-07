import 'package:algorhymns/core/usecase/usecase.dart';
import 'package:algorhymns/domain/repository/auth/auth.dart';
import 'package:algorhymns/service_locator.dart';
import 'package:dartz/dartz.dart';
import 'package:algorhymns/data/models/auth/reset_password_req.dart'; 

class ResetPasswordUseCase implements UseCase<Either<String, void>, ResetPasswordReq> {
  @override
  Future<Either<String, void>> call({ResetPasswordReq? params}) {
    return sl<AuthRepository>().resetPassword(params!);
  }
}
