import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/config/bootpay_config.dart';
import 'package:bootpay/user_info.dart';
import 'package:bootpay_bio/constants/bio_constants.dart';
import 'package:bootpay_bio/controller/bio_controller.dart';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:bootpay_bio/models/wallet/bio_metric.dart';
import 'package:bootpay_bio/models/wallet/next_job.dart';
import 'package:bootpay_bio/shims/bootpay_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bootpay_webview_flutter/bootpay_webview_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bootpay_bio.dart';
import '../config/bio_config.dart';
import '../controller/bio_debounce_close_controller.dart';


import 'package:bootpay_webview_flutter_android/bootpay_webview_flutter_android.dart';
import 'package:bootpay_webview_flutter_wkwebview/bootpay_webview_flutter_wkwebview.dart';


// typedef void BootpayNextJobCallback(NextJob data);


typedef WebViewCallback = void Function(JavaScriptMessage message);

// 1. 웹앱을 대체하는 뷰를 활용한 샘플
// 2. api 역할
class BioWebView extends StatefulWidget {
  // Payload;
  // Event
  // controller

  final Key? key;
  BioPayload? payload;


  late final WebViewCallback? onWebViewCancel;
  late final WebViewCallback? onWebViewError;
  late final WebViewCallback? onWebViewClose;
  late final WebViewCallback? onWebViewIssued;
  late final WebViewCallback? onWebViewConfirm;
  late final WebViewCallback? onWebViewDone;
  late final WebViewCallback? onWebViewRedirect;
  late final WebViewCallback? onWebViewEasySuccess;
  late final WebViewCallback? onWebViewEasyError;
  BootpayProgressBarCallback? onProgressShow;
  // final BootpayNextJobCallback? onNextJob;
  final BioController c = Get.find<BioController>();
  bool? showCloseButton = false;

  Widget? closeButton;
  bool? isEditMode = false;

  // WebView? webView;
  // Completer<WebViewController>? controller;
  // late final WebViewController _controller;
  WebViewController? controller;

  String? startScript;


  BioWebView(
      {this.key,
      this.payload,
      this.showCloseButton,
      this.closeButton,
      this.isEditMode,
      })
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BioWebViewState();

  // void transactionConfirm() {
  //   String script = "Bootpay.confirm()" +
  //       ".then( function (res) {" +
  //       _confirm() +
  //       _issued() +
  //       _done() +
  //       "}, function (res) {" +
  //       _error() +
  //       _cancel() +
  //       "});";
  //
  //   controller?.future.then((controller) {
  //     controller.evaluateJavascript(
  //         "setTimeout(function() { $script }, 30);"
  //     );
  //   });
  // }
}

class _BioWebViewState extends State<BioWebView> {
  final String INAPP_URL = 'https://webview.bootpay.co.kr/5.0.0-beta.36/';
  bool isClosed = false;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  // final BioDebounceCloseController closeController = Get.put(BioDebounceCloseController());


  //
  // void bootpayClose() {
  //   closeController.bootpayClose(widget.onWebViewClose);
  // }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    // widget.controller = Completer<WebViewController>();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is BTWebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            // debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            if (url.startsWith(INAPP_URL)) {
              // widget._controller
              for (String script in await BioConstants.getBootpayJSBeforeContentLoaded()) {
                // controller.evaluateJavascript(script);
                widget.controller?.runJavaScript(script);
              }
              // controller.evaluateJavascript(getBootpayJS());
              widget.controller?.runJavaScript(widget.startScript ?? '');
            }
          },
          // onNavi
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
            Page resource error:
            code: ${error.errorCode}
            description: ${error.description}
            errorType: ${error.errorType}
            isForMainFrame: ${error.isForMainFrame}
                    ''');

            if(error.errorCode == 3) { // SSL 인증서 에러, update 유도
              if(error.description.contains("sslerror:")) {
                JavaScriptMessage message = JavaScriptMessage(message: error.description);
                if (this.widget.onWebViewError != null) {
                  this.widget.onWebViewError!(message);
                }
                if(this.widget.onWebViewClose != null) {
                  this.widget.onWebViewClose!(message);
                }
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // if(widget.onShowHeader != null) {
            //   widget.onShowHeader!(request.url.contains("https://nid.naver.com") || request.url.contains("naversearchthirdlogin://"));
            // }
            // print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          // Navigation

        ),
      )
      ..addJavaScriptChannel(
        'BootpayCancel',
        onMessageReceived: onCancel,
      )
      ..addJavaScriptChannel(
        'BootpayError',
        onMessageReceived: onError,
      )
      ..addJavaScriptChannel(
        'BootpayClose',
        onMessageReceived: onClose,
      )
      ..addJavaScriptChannel(
        'BootpayIssued',
        onMessageReceived: onIssued,
      )
      ..addJavaScriptChannel(
        'BootpayConfirm',
        onMessageReceived: onConfirm,
      )
      ..addJavaScriptChannel(
        'BootpayDone',
        onMessageReceived: onDone,
      )
      ..addJavaScriptChannel(
        'BootpayFlutterWebView',
        onMessageReceived: onRedirect,
      )
      ..addJavaScriptChannel(
        'BootpayEasyError',
        onMessageReceived: onEasyError,
      )
      ..addJavaScriptChannel(
        'BootpayEasySuccess',
        onMessageReceived: onEasySuccess,
      )
      ..loadRequest(Uri.parse(INAPP_URL));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    widget.controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    if(widget.controller == null) return Container();
    // return  WebViewWidget(controller: widget.controller!);
    return platformWebViewWidget();
  }

  Widget platformWebViewWidget() {
    if(widget.controller!.platform is AndroidWebViewController && BootpayConfig.DISPLAY_WITH_HYBRID_COMPOSITION) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
          AndroidWebViewWidgetCreationParams(
            controller: widget.controller!.platform,
          ),
          displayWithHybridComposition: true,
        ),
      );
    }
    return WebViewWidget(controller: widget.controller!);
  }
}



extension BootpayCallback on _BioWebViewState {

  Future<void> onCancel(JavaScriptMessage message) async {
    if(this.widget.onWebViewCancel != null) {
      this.widget.onWebViewCancel!(message);
    }
  }

  Future<void> onError(JavaScriptMessage message) async {
    if(this.widget.onWebViewError != null) {
      this.widget.onWebViewError!(message);
    }
  }

  Future<void> onClose(JavaScriptMessage message) async {
    if(this.widget.onWebViewClose != null) {
      this.widget.onWebViewClose!(message);
    }
  }

  Future<void> onIssued(JavaScriptMessage message) async {
    if(this.widget.onWebViewIssued != null) {
      this.widget.onWebViewIssued!(message);
    }
  }


  Future<void> onConfirm(JavaScriptMessage message) async {
    if(this.widget.onWebViewConfirm != null) {
      this.widget.onWebViewConfirm!(message);
    }
  }


  Future<void> onDone(JavaScriptMessage message) async {
    if(this.widget.onWebViewDone != null) {
      this.widget.onWebViewDone!(message);
    }
  }

  Future<void> onRedirect(JavaScriptMessage message) async {
    if(this.widget.onWebViewRedirect != null) {
      this.widget.onWebViewRedirect!(message);
    }
  }

  Future<void> onEasyError(JavaScriptMessage message) async {
    if(this.widget.onWebViewEasyError != null) {
      this.widget.onWebViewEasyError!(message);
    }
  }


  Future<void> onEasySuccess(JavaScriptMessage message) async {
    if(this.widget.onWebViewEasySuccess != null) {
      this.widget.onWebViewEasySuccess!(message);
    }
  }
}


/*
JavascriptChannel onEasyError(BuildContext context) {
  return JavascriptChannel(
      name: 'BootpayEasyError',
      onMessageReceived: (JavascriptMessage message) {
        if(this.widget.onWebViewEasyError != null) {
          this.widget.onWebViewEasyError!(message);
        }
      });
}

JavascriptChannel onEasySuccess(BuildContext context) {
  return JavascriptChannel(
      name: 'BootpayEasySuccess',
      onMessageReceived: (JavascriptMessage message) async {
        if(this.widget.onWebViewEasySuccess != null) {
          this.widget.onWebViewEasySuccess!(message);
        }
      });
}
}
*/
