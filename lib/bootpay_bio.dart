import 'package:bootpay/bootpay.dart';
import 'package:flutter/material.dart';

import 'bootpay_bio_api.dart';
import 'models/bio_payload.dart';
import 'shims/bootpay_platform.dart';

// typedef void BootpayDefaultCallback(String data);
// typedef bool BootpayConfirmCallback(String data);
// typedef void BootpayCloseCallback();

class BootpayBio extends BootpayBioApi{
  static final BootpayBio _bootpay = BootpayBio._internal();
  factory BootpayBio() {
    return _bootpay;
  }

  late BootpayPlatform _platform;

  BootpayBio._internal() {
    _platform = BootpayPlatform();
  }

  @override
  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId) {
    return _platform.applicationId(webApplicationId, androidApplicationId, iosApplicationId);
  }

  @override
  void requestPaymentBio(
      {Key? key,
        BuildContext? context,
        BioPayload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayCloseCallback? onCloseHardware,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone}) {

    _platform.requestPaymentBio(
        context: context,
        payload: payload,
        showCloseButton: showCloseButton,
        closeButton: closeButton,
        onCancel: onCancel,
        onError: onError,
        onClose: onClose,
        onIssued: onIssued,
        onCloseHardware: onCloseHardware,
        onConfirm: onConfirm,
        onDone: onDone
    );
  }


  @override
  void requestPaymentPassword(
      {Key? key,
        BuildContext? context,
        BioPayload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayCloseCallback? onCloseHardware,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone}) {

    _platform.requestPaymentPassword(
        context: context,
        payload: payload,
        showCloseButton: showCloseButton,
        closeButton: closeButton,
        onCancel: onCancel,
        onError: onError,
        onClose: onClose,
        onIssued: onIssued,
        onCloseHardware: onCloseHardware,
        onConfirm: onConfirm,
        onDone: onDone
    );
  }

  @override
  void transactionConfirm() {
    _platform.transactionConfirm();
  }

  @override
  void removePaymentWindow(BuildContext context) {
    _platform.removePaymentWindow(context);
  }

  @override
  void dismiss(BuildContext context) {
    _platform.dismiss(context);
  }
}