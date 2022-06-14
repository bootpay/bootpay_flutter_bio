import 'dart:io';
import 'package:bootpay/bootpay.dart';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:bootpay_bio/bio_container.dart';
import 'package:bootpay_bio/webview/bootpay_bio_webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bootpay_bio.dart';
import '../bootpay_bio_api.dart';
import '../controller/bio_controller.dart';
import '../password_container.dart';

class BootpayPlatform extends BootpayBioApi {
  BioContainer? bioContainer;
  // final BioController c = Get.put(BioController());

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

    if (context == null) return;

    // c.isPasswordMode = false;

    showModalBioContainer(key, payload, showCloseButton, closeButton, onCancel,
        onError, onClose, onCloseHardware, onIssued, onConfirm, onDone, context, false);
  }

  void showModalBioContainer(
      Key? key,
      BioPayload? payload,
      bool? showCloseButton,
      Widget? closeButton,
      BootpayDefaultCallback? onCancel,
      BootpayDefaultCallback? onError,
      BootpayCloseCallback? onClose,
      BootpayCloseCallback? onCloseHardware,
      BootpayDefaultCallback? onIssued,
      BootpayConfirmCallback? onConfirm,
      BootpayDefaultCallback? onDone,
      BuildContext context,
      bool passwordMode
      ) {
    bioContainer = BioContainer(
      key: key,
      payload: payload,
      showCloseButton: showCloseButton,
      closeButton: closeButton,
      onCancel: onCancel,
      onError: onError,
      onClose: onClose,
      onCloseHardware: onCloseHardware,
      onIssued: onIssued,
      onConfirm: onConfirm,
      onDone: onDone,
      passwordMode: passwordMode
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(child: bioContainer!);
      },
    ).whenComplete(() {
      // print('Hey there, I\'m calling after hide bottomSheet');
    });
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
    // TODO: implement requestPaymentPassword


    if (context == null) return;

    // c.isPasswordMode = true;


    showModalBioContainer(key, payload, showCloseButton, closeButton, onCancel,
        onError, onClose, onCloseHardware, onIssued, onConfirm, onDone, context, true);

    // passwordContainer = PasswordContainer(
    //   key: key,
    //   payload: payload,
    //   showCloseButton: showCloseButton,
    //   closeButton: closeButton,
    //   onCancel: onCancel,
    //   onError: onError,
    //   onClose: onClose,
    //   onCloseHardware: onCloseHardware,
    //   onReady: onReady,
    //   onConfirm: onConfirm,
    //   onDone: onDone,
    // );
    //
    // showModalBottomSheet<void>(
    //   context: context,
    //   isScrollControlled: true,
    //   builder: (BuildContext context) {
    //     return SafeArea(child: passwordContainer!);
    //   },
    // ).whenComplete(() {
    //   // print('Hey there, I\'m calling after hide bottomSheet');
    // });
  }

  @override
  String applicationId(String webApplicationId, String androidApplicationId,
      String iosApplicationId) {
    if (Platform.isIOS)
      return iosApplicationId;
    else
      return androidApplicationId;
  }

  @override
  void removePaymentWindow(BuildContext context) {
    dismiss(context);
  }

  @override
  void dismiss(BuildContext context) {
    if (bioContainer != null) {
      Navigator.of(context).pop();
      bioContainer = null;
    }
    // else if (passwordContainer != null) {
    //   Navigator.of(context).pop();
    //   passwordContainer = null;
    // }
  }

  @override
  void transactionConfirm() {
    // if(webView != null) webView!.transactionConfirm(data);
    bioContainer?.transactionConfirm();
    // passwordContainer?.transactionConfirm();
  }
}
