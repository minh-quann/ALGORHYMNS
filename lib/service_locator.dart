
import 'package:algorhymns/data/repository/auth/auth_repository_impl.dart';
import 'package:algorhymns/data/repository/song/song_repository_impl.dart';
import 'package:algorhymns/data/sources/auth/auth_firebase_service.dart';
import 'package:algorhymns/data/sources/song/song_firebase_service.dart';
import 'package:algorhymns/domain/repository/auth/auth.dart';
import 'package:algorhymns/domain/repository/song/song.dart';
import 'package:algorhymns/domain/usecases/auth/get_user.dart';
import 'package:algorhymns/domain/usecases/auth/signin.dart';
import 'package:algorhymns/domain/usecases/auth/signup.dart';
import 'package:algorhymns/domain/usecases/song/add_or_remove_favorite_song.dart';
import 'package:algorhymns/domain/usecases/song/get_favorite_songs.dart';
import 'package:algorhymns/domain/usecases/song/get_news_songs.dart';
import 'package:algorhymns/domain/usecases/song/get_play_list.dart';
import 'package:algorhymns/domain/usecases/song/is_favorite_song.dart';
import 'package:get_it/get_it.dart';
final sl = GetIt.instance;

Future<void> initializeDependencies() async {
 
 
 sl.registerSingleton<AuthFirebaseService>(
  AuthFirebaseServiceImpl()
 );

 sl.registerSingleton<SongFirebaseService>(
  SongFirebaseServiceImpl()
 );
 

 sl.registerSingleton<AuthRepository>(
  AuthRepositoryImpl()
 );

 sl.registerSingleton<SongsRepository>(
  SongRepositoryImpl()
 );



 sl.registerSingleton<SignupUseCase>(
  SignupUseCase()
 );

 sl.registerSingleton<SigninUseCase>(
  SigninUseCase()
 );

 sl.registerSingleton<GetNewsSongsUseCase>(
  GetNewsSongsUseCase()
 );

 sl.registerSingleton<GetPlayListUseCase>(
  GetPlayListUseCase()
 );

 sl.registerSingleton<AddOrRemoveFavoriteSongUseCase>(
  AddOrRemoveFavoriteSongUseCase()
 );

 sl.registerSingleton<IsFavoriteSongUseCase>(
  IsFavoriteSongUseCase()
 );

 sl.registerSingleton<GetUserUseCase>(
  GetUserUseCase()
 );

 sl.registerSingleton<GetFavoriteSongsUseCase>(
  GetFavoriteSongsUseCase()
 );
}