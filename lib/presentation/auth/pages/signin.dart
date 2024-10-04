import 'package:algorhymns/common/widgets/appbar/app_bar.dart';
import 'package:algorhymns/common/widgets/button/basic_app_button.dart';
import 'package:algorhymns/core/configs/assets/app_vectors.dart';
import 'package:algorhymns/data/models/auth/signin_user_req.dart';
import 'package:algorhymns/domain/usecases/auth/signin.dart';
import 'package:algorhymns/presentation/auth/pages/signup.dart';
import 'package:algorhymns/presentation/root/pages/root.dart';
import 'package:algorhymns/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SigninPage extends StatelessWidget{
   SigninPage({super.key});

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signupText(context),
      appBar: BasicAppbar(
         title: Row(
          children: [
            const SizedBox(width: 85), 
            SvgPicture.asset(
              AppVectors.logo,
              height: 100,
              width: 40,
            ),
            const SizedBox(width: 20), 
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: 50,
          horizontal: 30
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _registerText(),
            const SizedBox(height: 50),
            _emailField(context),
            const SizedBox(height: 20),
            _passwordField(context),
            const SizedBox(height: 20),
            BasicAppButton(
              onPressed: () async {
                var result = await sl<SigninUseCase>().call(
                  params: SigninUserReq(
                    email: _email.text.toString(), 
                    password: _password.text.toString()
                    )
                );
                result.fold(
                  (l){
                    var snackbar = SnackBar(content: Text(l));
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  },
                  (r){
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (BuildContext context) => const RootPage()),
                      (route) => false
                    );
                  }
                );
              }, 
              title: 'Đăng Nhập'
              )
          ],
        ),
      ),
    );
  }
  Widget _registerText(){
    return const Text(
      'Đăng Nhập',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25
      ),
      textAlign: TextAlign.center,
    );
  }
   Widget _emailField(BuildContext context){
    return TextField(
      controller: _email ,
      decoration: const InputDecoration(
        hintText: 'Email'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }
   Widget _passwordField(BuildContext context){
    return TextField(
      controller: _password,
      decoration: const InputDecoration(
        hintText: 'PassWord'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }
  Widget _signupText(BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 30
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Chưa có tài khoản?',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              fontSize: 14),
            ),
            TextButton(
              onPressed: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => SignupPage(),
                  ),
                );
              },
               child: const Text(
                'Đăng Ký Ngay'
               )
          )
        ],
      ),
    );
  }
}