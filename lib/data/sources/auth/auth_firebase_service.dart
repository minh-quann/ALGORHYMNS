import 'package:algorhymns/core/configs/constants/app_urls.dart';
import 'package:algorhymns/data/models/auth/create_user_req.dart';
import 'package:algorhymns/data/models/auth/reset_password_req.dart';
import 'package:algorhymns/data/models/auth/signin_user_req.dart';
import 'package:algorhymns/data/models/auth/user.dart';
import 'package:algorhymns/domain/entities/auth/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';


abstract class AuthFirebaseService {
  Future<Either> signup(CreateUserReq createUserReq);
  Future<Either> signin(SigninUserReq signinUserReq);
  Future<Either<String, void>> resetPassword(ResetPasswordReq req);
  Future<Either> getUser();
}

class AuthFirebaseServiceImpl extends AuthFirebaseService{
   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
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
      var data = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email, 
        password: createUserReq.password
        );
         FirebaseFirestore.instance.collection('Users').doc(data.user?.uid)
         .set(
          {
            'name' : createUserReq.fullName,
            'email' : data.user?.email
          }
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
   @override
  Future<Either<String, void>> resetPassword(ResetPasswordReq req) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: req.email);
      return const Right(null); 
    } catch (e) {
      return Left('Có lỗi xảy ra: ${e.toString()}'); 
    }
  }
 @override
  Future < Either > getUser() async {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      var user = await firebaseFirestore.collection('Users').doc(
        firebaseAuth.currentUser?.uid
      ).get();

      UserModel userModel = UserModel.fromJson(user.data() !);
      userModel.imageURL = firebaseAuth.currentUser?.photoURL ?? AppURLs.defaultImage;
      UserEntity userEntity = userModel.toEntity();
      return Right(userEntity);
    } catch (e) {
      return const Left('An error occurred');
    }
  }

}
