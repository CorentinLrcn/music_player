import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class GoBackBtn extends StatelessWidget {
  final AudioPlayer audioReader;

  const GoBackBtn({Key? key, required this.audioReader}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => {
        audioReader.stop(),
        Navigator.of(context).pop(),
      },
      icon: const Icon(
        Icons.arrow_back_ios_rounded,
        color: Colors.white,
      ),
    );
  }
}
