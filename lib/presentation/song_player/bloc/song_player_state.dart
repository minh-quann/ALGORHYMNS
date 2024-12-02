abstract class SongPlayerState {}

class SongPlayerInitial extends SongPlayerState {}

class SongPlayerLoading extends SongPlayerState {}

class SongPlayerLoaded extends SongPlayerState {
  final Duration songPosition;
  final bool isRecording;
  final int elapsedRecordingTime;

  SongPlayerLoaded({
    required this.songPosition,
    required this.isRecording,
    required this.elapsedRecordingTime,
  });
}

class SongPlayerPlaying extends SongPlayerState {
  final Duration songPosition;
  final Duration songDuration;

  SongPlayerPlaying({
    required this.songPosition,
    required this.songDuration,
  });
}

class SongPlayerPaused extends SongPlayerState {
  final Duration songPosition;
  final Duration songDuration;

  SongPlayerPaused({
    required this.songPosition,
    required this.songDuration,
  });
}

class RecordingStarted extends SongPlayerState {}

class RecordingStopped extends SongPlayerState {}

class SongPlayerFailure extends SongPlayerState {}