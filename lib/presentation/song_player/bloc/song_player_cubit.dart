import 'dart:async';
import 'dart:io';

import 'package:algorhymns/presentation/song_player/bloc/song_player_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  AudioPlayer audioPlayer = AudioPlayer();
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  Timer? syncLyricTimer;
  Timer? recordingTimer;

  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;

  bool showLyrics = false;
  bool isRecording = false;
  int elapsedRecordingTime = 0;
  String? recordingFilePath;
  String _filePath = "";

  SongPlayerCubit() : super (SongPlayerLoading()) {
    audioPlayer.positionStream.listen((position) {
      songPosition = position;
      updateState();
    });

    audioPlayer.durationStream.listen((duration) {
      if (songDuration == Duration.zero) {
        songDuration = duration!;
      }
    });

    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await recorder.openRecorder();
    if (!await Permission.microphone.request().isGranted) {
      throw Exception("Microphone permission denied");
    }
  }

  void updateState() {
    emit(SongPlayerLoaded(
      songPosition: songPosition,
      isRecording: isRecording,
      elapsedRecordingTime: elapsedRecordingTime,
    ));
  }

  Future<void> loadSong(String url) async {
    try {
      await audioPlayer.setUrl(url);
      updateState();
    } catch (e) {
      emit(SongPlayerFailure());
    }
  }

  void playOrPauseSongAndRecord() async {
    if (audioPlayer.playing) {
      await stopRecording();
      await audioPlayer.pause();
      emit(SongPlayerPaused(
        songPosition: audioPlayer.position,
        songDuration: audioPlayer.duration!,
      ));
    } else {
      await audioPlayer.play();
      await startRecording();
      emit(SongPlayerPlaying(
          songPosition: audioPlayer.position,
          songDuration: audioPlayer.duration!));
    }
  }

  Future<void> startRecording() async {
    if (!isRecording) {
      _filePath = await _getRecordingFilePath();
      await recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.pcm16WAV,
      );
      isRecording = true;
      emit(RecordingStarted());
    }
  }

  Future<void> stopRecording() async {
    if (isRecording) {
      await recorder.stopRecorder();
      isRecording = false;
      emit(RecordingStopped());
    }
  }

  Future<String> _getRecordingFilePath() async {
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/record';
    final dir = Directory(path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return '$path/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
  }

  @override
  Future<void> close() {
    recorder.closeRecorder();
    audioPlayer.dispose();
    syncLyricTimer?.cancel();
    recordingTimer?.cancel();
    return super.close();
  }

  void toggleLyrics() {
    showLyrics = !showLyrics;
    updateState();
  }

}