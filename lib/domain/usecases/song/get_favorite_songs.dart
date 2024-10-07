
import 'package:algorhymns/core/usecase/usecase.dart';
import 'package:algorhymns/domain/repository/song/song.dart';
import 'package:algorhymns/service_locator.dart';
import 'package:dartz/dartz.dart';

class GetFavoriteSongsUseCase implements UseCase<Either,dynamic> {

  @override
  Future<Either> call({params}) async{
    return await sl<SongsRepository>().getUserFavoriteSongs();
  }
}