import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_player/tools/audio_reader.dart';
import 'package:music_player/tools/go_back_button.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../tools/audio_reader.dart';

class MusicPlayerScreen extends StatefulWidget {
  final List<SongModel> songList;
  final int index;

  const MusicPlayerScreen(
      {Key? key, required this.songList, required this.index})
      : super(key: key);

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late AudioPlayer audioReader;
  late int i;

  @override
  void initState() {
    super.initState();
    audioReader = AudioPlayer();
    i = widget.index;
  }

  changeIndex(String type) {
    if (type == 'next') {
      if (i == widget.songList.length - 1) {
        setState(() {
          i = 0;
        });
      } else {
        setState(() {
          i += 1;
        });
      }
    } else if (type == 'previous') {
      if (i == 0) {
        setState(() {
          i = widget.songList.length - 1;
        });
      } else {
        setState(() {
          i -= 1;
        });
      }
    } else if (type == 'random') {
      Random rndm = Random();
      setState(() {
        i = rndm.nextInt(widget.songList.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Couleur de fond en dégradé
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight - (screenHeight / 4),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDarkMode ? Colors.teal[900]! : Colors.teal[800]!,
                      isDarkMode ? Colors.teal[600]! : Colors.teal[200]!,
                    ]),
              ),
            ),
          ),
          // Infos sur disque + gestion de la lecture
          Positioned(
            right: 0,
            left: 0,
            top: screenHeight * 0.5,
            height: screenHeight,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: isDarkMode ? Colors.grey[850] : Colors.white,
              ),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.125),
                  Text(
                    widget.songList[i].title,
                    style: GoogleFonts.varelaRound(
                      fontSize: 24,
                      color: isDarkMode ? Colors.white : Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    widget.songList[i].artist!,
                    style: GoogleFonts.varelaRound(
                      fontSize: 20,
                      color: isDarkMode ? Colors.white : Colors.blueGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Affichage de la gestion de la lecture
                  AudioReader(
                    audioReader: audioReader,
                    song: widget.songList[i],
                    changeIndex: changeIndex,
                  ),
                ],
              ),
            ),
          ),
          // Affichage pochette de disque
          Positioned(
            top: screenHeight * 0.2,
            left: screenWidth * 0.1,
            height: screenWidth * 0.8,
            width: screenWidth * 0.8,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode ? Colors.white : Colors.blueGrey,
                  width: 2,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white : Colors.blueGrey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? Colors.white : Colors.grey[850]!,
                    width: 2,
                  ),
                ),
                child: QueryArtworkWidget(
                  id: widget.songList[i].id,
                  type: ArtworkType.AUDIO,
                  artworkFit: BoxFit.fill,
                  artworkBorder: BorderRadius.circular(150),
                  nullArtworkWidget: Image.asset('logo/no_image.png'),
                  quality: 100,
                  size: 1000,
                ),
              ),
            ),
          ),
          // App Bar pour retour en arrière
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: AppBar(
              title: const Text(''),
              leading: GoBackBtn(
                audioReader: audioReader,
              ),
              backgroundColor: Colors.white.withOpacity(0.0),
              elevation: 0,
            ),
          ),
          // Place pour de la pub
          // Positioned(
          //   top: screenHeight * 0.93,
          //   right: 0,
          //   left: 0,
          //   height: screenHeight * 0.2,
          //   child: Container(
          //     decoration: const BoxDecoration(
          //       color: Colors.blueGrey,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
