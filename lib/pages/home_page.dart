// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_web/core/constants/constants.dart';
import 'package:mobile_web/core/persistence/preference_helper.dart';
import 'package:path/path.dart' as path;
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
  String? url;
  double progress = 0;
  final GlobalKey webViewKey = GlobalKey();
  bool showAppbar = true;
  File? tempFile;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getUrl();
    super.initState();
  }

  getUrl() async {
    url = await PreferenceHelper.getUrl();
    setState(() {});
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
                        ),
                        if (url != null)
                          InkWell(
                            onTap: () {
                              url = null;
                              setState(() {});
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('view actions'),
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
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return Expanded(
                    child: (snapshot.data ?? false)
                        ? InAppWebView(
                            key: webViewKey,
                            initialData: (url != null)
                                ? InAppWebViewInitialData(data: htmlContent)
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
                                        url: uri.replace(scheme: 'https')));
                                return NavigationActionPolicy.CANCEL;
                              }
                              return NavigationActionPolicy.ALLOW;
                            },
                            onWebViewCreated:
                                (InAppWebViewController controller) {
                              _webViewController = controller;
                              controller.addJavaScriptHandler(
                                  handlerName: "myChannel",
                                  callback: handleArgs);
                            },
                            onLoadStart:
                                (InAppWebViewController controller, Uri? url) {
                              setState(() {
                                this.url = url.toString();
                                PreferenceHelper.setUrl(this.url ?? '');
                              });
                            },
                            onLoadStop:
                                (InAppWebViewController controller, Uri? url) {
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
                  );
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

  handleArgs(List args) async {
    if (args[0] == "navbar") {
      showAppbar = !showAppbar;
      setState(() {});
    } else if (args[0] == "selectFile") {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        tempFile = File(result.files.first.path!);
        return result.files.first.path;
      }
    } else if (args[0] == "shareFile") {
      if (tempFile != null) {
        Share.shareXFiles([XFile(tempFile!.path)],
            text: "Hay, check this new file");
      } else {
        Fluttertoast.showToast(msg: "Please select s file to share");
      }
    } else if (args[0] == "downloadFile") {
      HttpClient httpClient = HttpClient();
      String filePath = '';
      bool isPermission = false;
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          var result = await Permission.storage.request();
          if (!result.isGranted) {
            openAppSettings();
            return;
          } else {
            isPermission = true;
          }
        } else {
          isPermission = true;
        }
      } else {
        isPermission = true;
      }
      if (isPermission) {
        var request = await httpClient.getUrl(Uri.parse(args[1]));
        var response = await request.close();
        if (response.statusCode == 200) {
          var bytes = await consolidateHttpClientResponseBytes(response);
          String basename = path.basename(args[1]);
          File file = File(path.join("/storage/emulated/0/Download", basename));
          await file.writeAsBytes(bytes);
          filePath = file.path;
        }
      }
      return filePath;
    } else if (args[0] == "setWallpaper") {
      if (tempFile != null) {
        int location = WallpaperManager.HOME_SCREEN;
        bool result = await WallpaperManager.setWallpaperFromFile(
            tempFile!.path, location);
        return result;
      } else {
        Fluttertoast.showToast(msg: "Please select file to set wallpaper");
      }
    }
  }
}
