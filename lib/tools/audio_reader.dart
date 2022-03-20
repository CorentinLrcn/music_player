import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioReader extends StatefulWidget {
  final AudioPlayer audioReader;
  final SongModel song;
  final changeIndex;

  const AudioReader({
    Key? key,
    required this.audioReader,
    required this.song,
    required this.changeIndex,
  }) : super(key: key);

  @override
  _AudioReaderState createState() => _AudioReaderState();
}

class _AudioReaderState extends State<AudioReader> {
  Duration duration = const Duration();
  Duration position = const Duration();
  bool isPlaying = false;
  bool isLooping = false;
  bool isShuffling = false;
  double btnSize = 25;
  late int i;

  @override
  void initState() {
    super.initState();
    widget.audioReader.onDurationChanged.listen((d) {
      setState(() {
        duration = d;
      });
    });
    widget.audioReader.onAudioPositionChanged.listen((p) {
      setState(() {
        position = p;
      });
    });
    widget.audioReader.onPlayerCompletion.listen((event) async {
      if (isShuffling) {
        widget.changeIndex('random');
        await widget.audioReader.stop();
        await widget.audioReader.play(widget.song.data, isLocal: true);
        await widget.audioReader.stop();
        await widget.audioReader.play(widget.song.data, isLocal: true);
      } else {
        widget.changeIndex('next');
        await widget.audioReader.stop();
        await widget.audioReader.play(widget.song.data, isLocal: true);
        await widget.audioReader.stop();
        await widget.audioReader.play(widget.song.data, isLocal: true);
      }
    });
    //widget.audioReader.setUrl(widget.song.data, isLocal: true);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    //final double screenWidth = MediaQuery.of(context).size.width;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    IconButton playPauseBtn() {
      return IconButton(
        icon: isPlaying
            ? const Icon(Icons.pause_rounded)
            : const Icon(Icons.play_arrow_rounded),
        padding: const EdgeInsets.all(10),
        iconSize: 60,
        color: isDarkMode ? Colors.white : Colors.blueGrey,
        onPressed: () async {
          if (!isPlaying) {
            await widget.audioReader.play(widget.song.data, isLocal: true);
            setState(() {
              isPlaying = true;
            });
          } else if (isPlaying) {
            await widget.audioReader.pause();
            setState(() {
              isPlaying = false;
            });
          }
        },
      );
    }

    IconButton nextBtn() {
      return IconButton(
        onPressed: () async {
          if (!isShuffling) {
            widget.changeIndex('next');
            if (isPlaying) {
              await widget.audioReader.stop();
              await widget.audioReader.play(widget.song.data, isLocal: true);
              await widget.audioReader.stop();
              await widget.audioReader.play(widget.song.data, isLocal: true);
            }
          } else if (isShuffling) {
            widget.changeIndex('random');
            if (isPlaying) {
              await widget.audioReader.stop();
              await widget.audioReader.play(widget.song.data, isLocal: true);
              await widget.audioReader.stop();
              await widget.audioReader.play(widget.song.data, isLocal: true);
            }
          }
        },
        icon: const Icon(Icons.skip_next_rounded),
        padding: const EdgeInsets.all(10),
        iconSize: 35,
        color: isDarkMode ? Colors.white : Colors.blueGrey,
      );
    }

    IconButton previousBtn() {
      return IconButton(
        onPressed: () async {
          if (position.inSeconds > 3 || isShuffling) {
            await widget.audioReader.seek(const Duration(seconds: 0));
          } else {
            widget.changeIndex('previous');
            await widget.audioReader.stop();
            await widget.audioReader.play(widget.song.data, isLocal: true);
            await widget.audioReader.stop();
            await widget.audioReader.play(widget.song.data, isLocal: true);
          }
        },
        icon: const Icon(Icons.skip_previous_rounded),
        padding: const EdgeInsets.all(10),
        iconSize: 35,
        color: isDarkMode ? Colors.white : Colors.blueGrey,
      );
    }

    IconButton loopBtn() {
      return IconButton(
        onPressed: () {
          if (!isLooping) {
            widget.audioReader.setReleaseMode(ReleaseMode.LOOP);
            setState(() {
              isLooping = true;
              btnSize = 35;
            });
          } else if (isLooping) {
            widget.audioReader.setReleaseMode(ReleaseMode.RELEASE);
            setState(() {
              isLooping = false;
              btnSize = 25;
            });
          }
        },
        //icon: const Icon(Icons.repeat_rounded),
        icon: const Icon(
          Icons.repeat_rounded,
        ),
        padding: const EdgeInsets.all(10),
        iconSize: isLooping ? 30 : 25,
        color: isDarkMode
            ? isLooping
                ? Colors.teal
                : Colors.white
            : isLooping
                ? Colors.teal
                : Colors.blueGrey,
      );
    }

    IconButton randomBtn() {
      return IconButton(
        onPressed: () {
          if (!isShuffling) {
            setState(() {
              isShuffling = true;
              btnSize = 35;
            });
          } else if (isShuffling) {
            setState(() {
              isShuffling = false;
              btnSize = 25;
            });
          }
        },
        icon: const Icon(Icons.shuffle_rounded),
        padding: const EdgeInsets.all(10),
        iconSize: isShuffling ? 30 : 25,
        color: isDarkMode
            ? isShuffling
                ? Colors.teal
                : Colors.white
            : isShuffling
                ? Colors.teal
                : Colors.blueGrey,
      );
    }

    return Center(
        child: Column(
      children: [
        SizedBox(height: screenHeight * 0.05),
        Column(
          children: [
            // Affichage des temps (durée écoulée et durée totale de la musique)
            Padding(
              padding: const EdgeInsets.only(
                left: 25,
                right: 25,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    position.toString().split('.')[0],
                    style: GoogleFonts.varelaRound(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.blueGrey,
                    ),
                  ),
                  Text(
                    duration.toString().split('.')[0],
                    style: GoogleFonts.varelaRound(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
            // Affichage de la barre de gestion du temps de la musique
            Slider(
              activeColor: isDarkMode ? Colors.white : Colors.teal,
              inactiveColor: Colors.blueGrey,
              value: position.inSeconds.toDouble(),
              min: 0.0,
              max: duration.inSeconds.toDouble(),
              onChanged: (double value) => {
                setState(() {
                  widget.audioReader.seek(Duration(seconds: value.toInt()));
                  value = value;
                })
              },
            ),
            // Affichage des boutons de gestion de la lecture
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                loopBtn(),
                previousBtn(),
                playPauseBtn(),
                nextBtn(),
                randomBtn(),
              ],
            ),
          ],
        )
      ],
    ));
  }
}
