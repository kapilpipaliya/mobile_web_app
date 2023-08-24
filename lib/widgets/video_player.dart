import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_web/widgets/action_button.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends StatefulWidget {
  final String file;

  const MyVideoPlayer({Key? key, required this.file}) : super(key: key);

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.file))
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.addListener(() {
      if ( !_controller.value.isPlaying) {
        isPlaying = false;
        setState(() {});
      }else if(_controller.value.isPlaying){
        isPlaying = true;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Stack(
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ActionButton(
                          onTap: () {}, icon: const Icon(Icons.skip_previous)),
                      const SizedBox(
                        width: 20,
                      ),
                      ActionButton(
                          onTap: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                          icon: Icon(isPlaying
                              ? Icons.pause
                              : Icons.play_arrow)),
                      const SizedBox(
                        width: 20,
                      ),
                      ActionButton(
                          onTap: () {}, icon: const Icon(Icons.skip_next))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
