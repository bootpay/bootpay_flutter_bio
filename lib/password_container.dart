import 'dart:async';
import 'package:bootpay/bootpay.dart';
import 'package:bootpay_bio/constants/bio_constants.dart';
import 'package:bootpay_bio/constants/card_code.dart';
import 'package:bootpay_bio/controller/bio_controller.dart';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:bootpay_bio/models/wallet/next_job.dart';
import 'package:bootpay_bio/models/wallet/wallet_data.dart';
import 'package:bootpay_bio/webview/bootpay_bio_webview.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import 'bootpay_bio.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:fluttertoast/fluttertoast.dart';


import 'package:otp/otp.dart';

import 'config/bio_config.dart';


enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class PasswordContainer extends StatefulWidget {
  Key? key;
  BootpayBioWebView? webView;
  BioPayload? payload;
  bool? showCloseButton;

  Widget? closeButton;
  BootpayDefaultCallback? onCancel;
  BootpayDefaultCallback? onError;
  BootpayCloseCallback? onClose;
  BootpayCloseCallback? onCloseHardware;
  BootpayDefaultCallback? onIssued;
  BootpayConfirmCallback? onConfirm;
  BootpayDefaultCallback? onDone;


  PasswordContainer({
      this.key,
      this.payload,
      this.showCloseButton,
      this.closeButton,
      this.onCancel,
      this.onError,
      this.onClose,
      this.onCloseHardware,
      this.onIssued,
      this.onConfirm,
      this.onDone}); // BioContainer(this.webView, this.payload);

  @override
  PasswordContainerState createState() => PasswordContainerState();

  transactionConfirm() {
    webView?.transactionConfirm();
  }
}

class PasswordContainerState extends State<PasswordContainer> {
  DateTime? currentBackPressTime = DateTime.now();


  final BioController c = Get.put(BioController());

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    // c.initValues();
    // c.getWalletList(widget.payload?.userToken ?? "");
    createWebView();

    c.requestType.value = BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY;
  }

  createWebView() {
    widget.webView = BootpayBioWebView(
      payload: widget.payload,
      showCloseButton: widget.showCloseButton,
      key: widget.key,
      closeButton: widget.closeButton,
      onCancel: widget.onCancel,
      onError: widget.onError,
      onClose: widget.onClose,
      onCloseHardware: widget.onCloseHardware,
      onIssued: widget.onIssued,
      onConfirm: widget.onConfirm,
      onDone: widget.onDone,
      onNextJob: onNextJob,
    );
  }


  setPasswordToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("password_token", token);
  }

  onNextJob(NextJob data) async {
    BootpayPrint("onNextJob: ${data.toJson()}");

    if(data.initToken) {
      setPasswordToken("");
      widget.payload?.token = "";
    } else if(data.token.isNotEmpty) {
      setPasswordToken(data.token.replaceAll("\"", ""));
      widget.payload?.token = data.token;
    }

    if(data.biometricDeviceUuid.isNotEmpty && data.biometricSecretKey.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("biometric_device_uuid", data.biometricDeviceUuid);
      prefs.setString("biometric_secret_key", data.biometricSecretKey);
      prefs.setInt("server_unixtime", data.serverUnixtime);
    }

    requestPasswordForPay();
  }

  Future<bool> isAblePasswordToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String passwordToken =  prefs.getString('password_token') ?? '';
    return passwordToken.isNotEmpty;
  }

  requestPasswordForPay() async {
    BootpayPrint("requestPasswordForPay call");

    // showWebView();
    if(!await isAblePasswordToken()) {
      BootpayPrint(2);
      c.requestType.value = BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY;
      widget.webView?.requestPasswordToken();
      // widget.webView?.get
      // widget.webView?.callJavascriptAsync(script)
      // showWebView();
      return;
    }

    c.requestType.value = BioConstants.REQUEST_PASSWORD_FOR_PAY;
    widget.webView?.requestPasswordForPay();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return WillPopScope(

      child: SafeArea(
        child: Container(
            child: widget.webView!
        ),
      ),
      onWillPop: () async {
        // DateTime now = DateTime.now();
        // if (now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
        //   currentBackPressTime = now;
        //   if(widget.webView?.onCloseHardware != null) widget.webView?.onCloseHardware!();
        //   Fluttertoast.showToast(msg: "\'뒤로\' 버튼을 한번 더 눌러주세요.");
        //   return Future.value(false);
        // }
        // return Future.value(true);
        if(widget.webView?.onCloseHardware != null) widget.webView?.onCloseHardware!();
        return Future.value(true);
      },
    );
  }

}