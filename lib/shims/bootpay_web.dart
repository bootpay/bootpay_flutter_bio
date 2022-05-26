
// @JS()
// library bootpay_api;
//
// import 'dart:convert';
//
// import 'package:bootpay/api/bootpay_analytics.dart';
// import 'package:bootpay/model/stat_item.dart';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:flutter/material.dart';

import '../bootpay_bio.dart';
import '../bootpay_bio_api.dart';


// import 'package:js/js.dart';
// import 'package:flutter/material.dart';
// import '../bootpay.dart';
// import '../bootpay_api.dart';
// import '../model/payload.dart';

// @JS()
// external String _request(String payload);
// @JS()
// external void _removePaymentWindow();
// @JS()
// external void _transactionConfirm(String data);
//
// @JS()
// external void BootpayClose();
// @JS('BootpayClose')
// external set _BootpayClose(void Function() f);
// @JS()
// external void BootpayCancel(String data);
// @JS('BootpayCancel')
// external set _BootpayCancel(void Function(String) f);
// @JS()
// external void BootpayDone(String data);
// @JS('BootpayDone')
// external set _BootpayDone(void Function(String) f);
// @JS()
// external void BootpayReady(String data);
// @JS('BootpayReady')
// external set _BootpayReady(void Function(String) f);
// @JS()
// external bool BootpayConfirm(String data);
// @JS('BootpayConfirm')
// external set _BootpayConfirm(bool Function(String) f);
// @JS()
// external void BootpayError(String data);
// @JS('BootpayError')
// external set _BootpayError(void Function(String) f);

class BootpayPlatform extends BootpayBioApi{
  BootpayDefaultCallback? _callbackCancel;
  BootpayDefaultCallback? _callbackError;
  BootpayCloseCallback? _callbackClose;
  BootpayCloseCallback? _callbackCloseHardware;
  BootpayDefaultCallback? _callbackReady;
  BootpayConfirmCallback? _callbackConfirm;
  BootpayDefaultCallback? _callbackDone;

  BootpayPlatform() {
  }


  @override
  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId) {
    return webApplicationId;
  }

  @override
  void requestPaymentBio(
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
    throw UnimplementedError('bootpayBio web not support yet');
  }

  @override
  void requestPaymentPassword(
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
    throw UnimplementedError('requestPaymentPassword web not support yet');
  }

  @override
  void removePaymentWindow(BuildContext context) {
    throw UnimplementedError('bootpayBio web not support yet');
  }

  @override
  void transactionConfirm() {
    throw UnimplementedError('bootpayBio web not support yet');
  }

  void dismiss(BuildContext context) {
    throw UnimplementedError('bootpayBio web not support yet');
  }

  void onClose() {
    if(this._callbackClose != null) this._callbackClose!();
  }
  void onCancel(String data) {
    if(this._callbackCancel != null) this._callbackCancel!(data);
  }
  void onReady(String data) {
    if(this._callbackReady != null) this._callbackReady!(data);
  }
  bool onConfirm(String data) {
    if(this._callbackConfirm != null) return this._callbackConfirm!(data);
    return false;
  }
  void onDone(String data) {
    if(this._callbackDone != null) this._callbackDone!(data);
  }
  void onError(String data) {
    if(this._callbackError != null) this._callbackError!(data);
  }

  // @override
  // void requestPaymentPassword({Key? key, BuildContext? context, BioPayload? payload, bool? showCloseButton, Widget? closeButton, BootpayDefaultCallback? onCancel, BootpayDefaultCallback? onError, BootpayCloseCallback? onClose, BootpayCloseCallback? onCloseHardware, BootpayDefaultCallback? onReady, BootpayConfirmCallback? onConfirm, BootpayDefaultCallback? onDone}) {
  //   // TODO: implement requestPaymentPassword
  // }
}