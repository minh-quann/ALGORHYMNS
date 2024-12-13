import 'package:algorhymns/domain/usecases/song/get_play_list.dart';
import 'package:algorhymns/presentation/home/bloc/play_list_state.dart';
import 'package:algorhymns/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayListCubit extends Cubit<PlayListState> {
  PlayListCubit() : super(PlayListLoading());

  Future<void> getPlayList() async {
    var returnedSongs = await sl<GetPlayListUseCase>().call();
    returnedSongs.fold((l) {
      emit(PlayListLoadFailure());
    }, (data) {
      emit(PlayListLoaded(songs: data));
    });
  }
}