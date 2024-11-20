import 'dart:convert';

import 'package:algorhymns/presentation/song_player/bloc/lyrics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class SongLyricsCubit extends Cubit<SongLyricsState> {
  List<Map<String, dynamic>> lyricsText = [];
  int highlightedIndex = -1;

  SongLyricsCubit() : super(SongLyricsLoading());


  Future<void> loadLyrics(String url) async {
    try {
      emit(
          SongLyricsLoading()
      );

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        lyricsText = (data['lyrics'] as List)
            .map((lyric) => {
          "timestamp": lyric['timestamp'] as String,
          "line": lyric['line'] as String
        }).toList();

        emit(SongLyricsLoaded(lyricsText, highlightedIndex));
      } else {
        emit(
            SongLyricsFailure("Failed to load lyrics with status: ${response.statusCode}")
        );
      }
    } catch (e) {
      emit(
          SongLyricsFailure("Error loading lyrics: $e")
      );
    }
  }

}