import 'dart:io';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mime/mime.dart';
import 'package:mobile_web/widgets/audio_player.dart';
import 'package:mobile_web/widgets/pdf_view.dart';
import 'package:mobile_web/widgets/video_player.dart';

@RoutePage()
class MediaPage extends StatefulWidget {
  final String filePath;

  const MediaPage({Key? key, required this.filePath}) : super(key: key);

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  String? fileType;
  String? fileName;

  @override
  void initState() {
    fileType = lookupMimeType(widget.filePath);
    RegExp exp = RegExp('\/((?:.(?!\/))+\$)');
    fileName = exp.firstMatch(widget.filePath)?.group(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName ?? 'Media file'),
      ),
      body: (fileType != null)
          ? ((fileType!.contains('image'))
              ? Image.file(File(widget.filePath))
              : (fileType!.contains('text'))
                  ? Text(File(widget.filePath).readAsStringSync())
                  : (fileType!.contains('audio'))
                      ? MyAudioPlayer(file: widget.filePath)
                      : (fileType!.contains('video'))
                          ? MyVideoPlayer(file: widget.filePath)
                          : (fileType!.contains('pdf'))
                              ? PdfViewer(file: widget.filePath)
                              : Container())
          : Container(),
    );
  }
}
