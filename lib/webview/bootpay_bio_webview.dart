import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/user_info.dart';
import 'package:bootpay_bio/constants/bio_constants.dart';
import 'package:bootpay_bio/controller/bio_controller.dart';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:bootpay_bio/models/wallet/bio_metric.dart';
import 'package:bootpay_bio/models/wallet/next_job.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bootpay_webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


typedef void BootpayNextJobCallback(NextJob data);


// 1. 웹앱을 대체하는 뷰를 활용한 샘플
// 2. api 역할
class BootpayBioWebView extends WebView {
  // Payload;
  // Event
  // controller

  final Key? key;
  final BioPayload? payload;
  final BootpayDefaultCallback? onCancel;
  final BootpayDefaultCallback? onError;
  final BootpayCloseCallback? onClose;
  final BootpayCloseCallback? onCloseHardware;
  final BootpayDefaultCallback? onReady;
  final BootpayConfirmCallback? onConfirm;
  final BootpayDefaultCallback? onDone;
  final BootpayNextJobCallback? onNextJob;
  bool? showCloseButton = false;
  Widget? closeButton;

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  BootpayBioWebView(
      {this.key,
      this.payload,
      this.showCloseButton,
      this.onCancel,
      this.onError,
      this.onClose,
      this.onCloseHardware,
      this.onReady,
      this.onConfirm,
      this.onDone,
      this.onNextJob,
      this.closeButton,
      })
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BootpayWebViewState();

  void transactionConfirm(String data) {
    _controller.future.then((controller) {
      controller.evaluateJavascript(
        "setTimeout(function() { BootPay.transactionConfirm(JSON.parse('$data')); }, 30);"
      );
    });
  }

  void removePaymentWindow() {
    _controller.future.then((controller) {
      controller.evaluateJavascript(
          "Bootpay.removePaymentWindow();"
      );
      // controller.
    });
  }

  Future<void> requestAddBioData() async {
    String script = await BioConstants.getJSBiometricAuthenticate(payload!);
    print('requestAddBioData : $script');
    _controller.future.then((controller) {
      controller.evaluateJavascript(
          script
      );
      // controller.
    });
  }

  Future<void> requestBioForPay(String otp, String? cardQuota) async {
    String script = await BioConstants.getJSBioOTPPay(payload!, otp, cardQuota ?? "0");
    print('requestBioForPay : $script');
    _controller.future.then((controller) {
      controller.evaluateJavascript(
          script
      );
      // controller.
    });
  }
}

class _BootpayWebViewState extends State<BootpayBioWebView> {

  // final String INAPP_URL = 'https://inapp.bootpay.co.kr/3.3.3/production.html';
  final String INAPP_URL = 'https://webview.bootpay.co.kr/4.0.0/';
  bool isClosed = false;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  final BioController c = Get.find<BioController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();


    // widget.showCloseButton?;
    // widget.onError!("error test");
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return WebView(
      key: widget.key,
      initialUrl: INAPP_URL,
      javascriptMode: JavascriptMode.unrestricted,
      gestureRecognizers: gestureRecognizers,
      onWebViewCreated: (WebViewController webViewController) {
        widget._controller.complete(webViewController);
      },
      javascriptChannels: <JavascriptChannel>[
        onCancel(context),
        onError(context),
        onClose(context),
        onReady(context),
        onConfirm(context),
        onDone(context),
        onEasyError(context),
        onEasySuccess(context)
      ].toSet(),
      navigationDelegate: (NavigationRequest request) {
        if(Platform.isAndroid)  return NavigationDecision.prevent;
        else return NavigationDecision.navigate;
      },

      onPageFinished: (String url) {


        if (url.startsWith(INAPP_URL)) {
          widget._controller.future.then((controller) async {
            for (String script in await BioConstants.getBootpayJSBeforeContentLoaded()) {
              // controller.evaluateJavascript(script);
              controller.evaluateJavascript(script);
            }
            // controller.evaluateJavascript(getBootpayJS());
            controller.evaluateJavascript(await getBootpayJS());
          });
        }

        //네이버페이 일 경우 뒤로가기 버튼 제거 - 그러나 작동하지 않는다 (아마 팝업이라)
        // if(url.startsWith("https://nid.naver.com/nidlogin.login")) {
        //   widget._controller.future.then((controller) async {
        //     controller.evaluateJavascript('window.document.getElementById("back").remove();');
        //   });
        // }
      },
      gestureNavigationEnabled: true,
    );

    // return Stack(
    //   children: [
    //     isClosed == false ? WebView(
    //       key: widget.key,
    //       initialUrl: INAPP_URL,
    //       javascriptMode: JavascriptMode.unrestricted,
    //       onWebViewCreated: (WebViewController webViewController) {
    //         widget._controller.complete(webViewController);
    //       },
    //       javascriptChannels: <JavascriptChannel>[
    //         onCancel(context),
    //         onError(context),
    //         onClose(context),
    //         onReady(context),
    //         onConfirm(context),
    //         onDone(context)
    //       ].toSet(),
    //       navigationDelegate: (NavigationRequest request) {
    //         if(Platform.isAndroid)  return NavigationDecision.prevent;
    //         else return NavigationDecision.navigate;
    //       },
    //
    //       onPageFinished: (String url) {
    //
    //
    //         if (url.startsWith(INAPP_URL)) {
    //           widget._controller.future.then((controller) async {
    //             for (String script in await BioConstants.getBootpayJSBeforeContentLoaded()) {
    //               // controller.evaluateJavascript(script);
    //               controller.runJavascript(script);
    //             }
    //             // controller.evaluateJavascript(getBootpayJS());
    //             controller.runJavascript(getBootpayJS());
    //           });
    //         }
    //
    //         //네이버페이 일 경우 뒤로가기 버튼 제거 - 그러나 작동하지 않는다 (아마 팝업이라)
    //         // if(url.startsWith("https://nid.naver.com/nidlogin.login")) {
    //         //   widget._controller.future.then((controller) async {
    //         //     controller.evaluateJavascript('window.document.getElementById("back").remove();');
    //         //   });
    //         // }
    //       },
    //       gestureNavigationEnabled: true,
    //     ) : Container(),
    //     // widget.showCloseButton == false ?
    //     // Container() :
    //     // widget.closeButton != null ?
    //     // GestureDetector(
    //     //   child: widget.closeButton!,
    //     //   onTap: () => clickCloseButton(),
    //     // ) :
    //     // Padding(
    //     //   padding: const EdgeInsets.all(5.0),
    //     //   child: Container(
    //     //     height: 40,
    //     //     child: Row(
    //     //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     //       children: [
    //     //         Expanded(child: Container()),
    //     //         IconButton(
    //     //             onPressed: () => clickCloseButton(),
    //     //             icon: Icon(Icons.close, size: 35.0, color: Colors.black54),
    //     //         ),
    //     //       ],
    //     //     ),
    //     //   ),
    //     // )
    //   ],
    // );
  }
}

extension BootpayMethod on _BootpayWebViewState {

  void callJavascript(String script) {
    widget._controller.future.then((controller) async {
      // controller.runJavascript(script);
      controller.evaluateJavascript(script);
    });
  }

  Future<String> getBootpayJS() async {
    if(widget.payload == null) return "";

    String script = "";
    if([BioConstants.REQUEST_PASSWORD_TOKEN,
        BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD,
        BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY,
        BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD].contains(c.requestType.value)) {
      // contro
      script = BioConstants.getJSPasswordToken(widget.payload!);

    } else if(BioConstants.REQUEST_ADD_CARD == c.requestType.value) {
      script = BioConstants.getJSAddCard(widget.payload!);

    } else if(BioConstants.REQUEST_BIO_FOR_PAY == c.requestType.value) {
      script = BioConstants.getJSBioOTPPay(widget.payload!, c.otp, "${c.selectedQuota}");
    } else if([BioConstants.REQUEST_ADD_BIOMETRIC,
               BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY].contains(c.requestType.value)) {
      script = await BioConstants.getJSBiometricAuthenticate(widget.payload!);
    } else if(BioConstants.REQUEST_TOTAL_PAY == c.requestType.value) {
      script = BioConstants.getJSTotalPay(widget.payload!);
    } else if(BioConstants.REQUEST_DELETE_CARD == c.requestType.value) {
      script = BioConstants.getJSDestroyWallet(widget.payload!);
    }
    print("script: $script");

    return "setTimeout(function() {" + script + "}, 50);";
    // c.requestType.value == BioConstants.REQUEST_PASSWORD_TOKEN

    // if(CurrentBioRequest.getInstance().requestType == BioConstants.REQUEST_PASSWORD_TOKEN ||
    //     CurrentBioRequest.getInstance().requestType == BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD ||
    //     CurrentBioRequest.getInstance().requestType == BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY ||
    //     CurrentBioRequest.getInstance().requestType == BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD) {
    //   callJavaScript(BioConstants.getJSPasswordToken(payload));
    // } else if(CurrentBioRequest.getInstance().requestType == BioConstants.REQUEST_ADD_CARD) {
    //   callJavaScript(BioConstants.getJSAddCard(payload));
    // } else if(CurrentBioRequest.getInstance().requestType == BioConstants.REQUEST_BIO_FOR_PAY) {
    //   callJavaScript(BioConstants.getJSBioOTPPay(payload));
    // } else if(CurrentBioRequest.getInstance().requestType == BioConstants.REQUEST_ADD_BIOMETRIC ||
    //     CurrentBioRequest.getInstance().requestType == BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY) {
    //   callJavaScript(BioConstants.getJSBiometricAuthenticate(payload));
    // } else if(CurrentBioRequest.getInstance().requestType == BioConstants.REQUEST_TOTAL_PAY) {
    //   callJavaScript(BioConstants.getJSTotalPay(payload));
    // } else if(CurrentBioRequest.getInstance().requestType == BioConstants.REQUEST_DELETE_CARD) {
    //   callJavaScript(BioConstants.getJSDestroyWallet(payload));
    // }

    // String script = "Bootpay.requestPayment(" +
    //     "${this.widget.payload.toString()}" +
    //     ")" +
    //     ".then( function (res) {" +
    //     confirm() +
    //     issued() +
    //     done() +
    //     "}, function (res) {" +
    //     error() +
    //     cancel() +
    //     "})";
    //
    // print(script);
    //
    // return "setTimeout(function() {" + script + "}, 50);";
  }



  // String error() {
  //   return ".error(function (data) { if (window.BootpayError && window.BootpayError.postMessage) { BootpayError.postMessage(JSON.stringify(data)); } })";
  // }
  //
  // String cancel() {
  //   return ".cancel(function (data) { if (window.BootpayCancel && window.BootpayCancel.postMessage) { BootpayCancel.postMessage(JSON.stringify(data)); } })";
  // }
  //
  // String ready() {
  //   return ".ready(function (data) { if (window.BootpayReady && window.BootpayReady.postMessage) { BootpayReady.postMessage(JSON.stringify(data)); } })";
  // }
  //
  // String confirm() {
  //   return ".confirm(function (data) { if (window.BootpayConfirm && window.BootpayConfirm.postMessage) { BootpayConfirm.postMessage(JSON.stringify(data)); } })";
  // }
  //
  // String close() {
  //   return ".close(function (data) { if (window.BootpayClose && window.BootpayClose.postMessage) { BootpayClose.postMessage(JSON.stringify(data)); } })";
  // }
  //
  // String done() {
  //   return ".done(function (data) { if (window.BootpayDone && window.BootpayDone.postMessage) { BootpayDone.postMessage(JSON.stringify(data)); } })";
  // }

  // String confirm() {
  //   return "if (res.event === 'confirm') { if (window.BootpayConfirm && window.BootpayConfirm.postMessage) { BootpayConfirm.postMessage(JSON.stringify(res)); } }";
  // }
  //
  //
  // String done() {
  //   return "else if (res.event === 'done') { if (window.BootpayDone && window.BootpayDone.postMessage) { BootpayDone.postMessage(JSON.stringify(res)); } }";
  // }
  //
  //
  // String issued() {
  //   return "else if (res.event === 'issued') { if (window.BootpayIssued && window.BootpayIssued.postMessage) { BootpayIssued.postMessage(JSON.stringify(res)); } }";
  // }
  //
  // String error() {
  //   return "if (res.event === 'error') { console.log(1234);  if (window.BootpayError && window.BootpayError.postMessage) { BootpayError.postMessage(JSON.stringify(res)); } }";
  // }
  //
  // String cancel() {
  //   return "else if (res.event === 'cancel') { if (window.BootpayCancel && window.BootpayCancel.postMessage) { BootpayCancel.postMessage(JSON.stringify(res)); } }";
  // }
  //
  // String close() {
  //   return "document.addEventListener('bootpayclose', function (e) { if (window.BootpayClose && window.BootpayClose.postMessage) { BootpayClose.postMessage('결제창이 닫혔습니다'); } });";
  // }



  Future<String> getAnalyticsData() async {
    UserInfo.updateInfo();
    return "Bootpay.setAnalyticsData({uuid:'${await UserInfo.getBootpayUUID()}',sk:'${await UserInfo.getBootpaySK()}',sk_time:'${await UserInfo.getBootpayLastTime()}',time:'${DateTime.now().millisecondsSinceEpoch - await UserInfo.getBootpayLastTime()}'});";
  }

  void transactionConfirm(String data) {
    widget.transactionConfirm(data);
  }

  void clickCloseButton() {
    removePaymentWindow();

    if (widget.onCancel != null) {
      widget.onCancel!('{"action":"BootpayCancel","status":-100,"message":"사용자에 의한 취소"}');
    }
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  void removePaymentWindow() {
    setState(() {
      this.isClosed = true;
    });

    widget.removePaymentWindow();
  }
}


extension BootpayCallback on _BootpayWebViewState {
  JavascriptChannel onCancel(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayCancel',
        onMessageReceived: (JavascriptMessage message) {
          print('BootpayCancel');
          // print("21431: " + message.message);
          // print(widget.onCancel != null);
          if (this.widget.onCancel != null)
            this.widget.onCancel!(message.message);
        });
  }

  JavascriptChannel onError(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayError',
        onMessageReceived: (JavascriptMessage message) {
          print('BootpayError');
          c.requestType.value = BioConstants.REQUEST_TYPE_NONE;

          if (this.widget.onError != null)
            this.widget.onError!(message.message);
        });
  }

  JavascriptChannel onClose(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayClose',
        onMessageReceived: (JavascriptMessage message) {
          print("BootpayClose: ${c.requestType.value}");

          NextJob job = NextJob();
          if([BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD,
            BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY,
            BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD,
            BioConstants.REQUEST_ADD_CARD,
            BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY,
          ].contains(c.requestType.value)) {
            job.type = c.requestType.value;

            if(BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY == c.requestType.value ||
                BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY == c.requestType.value) {
              job.nextType = BioConstants.NEXT_JOB_RETRY_PAY;
            } else if(BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD == c.requestType.value) {
              job.nextType = BioConstants.NEXT_JOB_ADD_NEW_CARD;
            } else if(BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD == c.requestType.value) {
              job.nextType = BioConstants.NEXT_JOB_ADD_DELETE_CARD;
            } else if(BioConstants.REQUEST_ADD_CARD == c.requestType.value) {
              job.nextType = BioConstants.NEXT_JOB_GET_WALLET_LIST;
            }

            if (widget.onNextJob != null) widget.onNextJob!(job);
          } else {
            job.initToken = true;
            if (widget.onNextJob != null) widget.onNextJob!(job);
            if (widget.onClose != null) widget.onClose!();
          }


          // Navigator.of(context).pop();
        });
  }

  JavascriptChannel onReady(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayReady',
        onMessageReceived: (JavascriptMessage message) {
          if (this.widget.onReady != null)
            this.widget.onReady!(message.message);
        });
  }

  JavascriptChannel onConfirm(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayConfirm',
        onMessageReceived: (JavascriptMessage message) {
          if (this.widget.onConfirm != null) {
            bool goTransactionConfirm = this.widget.onConfirm!(message.message);
            if (goTransactionConfirm) {
              transactionConfirm(message.message);
            }
          }
        });
  }

  JavascriptChannel onDone(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayDone',
        onMessageReceived: (JavascriptMessage message) {
          if (this.widget.onDone != null) this.widget.onDone!(message.message);
        });
  }

  // JavascriptChannel onEasyCancel(BuildContext context) {
  //   return JavascriptChannel(
  //       name: 'BootpayEasyCancel',
  //       onMessageReceived: (JavascriptMessage message) {
  //         if (this.widget.onCancel != null) this.widget.onCancel!(message.message);
  //       });
  // }

  JavascriptChannel onEasyError(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayEasyError',
        onMessageReceived: (JavascriptMessage message) {
          if (this.widget.onError != null) this.widget.onError!(message.message);
        });
  }

  JavascriptChannel onEasySuccess(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayEasySuccess',
        onMessageReceived: (JavascriptMessage message) {
          print('BootpayEasySuccess: ${c.requestType}, ${message.message}');

          NextJob job = NextJob();
          if([BioConstants.REQUEST_PASSWORD_TOKEN,
            BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD,
            BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD,
            BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY
          ].contains(c.requestType.value)) {
            job.type = c.requestType.value;
            job.token = message.message.replaceAll("\"", "");
            if (widget.onNextJob != null) widget.onNextJob!(job);
          } else if(c.requestType.value == BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY) {
            BioMetric bioMetric = BioMetric.fromJson(json.decode(message.message));

            NextJob job = NextJob();
            job.type = c.requestType.value;
            job.nextType = BioConstants.NEXT_JOB_GET_WALLET_LIST;
            job.biometricSecretKey = bioMetric.biometricSecretKey ?? '';
            job.biometricDeviceUuid = bioMetric.biometricDeviceUuid ?? '';
            if (widget.onNextJob != null) widget.onNextJob!(job);
          } else {
            if (widget.onDone != null) widget.onDone!(message.message);
          }
        });
  }
}
