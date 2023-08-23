import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioPlayer extends StatefulWidget {
  final String file;

  const MyAudioPlayer({Key? key, required this.file}) : super(key: key);

  @override
  State<MyAudioPlayer> createState() => _MyAudioPlayerState();
}

class _MyAudioPlayerState extends State<MyAudioPlayer> {
  final player = AudioPlayer();
  String audioText = "Audio Loading..";

  @override
  void initState() {
    playAudio();
    super.initState();
  }

  playAudio() async {
    await player.setFilePath(widget.file);
    player.play();
    audioText = "Audio playing, Enjoy it..";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(audioText, style: const TextStyle(fontSize: 25)),
    );
  }
}
