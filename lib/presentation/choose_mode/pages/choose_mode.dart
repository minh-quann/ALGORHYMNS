import 'dart:ui';
import 'package:algorhymns/common/widgets/button/basic_app_button.dart';
import 'package:algorhymns/core/configs/assets/app_image.dart';
import 'package:algorhymns/core/configs/assets/app_vectors.dart';
import 'package:algorhymns/core/configs/theme/app_colors.dart';
import 'package:algorhymns/presentation/auth/pages/signup_or_signin.dart';
import 'package:algorhymns/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
class ChooseModePage extends StatelessWidget {
  const ChooseModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 40
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(
                  AppImage.chooseModeBG,
                )
              )
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.15),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 40
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(AppVectors.logo),
                ),
                const Spacer(),
                const Text(
                  'Chọn giao diện',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18
                  ),
                ),
                const SizedBox(height: 40),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.read<ThemeCubit>().updateTheme(ThemeMode.dark);
                              },
                              child: ClipOval(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: themeMode == ThemeMode.dark 
                                          ? const Color(0xff30393C).withOpacity(0.8) // màu nổi bật khi được chọn
                                          : const Color(0xff30393C).withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      AppVectors.moon,
                                      fit: BoxFit.none,
                                      color: themeMode == ThemeMode.dark ? Colors.yellow : Colors.grey, // Đổi màu biểu tượng
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: themeMode == ThemeMode.dark 
                                    ? Colors.white 
                                    : AppColors.grey,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(width: 40),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.read<ThemeCubit>().updateTheme(ThemeMode.light);
                              },
                              child: ClipOval(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: themeMode == ThemeMode.light 
                                          ? const Color(0xfffdd835).withOpacity(0.8) 
                                          : const Color(0xff30393C).withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      AppVectors.sun,
                                      fit: BoxFit.none,
                                      color: themeMode == ThemeMode.light ? Colors.orange : Colors.grey, // Đổi màu biểu tượng
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Light Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: themeMode == ThemeMode.light 
                                    ? Colors.white 
                                    : AppColors.grey,
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 50),
                BasicAppButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const SignupOrSigninPage(),
                      ),
                    );
                  },
                  title: 'Tiếp Tục',
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
