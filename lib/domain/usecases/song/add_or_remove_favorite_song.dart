import 'package:algorhymns/core/usecase/usecase.dart';
import 'package:algorhymns/domain/repository/song/song.dart';
import 'package:algorhymns/service_locator.dart';
import 'package:dartz/dartz.dart';


class AddOrRemoveFavoriteSongUseCase implements UseCase<Either,String> {
  @override
  Future<Either> call({String ? params}) async {
    return await sl<SongsRepository>().addOrRemoveFavoriteSongs(params!);
  }
  
}