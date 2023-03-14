import 'package:bootpay/bootpay.dart';
import 'package:bootpay_bio/config/bio_config.dart';
import 'package:bootpay_bio/models/bio_theme_data.dart';
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
        Widget? bioCardMoreIcon,
        BioThemeData? themeData,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        // BootpayCloseCallback? onCloseHardware,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone}) {

    _platform.requestPaymentBio(
        context: context,
        payload: payload,
        themeData: themeData,
        showCloseButton: showCloseButton,
        closeButton: closeButton,
        bioCardMoreIcon: bioCardMoreIcon,
        onCancel: onCancel,
        onError: onError,
        onClose: onClose,
        onIssued: onIssued,
        // onCloseHardware: onCloseHardware,
        onConfirm: onConfirm,
        onConfirmAsync: onConfirmAsync,
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
        Widget? bioCardMoreIcon,
        BioThemeData? themeData,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        // BootpayCloseCallback? onCloseHardware,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone}) {

    _platform.requestPaymentPassword(
        context: context,
        payload: payload,
        themeData: themeData,
        showCloseButton: showCloseButton,
        closeButton: closeButton,
        bioCardMoreIcon: bioCardMoreIcon,
        onCancel: onCancel,
        onError: onError,
        onClose: onClose,
        onIssued: onIssued,
        // onCloseHardware: onCloseHardware,
        onConfirm: onConfirm,
        onConfirmAsync: onConfirmAsync,
        onDone: onDone
    );
  }


  @override
  void requestEditPayment({
    Key? key,
    BuildContext? context,
    BioThemeData? themeData,
    String? userToken,
    BootpayDefaultCallback? onCancel,
    BootpayDefaultCallback? onError,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onDone}) {
    // TODO: implement requestEditPayment

    _platform.requestEditPayment(
      key: key,
      context: context,
      themeData: themeData,
      userToken: userToken,
      onCancel: onCancel,
      onError: onError,
      onClose: onClose,
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