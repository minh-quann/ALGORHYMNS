import 'dart:ui';
import 'package:algorhymns/common/widgets/button/basic_app_button.dart';
import 'package:algorhymns/core/configs/assets/app_image.dart';
import 'package:algorhymns/core/configs/assets/app_vectors.dart';
import 'package:algorhymns/core/configs/theme/app_colors.dart';
import 'package:algorhymns/presentation/auth/pages/signup_or_signin.dart';
import 'package:algorhymns/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              horizontal: 40,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(AppImages.chooseModeBG),
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.15),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 40,
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
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 40),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildThemeOption(
                          context,
                          mode: ThemeMode.dark,
                          icon: AppVectors.moon,
                          activeColor: const Color(0xff30393C),
                          text: 'Dark',
                          themeMode: themeMode,
                        ),
                        _buildThemeOption(
                          context,
                          mode: ThemeMode.light,
                          icon: AppVectors.sun,
                          activeColor: const Color(0xfffdd835),
                          text: 'Light',
                          themeMode: themeMode,
                        ),
                        _buildThemeOption(
                          context,
                          mode: ThemeMode.system,
                          icon: AppVectors.system, 
                          activeColor: const Color(0xff30393C),
                          text: 'System',
                          themeMode: themeMode,
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
                        builder: (BuildContext context) =>
                            const SignupOrSigninPage(),
                      ),
                    );
                  },
                  title: 'Tiếp Tục',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required ThemeMode mode,
    required String icon,
    required Color activeColor,
    required String text,
    required ThemeMode themeMode,
  }) {
    final isActive = themeMode == mode;
    return Column(
      children: [
        GestureDetector(
          onTap: () => context.read<ThemeCubit>().updateTheme(mode),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor.withOpacity(0.8)
                      : const Color(0xff30393C).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  icon,
                  fit: BoxFit.none,
                  color: isActive ? Colors.orange : Colors.grey,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 17,
            color: isActive ? Colors.white : AppColors.grey,
          ),
        ),
      ],
    );
  }
}
