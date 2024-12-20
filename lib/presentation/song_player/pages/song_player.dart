import 'package:algorhymns/common/widgets/appbar/app_bar.dart';
import 'package:algorhymns/common/widgets/favorite_button/favorite_button.dart';
import 'package:algorhymns/core/configs/constants/app_urls.dart';
import 'package:algorhymns/core/configs/theme/app_colors.dart';
import 'package:algorhymns/domain/entities/song/song.dart';
import 'package:algorhymns/presentation/song_player/bloc/get_result.dart';
import 'package:algorhymns/presentation/song_player/bloc/lyrics_cubit.dart';
import 'package:algorhymns/presentation/song_player/bloc/lyrics_state.dart';
import 'package:algorhymns/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:algorhymns/presentation/song_player/bloc/song_player_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:algorhymns/common/helpers/is_dark_mode.dart';

class SongPlayerPage extends StatefulWidget {
  final SongEntity songEntity;

  const SongPlayerPage({
    required this.songEntity,
    super.key
  });

  @override
  // ignore: library_private_types_in_public_api
  _SongPlayerPageState createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  late final ScrollController _scrollController;
  int highlightedIndex = -1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateHighlightedLyric(Duration songPosition, List<dynamic> lyrics) {
    setState(() {
      highlightedIndex = _calculateHighlightIndex(songPosition, lyrics);
    });
  }

  int _calculateHighlightIndex(Duration songPosition, List<dynamic> lyrics) {
    for (int i = 0; i < lyrics.length; i++) {
      final lyricTimestamp = _parseTimestamp(lyrics[i]['timestamp']);
      if (songPosition.inSeconds < lyricTimestamp) {
        return i - 1 >= 0 ? i - 1 : 0;
      }
    }
    return lyrics.length - 1;
  }

  int _parseTimestamp(String timestamp) {
    final parts = timestamp.split(":");
    if (parts.length == 2) {
      try {
        final minutes = int.parse(parts[0]);
        final seconds = double.parse(parts[1]).floor();
        return minutes * 60 + seconds;
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: const Text(
          'Now playing',
          style: TextStyle(
              fontSize: 18
          ),
        ),
        action: IconButton(
            onPressed: (){},
            icon: const Icon(
                Icons.more_vert_rounded
            )
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SongPlayerCubit()
              ..loadSong(
                  '${AppURLs.songFirestorage}'
                      '${Uri.encodeComponent(widget.songEntity.artist)}%20-%20'
                      '${Uri.encodeComponent(widget.songEntity.title)}.mp3?${AppURLs.mediaAlt}'
              ),
          ),
          BlocProvider(
              create: (_) => SongLyricsCubit()
                ..loadLyrics(
                    '${AppURLs.lyricFirestorage}'
                        '${Uri.encodeComponent(widget.songEntity.title)}.json?${AppURLs.mediaAlt}'
                )
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16
          ),
          child: BlocConsumer<SongPlayerCubit, SongPlayerState> (
            listener: (context, state) {
              if (state is SongPlayerLoaded) {
                final lyricsState = context.read<SongLyricsCubit>().state;
                if (lyricsState is SongLyricsLoaded) {
                  _updateHighlightedLyric(state.songPosition, lyricsState.lyricsText);
                }
              }
            },
            builder: (context, state) {
              final songPlayerCubit = context.read<SongPlayerCubit>();
              return Column(
                children: [
                  songPlayerCubit.showLyrics ? _lyricsDisplay(context) : _songsCover(context),
                  const SizedBox(height: 20,),
                  _songDetail(),
                  const SizedBox(height: 30,),
                  _songPlayer(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _songsCover(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
              fit: BoxFit.cover,

              image: NetworkImage(
                '${AppURLs.coverFirestorage}'
                    '${Uri.encodeComponent(widget.songEntity.artist)}%20-%20'
                    '${Uri.encodeComponent(widget.songEntity.title)}.jpg?${AppURLs.mediaAlt}'
              )
          )
      ),
    );
  }
Widget _lyricsDisplay(BuildContext context) {
  return BlocBuilder<SongLyricsCubit, SongLyricsState>(
    builder: (context, state) {
      if (state is SongLyricsLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is SongLyricsLoaded) {
        final lyrics = state.lyricsText;
        int currentIndex = highlightedIndex;
        int startIndex = (currentIndex - 5 >= 0) ? currentIndex - 5 : 0;
        int endIndex = (currentIndex + 5 < lyrics.length) ? currentIndex + 5 : lyrics.length - 1;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToCenter();
        });

        return Container(
          height: MediaQuery.of(context).size.height / 2,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color.fromARGB(255, 73, 73, 73).withOpacity(0.5),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = startIndex; i < currentIndex; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0), 
                      child: Text(
                        lyrics[i]["line"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: i < currentIndex - 2 ? 14 : 17, 
                          color: i < currentIndex - 2 
                              ? const Color.fromARGB(106, 255, 255, 255) 
                              : const Color.fromARGB(255, 255, 255, 255),  
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                if (currentIndex < lyrics.length)
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      lyrics[currentIndex]["line"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                for (int i = currentIndex + 1; i <= endIndex; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0), 
                      child: Text(
                        lyrics[i]["line"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: i >= endIndex - 2 ? 14 : 17,  
                          color: i >= endIndex - 2
                              ? const Color.fromARGB(103, 255, 255, 255)  
                              : const Color.fromARGB(255, 255, 255, 255), 
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );
      } else if (state is SongLyricsFailure) {
        return const Text("Error loading lyrics");
      } else {
        return const SizedBox.shrink();
      }
    },
  );
}



void scrollToCenter() {
  if (_scrollController.hasClients) {
    const lineHeight = 40.0;
    final containerHeight = MediaQuery.of(context).size.height / 2;
    final scrollPosition = highlightedIndex * lineHeight - (containerHeight / 2) + (lineHeight / 2);

    _scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}


  Widget _songDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.songEntity.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22
              ),
            ),
            const SizedBox(height: 5, ),
              Text(
                widget.songEntity.artist,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14
                ),
              ),
          ],
        ),
          FavoriteButton(
            songEntity: widget.songEntity
          )
      ],
    );
  }

 Widget _songPlayer(BuildContext context) {
  return BlocBuilder<SongPlayerCubit, SongPlayerState>(
    builder: (context, state) {
      final cubit = context.read<SongPlayerCubit>();

      if (state is SongPlayerLoading) {
        return const CircularProgressIndicator();
      }

      if (state is SongPlayerLoaded ||
          state is SongPlayerPlaying ||
          state is SongPlayerPaused) {
        final isPaused =
            state is SongPlayerLoaded && state.showCancelSaveButtons;

        return Column(
          children: [
            Slider(
              value: cubit.songPosition.inSeconds.toDouble(),
              min: 0.0,
              max: cubit.songDuration.inSeconds.toDouble(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(
                      context.read<SongPlayerCubit>().songPosition),
                ),
                Text(
                  formatDuration(
                      context.read<SongPlayerCubit>().songDuration),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isPaused)
                        GestureDetector(
                          onTap: cubit.cancelRecording,
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (isPaused) const SizedBox(width: 20),
                      GestureDetector(
                        onTap: cubit.playOrPauseSongAndRecord,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: Icon(
                            cubit.audioPlayer.playing
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (isPaused) const SizedBox(width: 20),
                      if (isPaused)
                        GestureDetector(
                          onTap: () {
                            cubit.saveRecording(
                              artist: widget.songEntity.artist,
                              title: widget.songEntity.title,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ResultsPage(), 
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
          
                Positioned(
                  right: 20,
                  child: IconButton(
                    onPressed: () {
                      cubit.toggleLyrics();
                    },
                    icon: const Icon(Icons.lyrics),
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    iconSize: 30,
                  ),
                ),
              ],
            ),
          ],
        );
      }

      return Container();
    },
  );
}


  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2,'0')}:${seconds.toString().padLeft(2,'0')}';
  }
}