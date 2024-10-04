import 'package:algorhymns/data/sources/auth/auth_firebase_service.dart';
import 'package:algorhymns/domain/repository/auth/auth.dart';
import 'package:algorhymns/domain/usecases/auth/signup.dart';
import 'package:algorhymns/domain/usecases/auth/signin.dart';
import 'package:get_it/get_it.dart';

import 'data/repository/auth/auth_repository_impl.dart';

final sl = GetIt.instance;

Future<void> inititalizeDependencies() async{
  sl.registerSingleton<AuthFirebaseService>(
    AuthFirebaseServiceImpl()
  );
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl()
  );
   sl.registerSingleton<SignupUserCase>(
   SignupUserCase()
  );
  sl.registerSingleton<SigninUseCase>(
   SigninUseCase()
  );
}
