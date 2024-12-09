import 'package:algorhymns/common/helpers/is_dark_mode.dart';
import 'package:algorhymns/common/widgets/appbar/app_bar_profile.dart';
import 'package:algorhymns/common/widgets/favorite_button/favorite_button.dart';
import 'package:algorhymns/core/configs/constants/app_urls.dart';
import 'package:algorhymns/core/configs/theme/app_colors.dart';
import 'package:algorhymns/data/models/auth/shared_prefs.dart';
import 'package:algorhymns/presentation/auth/pages/signin.dart';
import 'package:algorhymns/presentation/profile/bloc/favorite_songs_cubit.dart';
import 'package:algorhymns/presentation/profile/bloc/favorite_songs_state.dart';
import 'package:algorhymns/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:algorhymns/presentation/profile/bloc/profile_info_state.dart';
import 'package:algorhymns/presentation/song_player/pages/song_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbarProfile(
        backgroundColor: const Color(0xff2C2B2B),
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           _profileInfo(context),
           const SizedBox(height: 30,),
           _favoriteSongs(),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Xác nhận đăng xuất'),
      content: const Text('Bạn có chắc muốn đăng xuất không?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); 
          },
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () async {
            bool isLoggedOut = await _logout(); 

            if (isLoggedOut) {
              Navigator.of(context).pop(); 
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SigninPage()), 
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đăng xuất thất bại.')),
              );
            }
          },
          child: const Text('Đăng xuất'),
        ),
      ],
    ),
  );
}
Future<bool> _logout() async {
  try {
    await SharedPrefs.clearUserData();
    await FirebaseAuth.instance.signOut();

    return true;
  } catch (e) {
    return false;
  }
}

  Widget _profileInfo(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileInfoCubit()..getUser(),
      child: Container(
        height: MediaQuery.of(context).size.height / 3.5,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.isDarkMode ? AppColors.darkGrey : AppColors.grey,
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(50),
            bottomLeft: Radius.circular(50),
          ),
        ),
        child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
          builder: (context, state) {
            if (state is ProfileInfoLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileInfoLoaded) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          state.userEntity.imageURL!,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    state.userEntity.email!,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.userEntity.fullName!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }
            if (state is ProfileInfoFailure) {
              return const Text('Please try again');
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _favoriteSongs() {
    return BlocProvider(
      create: (context) => FavoriteSongsCubit()..getFavoriteSongs(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FAVORITE SONGS'),
            const SizedBox(height: 20),
            BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
              builder: (context, state) {
                if (state is FavoriteSongsLoading) {
                  return const CircularProgressIndicator();
                }
                if (state is FavoriteSongsLoaded) {
                  return ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SongPlayerPage(songEntity: state.favoriteSongs[index]),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        '${AppURLs.coverFirestorage}${state.favoriteSongs[index].artist} - ${state.favoriteSongs[index].title}.jpg?${AppURLs.mediaAlt}',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.favoriteSongs[index].title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      state.favoriteSongs[index].artist,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  state.favoriteSongs[index].duration.toString().replaceAll('.', ':'),
                                ),
                                const SizedBox(width: 20),
                                FavoriteButton(
                                  songEntity: state.favoriteSongs[index],
                                  key: UniqueKey(),
                                  function: () {
                                    context.read<FavoriteSongsCubit>().removeSong(index);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemCount: state.favoriteSongs.length,
                  );
                }
                if (state is FavoriteSongsFailure) {
                  return const Text('Please try again.');
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}