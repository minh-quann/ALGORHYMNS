import 'package:algorhymns/common/widgets/appbar/app_bar.dart';
import 'package:algorhymns/common/widgets/button/basic_app_button.dart';
import 'package:algorhymns/core/configs/assets/app_vectors.dart';
import 'package:algorhymns/data/models/auth/create_user_req.dart';
import 'package:algorhymns/domain/usecases/auth/signup.dart';
import 'package:algorhymns/presentation/auth/pages/signin.dart';
import 'package:algorhymns/presentation/root/pages/root.dart';
import 'package:algorhymns/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignupPage extends StatelessWidget{
  SignupPage({super.key});

  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signinText(context),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 50,
          horizontal: 30
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _registerText(),
            const SizedBox(height: 50),
            _fullNameField(context),
            const SizedBox(height: 20),
            _emailField(context),
            const SizedBox(height: 20),
            _passwordField(context),
            const SizedBox(height: 20),
            BasicAppButton(
              onPressed: () async {
                var result = await sl<SignupUserCase>().call(
                  params: CreateUserReq(
                    fullName: _fullName.text.toString(), 
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
              title: 'Tạo tài khoản'
              )
          ],
        ),
      ),
    );
  }
  Widget _registerText(){
    return const Text(
      'Đăng Ký',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _fullNameField(BuildContext context){
    return TextField(
      controller: _fullName,
      decoration: const InputDecoration(
        hintText: 'Full Name'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }
   Widget _emailField(BuildContext context){
    return TextField(
      controller: _email,
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
        hintText: 'Password'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }
  Widget _signinText(BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 30
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Đã có tài khoản?',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              fontSize: 14),
            ),
            TextButton(
              onPressed: (){Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => SigninPage(),
                      ),
                    );
                  },
               child: const Text(
                'Đăng nhập'
               )
          )
        ],
      ),
    );
  }
}