import 'package:algorhymns/common/helpers/is_dark_mode.dart';
import 'package:algorhymns/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';
class BasicAppbarProfile extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Color? backgroundColor;
  final bool hideBack;
  final List<Widget>? actions; 

  const BasicAppbarProfile({
    this.title,
    this.hideBack = false,
    this.actions,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.isDarkMode ? AppColors.darkGrey : AppColors.grey,
      centerTitle: true,
      title: title ?? const Text(''),
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: actions ?? [], // Thay đổi ở đây
      leading: hideBack ? null : IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: context.isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.04),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 15,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
