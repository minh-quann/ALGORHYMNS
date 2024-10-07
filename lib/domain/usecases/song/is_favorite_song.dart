import 'package:algorhymns/core/usecase/usecase.dart';
import 'package:algorhymns/domain/repository/song/song.dart';
import 'package:algorhymns/service_locator.dart';


class IsFavoriteSongUseCase implements UseCase<bool,String> {
  @override
  Future<bool> call({String ? params}) async {
    return await sl<SongsRepository>().isFavoriteSong(params!);
  }

  
}