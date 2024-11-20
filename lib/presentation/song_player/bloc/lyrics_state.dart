abstract class SongLyricsState {}

class SongLyricsLoading extends SongLyricsState {}

class SongLyricsLoaded extends SongLyricsState {
  List<Map<String, dynamic>> lyricsText;
  final int highlightedIndex;

  SongLyricsLoaded(this.lyricsText, this.highlightedIndex);
}

class SongLyricsFailure extends SongLyricsState {
  final String errorMessage;

  SongLyricsFailure(this.errorMessage);
}