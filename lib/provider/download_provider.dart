import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_web/main.dart';
import 'package:path/path.dart' as path;

class DownloadProvider extends ChangeNotifier {
  download(String url) async {
    NotificationService notificationService = NotificationService();
    try {
      String filePath = '';
      final dio = Dio();
      String basename = path.basename(url);
      filePath = path.join("/storage/emulated/0/Download", basename);
      await dio.download(url, filePath,
          onReceiveProgress: ((count, total) async {
        await Future.delayed(const Duration(seconds: 1), () {
          notificationService.createNotification(
              100, ((count / total) * 100).toInt(), filePath);
          notifyListeners();
        });
      }));
      notificationService.createNotification(100, 100, filePath);
      Fluttertoast.showToast(msg: "File downloaded successfully");
    } on DioException catch (e) {
      print("error downloading file $e");
    }
  }
}

class NotificationService {
  void createNotification(int count, int i, String filePath) {
    var androidPlatformChannelSpecifics = (count != i)
        ? AndroidNotificationDetails('progress channel', 'progress channel',
            channelDescription: 'progress channel description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: count,
            progress: i)
        : const AndroidNotificationDetails(
            'progress channel',
            'progress channel',
            channelDescription: 'progress channel description',
            channelShowBadge: false,
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
      flutterLocalNotificationsPlugin.show(0, 'File downloaded successfully',
          'Click to view file', platformChannelSpecifics,
          payload: 'file:$filePath');
    }
  }
}
