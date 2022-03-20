import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_player/screens/music_player_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({Key? key}) : super(key: key);

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  late List<SongModel> songListTmp;
  late List<SongModel> songList;
  bool isCharging = true;

  getAudioFromStorage() async {
    songListTmp = await OnAudioQuery().querySongs();
  }

  Future<String> checkPermissionGetFiles() async {
    if (await Permission.storage.request().isGranted) {
      if (isCharging) {
        // récupération des fichiers audio
        await getAudioFromStorage();
        // filtration pour n'avoir que les musiques
        songList = songListTmp.where((i) => i.isMusic!).toList();
        setState(() {
          isCharging = false;
        });
      }
      return Future.delayed(const Duration(seconds: 0), () => "OK");
    }
    return Future.delayed(const Duration(seconds: 0), () => "notOK");
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF343130)
          : isCharging
              ? Colors.white
              : Colors.teal,
      body: Center(
        child: FutureBuilder(
          // récupération des fichiers audio après obtention de la permission
          // depuis le stockage de l'appareil
          future: checkPermissionGetFiles(),
          // construction de la liste après avoir récupéré les fichiers audio
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: songList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          color: isDarkMode ? Colors.grey[700] : Colors.white,
                          margin: const EdgeInsets.only(right: 10, left: 10),
                          child: ListTile(
                            leading: QueryArtworkWidget(
                              id: songList[index].id,
                              type: ArtworkType.AUDIO,
                              size: 2000,
                              quality: 100,
                              nullArtworkWidget:
                                  Image.asset('logo/no_image.png'),
                            ),
                            title: Text(
                              songList[index].title,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.teal,
                              ),
                            ),
                            subtitle: Text(
                              songList[index].artist!,
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.teal[800],
                              ),
                            ),
                            trailing: Text(
                              '${(songList[index].duration! / 1000 / 60).truncate()}:${(songList[index].duration! / 1000 % 60).truncate()}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.teal,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      MusicPlayerScreen(
                                          songList: songList, index: index),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          color: Colors.white,
                          thickness: 1,
                          indent: 30,
                          endIndent: 30,
                        );
                      },
                    ),
                  )
                ],
              );
            }
            return Center(
              child: Image.asset(
                isDarkMode ? 'logo/logo_white.png' : 'logo/logo_colored.png',
                height: screenWidth / 3.25,
                width: screenWidth / 3.25,
              ),
            );
          },
        ),
      ),
    );
  }
}
