
import 'dart:async';
import 'dart:convert';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay_bio/bio_container.dart';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:bootpay_webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/bio_config.dart';
import '../constants/bio_constants.dart';
import '../controller/bio_debounce_close_controller.dart';
import '../models/wallet/bio_metric.dart';
import '../models/wallet/next_job.dart';
import '../webview/bio_webview.dart';

class ApiWebviewProvider {

  // final BioDebounceCloseController closeController = Get.put(BioDebounceCloseController());

  BioContainer? container;
  BioWebView? webView;
  BioPayload? payload;
  int requestType = 0;

  //api callback
  BootpayDefaultCallback? onCancel;
  BootpayDefaultCallback? onError;
  BootpayCloseCallback? onClose;
  BootpayDefaultCallback? onIssued;
  BootpayConfirmCallback? onConfirm;
  BootpayAsyncConfirmCallback? onConfirmAsync;
  BootpayDefaultCallback? onDone;
  BootpayNextJobCallback? onNextJob;

  ApiWebviewProvider(
      this.container,
      this.webView,
      this.onCancel,
      this.onError,
      this.onClose,
      this.onIssued,
      this.onConfirm,
      this.onConfirmAsync,
      this.onDone,
      this.onNextJob
      );

  void initWebViewCallback(
      WebViewCallback onWebViewCancel,
      WebViewCallback onWebViewError,
      WebViewCallback onWebViewClose,
      WebViewCallback onWebViewIssued,
      WebViewCallback onWebViewConfirm,
      WebViewCallback onWebViewDone,
      WebViewCallback onWebViewRedirect,
      WebViewCallback onWebViewEasySuccess,
      WebViewCallback onWebViewEasyError,
      ) {
    if(webView != null) {
      webView?.onWebViewCancel = onWebViewCancel;
      webView?.onWebViewError = onWebViewError;
      webView?.onWebViewClose = onWebViewClose;
      webView?.onWebViewIssued = onWebViewIssued;
      webView?.onWebViewConfirm = onWebViewConfirm;
      webView?.onWebViewDone = onWebViewDone;
      webView?.onWebViewRedirect = onWebViewRedirect;
      webView?.onWebViewEasySuccess = onWebViewEasySuccess;
      webView?.onWebViewEasyError = onWebViewEasyError;
    }
  }

  Future<void> requestPasswordForPay(BioPayload payload, int type, {bool? doWorkNow = true}) async {
    this.payload = payload;
    requestType = type;
    String script = await BioConstants.getJSPasswordPay(payload);
    if(doWorkNow == true) {
      webView?.controller?.future.then((controller) {
        controller.evaluateJavascript(
            callJavascriptAsync(script)
        );
      });
    } else {
      webView?.startScript = script;
    }

  }

  void removePaymentWindow() {
    webView?.controller?.future.then((controller) {
      controller.evaluateJavascript(
          "Bootpay.removePaymentWindow();"
      );
    });
  }


  void updateProgressShow(bool isShow) {
    if(webView?.onProgressShow != null) {
      webView?.onProgressShow!(isShow);
    }
  }

  void addNewCard(BioPayload payload, int type, {bool? doWorkNow = true}) {
    this.payload = payload;
    requestType = type;
    String script = BioConstants.getJSAddCard(payload);
    updateProgressShow(true);
    if(doWorkNow == true) {
      webView?.controller?.future.then((controller) {
        controller.evaluateJavascript(
            callJavascriptAsync(script)
        );
      });
    } else {
      webView?.startScript = script;
    }
  }

  void requestTotalPay(BioPayload payload, int type, {bool? doWorkNow = true}) {
    this.payload = payload;
    requestType = type;
    String script = BioConstants.getJSTotalPay(payload);

    BootpayPrint("requestTotalPay : $script");

    updateProgressShow(true);
    if(doWorkNow == true) {
      webView?.controller?.future.then((controller) {
        controller.evaluateJavascript(
            callJavascriptAsync(script)
        );
      });
    } else {
      webView?.startScript = script;
    }
  }

  Future<void> requestAddBioData(BioPayload payload, {int? type, bool? doWorkNow = true}) async {
    this.payload = payload;
    if(type != null) {
      requestType = type;
    }
    String script = await BioConstants.getJSBiometricAuthenticate(payload);
    BootpayPrint("requestAddBioData : $script, $type");

    updateProgressShow(true);
    if(doWorkNow == true) {
      webView?.controller?.future.then((controller) {
        controller.evaluateJavascript(
            callJavascriptAsync(script)
        );
      });
    } else {
      webView?.startScript = script;
    }
  }

  Future<void> requestBioForPay(BioPayload payload, String otp, int type, {String? cardQuota, bool? doWorkNow = true}) async {
    this.payload = payload;
    requestType = type;
    String script = await BioConstants.getJSBioOTPPay(payload, otp, cardQuota ?? "0");

    BootpayPrint("requestBioForPay : $script");

    updateProgressShow(true);
    if(doWorkNow == true) {
      webView?.controller?.future.then((controller) {
        controller.evaluateJavascript(
            callJavascriptAsync(script)
        );
      });
    } else {
      webView?.startScript = script;

    }
  }

  Future<void> requestPasswordToken(BioPayload payload, {int? type, bool? doWorkNow = true}) async {
    this.payload = payload;
    if(type != null) {
      requestType = type;
    }

    String script = BioConstants.getJSPasswordToken(payload.userToken ?? '');

    updateProgressShow(true);

    if(doWorkNow == true) {
      webView?.controller?.future.then((controller) {
        controller.evaluateJavascript(
            callJavascriptAsync(script)
        );
      });
    } else {
      webView?.startScript = script;
    }
  }


  Future<void> requestDeleteCard(BioPayload payload, int type, {bool? doWorkNow = true}) async {
    this.payload = payload;
    requestType = type;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String passwordToken =  prefs.getString('password_token') ?? '';
    payload.token = passwordToken;

    String script = await BioConstants.getJSDestroyWallet(payload);
    updateProgressShow(true);
    if(doWorkNow == true) {
      webView?.controller?.future.then((controller) {
        controller.evaluateJavascript(
            callJavascriptAsync(script)
        );
      });
    } else {
      webView?.startScript = script;
    }
  }


  Future<String> getBootpayJS(BioPayload payload, {String? otp, String? quota}) async {
    this.payload = payload;

    String script = "";
    if([BioConstants.REQUEST_PASSWORD_TOKEN,
      BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD,
      BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY,
      BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY,
      BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD].contains(requestType)) {
      // contro
      script = BioConstants.getJSPasswordToken(payload.userToken ?? '');

    } else if(BioConstants.REQUEST_PASSWORD_FOR_PAY == requestType) {
      script = await BioConstants.getJSPasswordPay(payload);
    } else if(BioConstants.REQUEST_ADD_CARD == requestType) {
      script = BioConstants.getJSAddCard(payload);
    } else if(BioConstants.REQUEST_BIO_FOR_PAY == requestType) {
      script = BioConstants.getJSBioOTPPay(payload, '$otp', '$quota');
    } else if([BioConstants.REQUEST_ADD_BIOMETRIC,
      BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY].contains(requestType)) {
      script = await BioConstants.getJSBiometricAuthenticate(payload);
    } else if(BioConstants.REQUEST_TOTAL_PAY == requestType) {
      script = BioConstants.getJSTotalPay(payload);
    } else if(BioConstants.REQUEST_DELETE_CARD == requestType) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String passwordToken =  prefs.getString('password_token') ?? '';
      payload.token = passwordToken;

      script = BioConstants.getJSDestroyWallet(payload);
    }

    return "setTimeout(function() {" + script + "}, 50);";
  }
}

extension InnerFunction on ApiWebviewProvider {

  void transactionConfirm() {

    String script = "Bootpay.confirm()" +
        ".then( function (data) {" +
        _confirm() +
        _issued() +
        _done() +
        "}, function (data) {" +
        _error() +
        _cancel() +
        "});";

    BootpayPrint("transactionConfirm : $script");

    webView?.controller?.future.then((controller) {
      controller.evaluateJavascript(
          "setTimeout(function() { $script }, 30);"
      );
    });
  }


  String callJavascriptAsync(String script) {
    return "setTimeout(function() { $script }, 30);";
  }
}


extension InnerScript on ApiWebviewProvider {
  String _confirm() {
    return "if (data.event === 'confirm') { if (window.BootpayConfirm && window.BootpayConfirm.postMessage) { BootpayConfirm.postMessage(JSON.stringify(data)); } }";
  }


  String _done() {
    return "else if (data.event === 'done') { if (window.BootpayDone && window.BootpayDone.postMessage) { BootpayDone.postMessage(JSON.stringify(data)); } }";
  }


  String _issued() {
    return "else if (data.event === 'issued') { if (window.BootpayIssued && window.BootpayIssued.postMessage) { BootpayIssued.postMessage(JSON.stringify(data)); } }";
  }

  String _error() {
    return "if (data.event === 'error') { if (window.BootpayError && window.BootpayError.postMessage) { BootpayError.postMessage(JSON.stringify(data)); } }";
  }

  String _cancel() {
    return "else if (data.event === 'cancel') { if (window.BootpayCancel && window.BootpayCancel.postMessage) { BootpayCancel.postMessage(JSON.stringify(data)); } }";
  }

  String _close() {
    return "document.addEventListener('bootpayclose', function (e) { if (window.BootpayClose && window.BootpayClose.postMessage) { BootpayClose.postMessage('결제창이 닫혔습니다'); } });";
  }
}
