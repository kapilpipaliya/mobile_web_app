import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_web/main.dart';
import 'package:path/path.dart' as path;

class DownloadProvider extends ChangeNotifier {
  download(String url) async {
    NotificationService notificationService = NotificationService();
    Timer? notificationTimer;
    try {
      String filePath = '';
      final dio = Dio();
      int progress = 0;
      notificationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        notificationService.createNotification(100, progress, filePath);
        if (progress == 100) {
          Fluttertoast.showToast(msg: "File downloaded successfully");
          timer.cancel();
        }
      });
      String basename = path.basename(url);
      filePath = path.join("/storage/emulated/0/Download", basename);
      await dio.download(url, filePath,
          onReceiveProgress: ((count, total) async {
        progress = ((count / total) * 100).toInt();
        // await Future.delayed(const Duration(seconds: 1), () {
        //   notifyListeners();
        // });
      }));
    } on DioException catch (e) {
      print("error downloading file $e");
      if (notificationTimer != null) {
        notificationTimer.cancel();
        notificationService.createNotification(0, 0, '', error: e.message);
      }
    }
  }
}

class NotificationService {
  void createNotification(int count, int i, String filePath, {String? error}) {
    var androidPlatformChannelSpecifics = (count != i)
        ? AndroidNotificationDetails('progress channel', 'progress channel',
            channelDescription: 'progress channel description',
            channelShowBadge: false,
            importance: Importance.defaultImportance,
            onlyAlertOnce: true,
            showProgress: true,
            playSound: false,
            enableVibration: false,
            maxProgress: count,
            progress: i)
        : const AndroidNotificationDetails(
            'success channel',
            'success channel',
            channelDescription: 'success channel description',
            channelShowBadge: true,
            importance: Importance.max,
            priority: Priority.high,
          );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    if (count != i) {
      flutterLocalNotificationsPlugin.show(
          0, 'Downloading file...', '$i%', platformChannelSpecifics,
          payload: 'item x');
    } else {
      if (error != null) {
        flutterLocalNotificationsPlugin.show(
            0, 'Download failed', error, platformChannelSpecifics,
            payload: 'file:$filePath');
      } else {
        flutterLocalNotificationsPlugin.show(0, 'File downloaded successfully',
            'Click to view file', platformChannelSpecifics,
            payload: 'file:$filePath');
      }
    }
  }
}
