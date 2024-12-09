import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
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
      print(audioPlayer.playerState.processingState);
      updateState();
    } catch (e) {
      emit(SongPlayerFailure());
    }
  }

  void playOrPauseSongAndRecord() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
      if (isRecording) {
        await pauseRecording();
      }
    } else {
      if (audioPlayer.processingState == ProcessingState.ready) {
        await startRecording();
      }
      await audioPlayer.play();

      if (!recorder.isRecording) {
        if (recorder.isPaused) {
          await resumeRecording();
        }
      }
    }

    emit(SongPlayerLoaded(
        songPosition: songPosition,
        isRecording: isRecording,
        elapsedRecordingTime: elapsedRecordingTime,
        showCancelSaveButtons: !audioPlayer.playing,
    ));
  }



  Future<void> startRecording() async {
    if (!isRecording) {
      _filePath = await _getRecordingFilePath();
      await recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.pcm16WAV,
      );
      isRecording = true;
      updateState();
    }
  }

  Future<void> stopRecording() async {
    if (recorder.isRecording) {
      try {
        final filePath = await recorder.stopRecorder();
        print("Recorder stopped. File path: $filePath");
        if (filePath != null) {
          _filePath = _filePath;
        }
      } catch (e) {
        print("Error stopping recorder: $e");
      }
      isRecording = false;
    }
  }

  Future<void> pauseRecording() async {
    if (recorder.isRecording) {
      await recorder.pauseRecorder();
      isRecording = false;
      // emit(SongPlayerLoaded(
      //     songPosition: songPosition,
      //     isRecording: false,
      //     elapsedRecordingTime: elapsedRecordingTime,
      //     showCancelSaveButtons: true,
      // ));
    }
  }

  Future<void> resumeRecording() async {
    if (recorder.isPaused) {
      await recorder.resumeRecorder();
      isRecording = true;
    }
  }

  void saveRecording() async {
    if (isRecording) {
      await stopRecording();
    }
    // await Future.delayed(Duration(seconds: 1));

    final file = File(_filePath);
    if (await file.exists()) {
      print("File successfully saved at $_filePath");
    } else {
      print("File does not exist at $_filePath. Save failed.");
    }

    // if (_filePath.isNotEmpty) {
    //   await _uploadRecordingToServer(_filePath);
    // }

    emit(SongPlayerLoaded(
        songPosition: songPosition,
        isRecording: false,
        elapsedRecordingTime: elapsedRecordingTime,
        showCancelSaveButtons: false,
    ));
  }

  void cancelRecording() async {
    if (recorder.isRecording) {
      await stopRecording();
    }

    if (_filePath.isNotEmpty) {
      final file = File(_filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    emit(SongPlayerLoaded(
        songPosition: songPosition,
        isRecording: false,
        elapsedRecordingTime: elapsedRecordingTime,
        showCancelSaveButtons: false,
    ));
  }

  Future<void> _uploadRecordingToServer(String filePath) async {
    // trên thiết bị android emulator
    final uri = Uri.parse("http://10.0.2.2:5000/analyze_audio");
    // trên thiết bị thật
    // final uri = Uri.parse("http://192.168.1.12:5000/analyze_audio");
    final file = File(filePath);

    if (file.existsSync()) {
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();
      if (response.statusCode == 200) {
        print("File uploaded successfully!");
      } else {
        print("Failed to upload file.");
      }
    } else {
      print("Recording file not found.");
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