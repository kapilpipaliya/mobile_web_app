import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
    } on DioException catch (e) {
      print("error downloading file $e");
    }
  }
}

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings('ic_launcher');

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal() {
    init();
  }

  void init() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: _androidInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

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
      _flutterLocalNotificationsPlugin.show(
          0, 'Downloading file...', '$i%', platformChannelSpecifics,
          payload: 'item x');
    } else {
      _flutterLocalNotificationsPlugin.show(0, 'File downloaded successfully',
          'saved to $filePath', platformChannelSpecifics,
          payload: 'item x');
    }
  }
}
