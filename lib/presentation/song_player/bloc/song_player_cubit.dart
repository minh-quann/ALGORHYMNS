import 'dart:async';

import 'package:algorhymns/presentation/song_player/bloc/song_player_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  AudioPlayer audioPlayer = AudioPlayer();
  Timer? syncLyricTimer;

  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;

  bool showLyrics = false;

  SongPlayerCubit() : super (SongPlayerLoading()) {
    audioPlayer.positionStream.listen((position) {
      songPosition = position;
      updateSongPlayer();
    });

    audioPlayer.durationStream.listen((duration) {
      if (songDuration == Duration.zero) {
        songDuration = duration!;
      }
    });
  }

  void updateSongPlayer() {
    emit(
        SongPlayerLoaded(songPosition)
    );
  }

  Future<void> loadSong(String url) async {
    try {
      await audioPlayer.setUrl(url);
      emit(
          SongPlayerLoaded(songPosition)
      );
    } catch (e) {
      emit(
          SongPlayerFailure()
      );
    }
  }

  void playOrPauseSong() {
    if (audioPlayer.playing) {
      audioPlayer.stop();
    } else {
      audioPlayer.play();
    }

    emit(
        SongPlayerLoaded(songPosition)
    );
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    syncLyricTimer?.cancel();
    return super.close();
  }

  void toggleLyrics() {
    showLyrics = !showLyrics;
    emit(
        SongPlayerLoaded(songPosition)
    );
  }

}