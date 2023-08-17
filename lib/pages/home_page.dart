import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  final urlController = TextEditingController();
  String url = "https://flutter.dev/";
  String htmlContent = '';
  double progress = 0;
  final GlobalKey webViewKey = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
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
        if (controller != null) {
          if (await controller.canGoBack()) {
            controller.goBack();
            return false;
          }
        }
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Column(children: <Widget>[
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
                            urlController.text = url;
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return _changeUrlDialog();
                                });
                          },
                          child: Text(
                            url,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
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
                            initialData: (url.isEmpty)
                                ? InAppWebViewInitialData(data: htmlContent)
                                : null,
                            initialUrlRequest: URLRequest(url: Uri.parse(url)),
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
                                  callback: (args) async {});
                            },
                            onLoadStart:
                                (InAppWebViewController controller, Uri? url) {
                              setState(() {
                                this.url = url.toString();
                              });
                            },
                            onLoadStop:
                                (InAppWebViewController controller, Uri? url) {
                              setState(() {
                                this.url = url.toString();
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
}
