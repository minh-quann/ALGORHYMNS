import 'dart:async';
import 'dart:io';
import 'package:algorhymns/presentation/song_player/bloc/get_result.dart';
import 'package:http/http.dart' as http;
import 'package:algorhymns/presentation/song_player/bloc/song_player_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart'; // Thêm để sử dụng Navigator

class SongPlayerCubit extends Cubit<SongPlayerState> {
  AudioPlayer audioPlayer = AudioPlayer();
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  Timer? syncLyricTimer;
  
  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;

  bool showLyrics = false;
  bool isRecording = false;
  int elapsedRecordingTime = 0;
  String? recordingFilePath;
  String _filePath = "";

  SongPlayerCubit() : super(SongPlayerLoading()) {
    audioPlayer.positionStream.listen((position) {
      songPosition = position;
      updateState();
    });

    audioPlayer.durationStream.listen((duration) {
      if (songDuration == Duration.zero) {
        songDuration = duration ?? Duration.zero;
      }
    });

    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await recorder.openRecorder();
    if (!await Permission.microphone.request().isGranted) {
      throw Exception("Microphone permission denied");
    }
    recorder.setSubscriptionDuration(const Duration(milliseconds: 100)); // Ensure frequent updates
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
      await audioPlayer.pause();
      if (isRecording) {
        await stopRecording();
      }
    } else {
      if (audioPlayer.processingState == ProcessingState.ready) {
        await startRecording();
      }
      await audioPlayer.play();
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
      try {
        // Start recording and ensure it doesn't stop
        await recorder.startRecorder(
          toFile: _filePath,
          codec: Codec.pcm16WAV,
        );
        isRecording = true;
        elapsedRecordingTime = 0;
        updateState();  // Ensure state is updated immediately after starting recording
      } catch (e) {
        print("Error starting recorder: $e");
      }
    }
  }

  Future<void> stopRecording() async {
    if (recorder.isRecording) {
      try {
        final filePath = await recorder.stopRecorder();
        print("Recorder stopped. File path: $filePath");
        if (filePath != null) {
          _filePath = filePath;
        }
      } catch (e) {
        print("Error stopping recorder: $e");
      }
      isRecording = false;
      updateState();
    }
  }

  Future<void> pauseRecording() async {
    if (recorder.isRecording) {
      await recorder.pauseRecorder();
      isRecording = false;
      updateState();
    }
  }

  Future<void> resumeRecording() async {
    if (recorder.isPaused) {
      await recorder.resumeRecorder();
      isRecording = true;
      updateState();
    }
  }

  void saveRecording({required String artist, required String title}) async {
    if (isRecording) {
      await stopRecording();
    }

    final file = File(_filePath);
    if (await file.exists()) {
      print("File successfully saved at $_filePath");

      // Send the file immediately after saving
      await _uploadRecordingToServer(_filePath, artist, title); // Upload file to server
    } else {
      print("File does not exist at $_filePath. Save failed.");
    }

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

  Future<void> _uploadRecordingToServer(String filePath, String artist, String title) async {
    final uri = Uri.parse("http://10.0.2.2:5000/analyze_audio");
    final file = File(filePath);

    if (file.existsSync()) {
      try {
        final request = http.MultipartRequest('POST', uri)
          ..fields['artist'] = artist
          ..fields['title'] = title
          ..files.add(await http.MultipartFile.fromPath('file', filePath));

        final response = await request.send();
        if (response.statusCode == 200) {
          print("File uploaded successfully!");
          // Handle the server's response if necessary
        } else {
          print("Failed to upload file with status code: ${response.statusCode}");
        }
      } catch (e) {
        print("Error while uploading file: $e");
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
    return super.close();
  }

  void toggleLyrics() {
    showLyrics = !showLyrics;
    updateState();
  }

  // Thêm phương thức để mở trang kết quả
  void navigateToResultsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResultsPage()), 
    );
  }
}
