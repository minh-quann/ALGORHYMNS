abstract class SongPlayerState {}

class SongPlayerLoading extends SongPlayerState {}

class SongPlayerLoaded extends SongPlayerState {
  final Duration songPosition;

  SongPlayerLoaded(this.songPosition);
}

class SongPlayerFailure extends SongPlayerState {}