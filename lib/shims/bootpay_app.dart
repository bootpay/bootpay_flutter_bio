
import 'dart:io';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:bootpay_bio/webview/bio_container.dart';
import 'package:bootpay_bio/webview/bootpay_bio_webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../bootpay_bio.dart';
import '../bootpay_bio_api.dart';


class BootpayPlatform extends BootpayBioApi{

  BootpayBioWebView? webView;

  @override
  void request(
      {
        Key? key,
        BuildContext? context,
        BioPayload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayCloseCallback? onCloseHardware,
        BootpayDefaultCallback? onReady,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone
      }) {


    // webView = BootpayBioWebView(
    //   payload: payload,
    //   showCloseButton: showCloseButton,
    //   key: key,
    //   closeButton: closeButton,
    //   onCancel: onCancel,
    //   onError: onError,
    //   onClose: onClose,
    //   onCloseHardware: onCloseHardware,
    //   onReady: onReady,
    //   onConfirm: onConfirm,
    //   onDone: onDone,
    // );

    if(context == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
            child: BioContainer(
              key: key,
              payload: payload,
              showCloseButton: showCloseButton,
              closeButton: closeButton,
              onCancel: onCancel,
              onError: onError,
              onClose: onClose,
              onCloseHardware: onCloseHardware,
              onReady: onReady,
              onConfirm: onConfirm,
              onDone: onDone,
            )
        );
      },
    ).whenComplete(() {
      print('Hey there, I\'m calling after hide bottomSheet');
    });
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => BioRouter(webView, payload)),
    // );
  }

  @override
  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId) {
    if(Platform.isIOS) return iosApplicationId;
    else return androidApplicationId;
  }


  @override
  void removePaymentWindow(BuildContext context) {
    if(webView != null) {
      // webView!.removePaymentWindow();
      Navigator.of(context).pop();
      webView = null;
    }
  }

  @override
  void dismiss(BuildContext context) {
    if(webView != null) {
      Navigator.of(context).pop();
      webView = null;
    }
  }

  @override
  void transactionConfirm(String data) {
    if(webView != null) webView!.transactionConfirm(data);
  }
}