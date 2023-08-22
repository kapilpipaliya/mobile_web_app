// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';
import 'package:mobile_web/core/persistence/preference_helper.dart';
import 'package:mobile_web/provider/download_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  final urlController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  String? url;
  String? htmlContent;
  double progress = 0;
  final GlobalKey webViewKey = GlobalKey();
  bool showAppbar = true;
  File? tempFile;
  List<Map<String, dynamic>> drawerActions = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getUrl();
    super.initState();
  }

  getUrl() async {
    url = await PreferenceHelper.getUrl();
    htmlContent = await rootBundle.loadString("assets/html/index.html");
    setState(() {});
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestPermission();
  }

  @override
  void dispose() {
    _webViewController = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!kIsWeb) {
      if (_webViewController != null &&
          defaultTargetPlatform == TargetPlatform.android) {
        if (state == AppLifecycleState.paused) {
          pauseAll();
        } else {
          resumeAll();
        }
      }
    }
  }

  void pauseAll() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _webViewController?.android.pause();
    }
    _webViewController?.pauseTimers();
  }

  void resumeAll() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _webViewController?.android.resume();
    }
    _webViewController?.resumeTimers();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final controller = _webViewController;
        if (controller != null && await controller.canGoBack()) {
          controller.goBack();
          return false;
        } else {
          showDialog(
              context: context,
              builder: (context) {
                return _exitAppDialog();
              });
          return false;
        }
      },
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          drawer: _buildDrawer(),
          body: Column(children: <Widget>[
            if (showAppbar)
              Container(
                color: Theme.of(context).primaryColor,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              context.router.pop();
                            },
                            icon: const Icon(Icons.arrow_back)),
                        IconButton(
                            onPressed: () {
                              if (_webViewController != null) {
                                _webViewController!.goForward();
                              }
                            },
                            icon: const Icon(Icons.arrow_forward)),
                        IconButton(
                            onPressed: () {
                              if (_webViewController != null) {
                                _webViewController!.reload();
                              }
                            },
                            icon: const Icon(Icons.refresh)),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              urlController.text = url ?? '';
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return _changeUrlDialog();
                                  });
                            },
                            child: Text(
                              url ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                        height: 5,
                        child: progress < 1.0
                            ? LinearProgressIndicator(
                                value: progress,
                                color: Colors.cyan,
                              )
                            : Container()),
                  ],
                ),
              ),
            FutureBuilder(
                future: isNetworkAvailable(),
                builder: (context, snapshot) {
                  return (snapshot.hasData &&
                          (htmlContent != null || url != null))
                      ? Expanded(
                          child: (snapshot.data ?? false)
                              ? InAppWebView(
                                  key: webViewKey,
                                  initialData: (htmlContent != null)
                                      ? InAppWebViewInitialData(
                                          data: htmlContent!)
                                      : null,
                                  initialUrlRequest: (url != null)
                                      ? URLRequest(url: Uri.parse(url!))
                                      : null,
                                  initialOptions: InAppWebViewGroupOptions(
                                    crossPlatform: InAppWebViewOptions(
                                      javaScriptEnabled: true,
                                      useOnDownloadStart: true,
                                    ),
                                  ),
                                  shouldOverrideUrlLoading:
                                      (controller, navigationAction) async {
                                    final uri = navigationAction.request.url!;
                                    if (uri.scheme == 'http') {
                                      await controller.loadUrl(
                                          urlRequest: URLRequest(
                                              url: uri.replace(
                                                  scheme: 'https')));
                                      return NavigationActionPolicy.CANCEL;
                                    }
                                    return NavigationActionPolicy.ALLOW;
                                  },
                                  onWebViewCreated: (InAppWebViewController
                                      controller) async {
                                    _webViewController = controller;
                                    await controller
                                        .injectJavascriptFileFromAsset(
                                            assetFilePath:
                                                "assets/html/index.js");
                                    controller.addJavaScriptHandler(
                                        handlerName: "myChannel",
                                        callback: handleArgs);
                                  },
                                  onLoadStart:
                                      (InAppWebViewController controller,
                                          Uri? url) {
                                    setState(() {
                                      this.url = url.toString();
                                      PreferenceHelper.setUrl(this.url ?? '');
                                    });
                                  },
                                  onLoadStop:
                                      (InAppWebViewController controller,
                                          Uri? url) {
                                    setState(() {
                                      this.url = url.toString();
                                      PreferenceHelper.setUrl(this.url ?? '');
                                    });
                                  },
                                  onProgressChanged:
                                      (InAppWebViewController controller,
                                          int progress) {
                                    setState(() {
                                      this.progress = progress / 100;
                                    });
                                  },
                                  onConsoleMessage:
                                      (InAppWebViewController controller,
                                          ConsoleMessage consoleMessage) {
                                    debugPrint(
                                        "console message: ${consoleMessage.message}");
                                  },
                                  onCloseWindow: (controller) {
                                    context.router.pop();
                                  },
                                )
                              : const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    "Not connected to Internet ",
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ),
                        )
                      : Container();
                }),
          ]),
        ),
      ),
    );
  }

  Future<bool> isNetworkAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }

    return true;
  }

  _buildDrawer() {
    return Drawer(
      child: StatefulBuilder(builder: (context, StateSetter innerState) {
        return _drawerOptions(drawerActions, innerState);
      }),
    );
  }

  _drawerOptions(List options, StateSetter innerState) {
    return Column(
      children: List.generate(
          options.length,
          (index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          options[index]['name'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        (options[index]['children'] != null &&
                                (options[index]['children'] as List).isNotEmpty)
                            ? IconButton(
                                onPressed: () {
                                  options[index]['expanded'] =
                                      !options[index]['expanded'];
                                  innerState(() {});
                                },
                                icon: const Icon(Icons.arrow_drop_down))
                            : Container()
                      ],
                    ),
                    if (options[index]['expanded'] != null &&
                        options[index]['expanded'])
                      _drawerOptions(
                          options[index]['children'] as List, innerState)
                  ],
                ),
              )),
    );
  }

  _changeUrlDialog() {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Change url",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 14,
            ),
            TextField(controller: urlController),
            const SizedBox(
              height: 14,
            ),
            ElevatedButton(
                onPressed: () {
                  context.router.pop();
                  _webViewController!.loadUrl(
                      urlRequest:
                          URLRequest(url: Uri.parse(urlController.text)));
                },
                child: const Text("Load"))
          ],
        ),
      ),
    );
  }

  _exitAppDialog() {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Exit app?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      context.router.pop();
                    },
                    child: const Text("No")),
                ElevatedButton(
                    onPressed: () {
                      exit(0);
                    },
                    child: const Text("Yes")),
              ],
            )
          ],
        ),
      ),
    );
  }

  handleArgs(List args) {
    try {
      Map<String, dynamic> argData = jsonDecode(args[0]);
      performAction(argData);
    } catch (e) {
      print(e);
    }
  }

  performAction(Map<String, dynamic> argData) async {
    if (argData['action'] == "navbar") {
      showAppbar = !showAppbar;
      setState(() {});
    } else if (argData['action'] == "openDrawer") {
      drawerActions = [];
      List tempList = argData['menu'] as List;
      for (int i = 0; i < tempList.length; i++) {
        drawerActions.add(tempList[i] as Map<String, dynamic>);
      }
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState!.openDrawer();
      });
    } else if (argData['action'] == "selectFile") {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        tempFile = File(result.files.first.path!);
        return result.files.first.path;
      }
    } else if (argData['action'] == "shareFile") {
      if (argData['url'] != null) {
        Share.share("Hay, Download this new file : ${argData['url']}");
      } else if (tempFile != null) {
        Share.shareXFiles([XFile(tempFile!.path)],
            text: "Hay, check this new file");
      } else {
        Fluttertoast.showToast(msg: "Please select s file to share");
      }
    } else if (argData['action'] == "downloadFile") {
      await _getStoragePermission();
      await DownloadProvider().download(argData['url']);
      Fluttertoast.showToast(msg: "File downloaded successfully");
    } else if (argData['action'] == "setWallpaper") {
      if (tempFile != null) {
        int location = WallpaperManager.HOME_SCREEN;
        bool result = await WallpaperManager.setWallpaperFromFile(
            tempFile!.path, location);
        return result;
      } else {
        Fluttertoast.showToast(msg: "Please select file to set wallpaper");
      }
    } else if (argData['action'] == "addEvent" ||
        argData['action'] == "removeEvent") {
      bool isPermission = await _getCalenderPermission();
      if (isPermission) {
        final CalendarPlugin calender = CalendarPlugin();
        List<Calendar>? calenders = await calender.getCalendars();
        if (calenders != null && calenders.isNotEmpty) {
          if (argData['action'] == "addEvent") {
            calender.createEvent(
                calendarId: calenders[0].id!,
                event: CalendarEvent(
                    eventId: argData['id'],
                    title: argData['title'],
                    startDate: DateTime.parse(argData['date']),
                    endDate: DateTime.parse(argData['date']),
                    attendees: Attendees(attendees: [])));
          } else {
            calender.deleteEvent(
                calendarId: calenders[0].id!, eventId: argData['id']);
          }
        }
      }
    } else if (argData['action'] == "getLocation") {
      LocationPermission permission;
      await Geolocator.isLocationServiceEnabled();
      try {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return Future.error('Location permissions are denied');
          }
        }

        if (permission == LocationPermission.deniedForever) {
          Fluttertoast.showToast(msg: "Please enable permission from settings");
          openAppSettings();
        }

        Position position = await Geolocator.getCurrentPosition();
        Fluttertoast.showToast(
            msg:
                "Latitude is : ${position.latitude}\nLongitude is : ${position.longitude}");
      } catch (e) {
        print(e.toString());
      }
    } else if (argData['action'] == "clearCache") {
      await _webViewController!.clearCache();
      Fluttertoast.showToast(msg: "cache data cleared");
    } else if (argData['action'] == 'showNotification') {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: initializationSettingsDarwin);
      flutterLocalNotificationsPlugin.initialize(initializationSettings);
      flutterLocalNotificationsPlugin.show(
        1,
        argData['title'],
        argData['body'],
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'notification channel id', 'notification channel name',
              channelDescription: 'notification description'),
        ),
      );
    }
  }
}

Future<bool> _getStoragePermission() async {
  PermissionStatus status = await Permission.storage.status;
  if (!status.isGranted) {
    status = await Permission.storage.request();
  }
  return status.isGranted;
}

Future<bool> _getCalenderPermission() async {
  PermissionStatus status = await Permission.calendar.status;
  if (!status.isGranted) {
    status = await Permission.calendar.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
  return status.isGranted;
}
