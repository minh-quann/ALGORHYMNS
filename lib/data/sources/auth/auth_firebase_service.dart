import 'package:algorhymns/data/models/auth/create_user_req.dart';
import 'package:algorhymns/data/models/auth/signin_user_req.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';


abstract class AuthFirebaseService {
  Future<Either> signup(CreateUserReq createUserReq);
  Future<Either> signin(SigninUserReq signinUserReq);
}

class AuthFirebaseServiceImpl extends AuthFirebaseService{
  @override
  Future<Either> signin(SigninUserReq signinUserReq) async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: signinUserReq.email, 
        password: signinUserReq.password
        );
        return const Right('Đăng nhập hoàn tất');

     } on FirebaseAuthException catch(e){
      String message = '';
      if(e.code == 'invalid-email'){
        message = 'Không có người dùng cho email này';
      }else if (e.code == 'invalid-credential'){
        message = 'Mật khẩu không đúng';
      }

      return Left(message);
     }
  }

  @override
  Future<Either> signup(CreateUserReq createUserReq) async {
     try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email, 
        password: createUserReq.password
        );
        return const Right('Đăng ký hoàn tất');

     } on FirebaseAuthException catch(e){
      String message = '';
      if(e.code == 'weak-password'){
        message = 'Mật khẩu quá yếu, xin hãy đặt một mật khẩu mạnh hơn!';
      }else if (e.code == 'email-already-in-use'){
        message = 'Email này đã được đăng ký trước đó';
      }

      return Left(message);
     }
  }
}
