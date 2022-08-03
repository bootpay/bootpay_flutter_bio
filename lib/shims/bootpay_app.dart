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
import '../controller/bio_debounce_close_controller.dart';
import '../models/bio_theme_data.dart';
import '../password_container.dart';

class BootpayPlatform extends BootpayBioApi {
  bool isShowModal = false;
  BioContainer? bioContainer;
  final BioDebounceCloseController closeController = Get.put(BioDebounceCloseController());
  // final BioController c = Get.put(BioController());

  @override
  void requestPaymentBio(
      {Key? key,
      BuildContext? context,
      BioPayload? payload,
        BioThemeData? themeData,
      bool? showCloseButton,
      Widget? closeButton,
      BootpayDefaultCallback? onCancel,
      BootpayDefaultCallback? onError,
      BootpayCloseCallback? onClose,
      // BootpayCloseCallback? onCloseHardware,
      BootpayDefaultCallback? onIssued,
      BootpayConfirmCallback? onConfirm,
      BootpayDefaultCallback? onDone}) {

    if (context == null) return;

    // c.isPasswordMode = false;

    showModalBioContainer(key, payload, themeData, showCloseButton, closeButton, onCancel,
        onError, onClose, onIssued, onConfirm, onDone, context, false);
  }

  void showModalBioContainer(
      Key? key,
      BioPayload? payload,
      BioThemeData? themeData,
      bool? showCloseButton,
      Widget? closeButton,
      BootpayDefaultCallback? onCancel,
      BootpayDefaultCallback? onError,
      BootpayCloseCallback? onClose,
      // BootpayCloseCallback? onCloseHardware,
      BootpayDefaultCallback? onIssued,
      BootpayConfirmCallback? onConfirm,
      BootpayDefaultCallback? onDone,
      BuildContext context,
      bool passwordMode
      ) {
    bioContainer = BioContainer(
      key: key,
      payload: payload,
      themeData: themeData,
      showCloseButton: showCloseButton,
      closeButton: closeButton,
      onCancel: onCancel,
      onError: onError,
      onClose: onClose,
      // onCloseHardware: onCloseHardware,
      onIssued: onIssued,
      onConfirm: onConfirm,
      onDone: onDone,
      passwordMode: passwordMode
    );

    isShowModal = true;
    closeController.isBootpayShow = true;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // return SafeArea(child: bioContainer!);
        return bioContainer!;
      },
    ).whenComplete(() {
      isShowModal = false;
      print("whenComplete : $isShowModal");
      // print('Hey there, I\'m calling after hide bottomSheet');
    });
  }

  @override
  void requestPaymentPassword(
      {Key? key,
      BuildContext? context,
      BioPayload? payload,
      BioThemeData? themeData,
      bool? showCloseButton,
      Widget? closeButton,
      BootpayDefaultCallback? onCancel,
      BootpayDefaultCallback? onError,
      BootpayCloseCallback? onClose,
      // BootpayCloseCallback? onCloseHardware,
      BootpayDefaultCallback? onIssued,
      BootpayConfirmCallback? onConfirm,
      BootpayDefaultCallback? onDone}) {
    // TODO: implement requestPaymentPassword


    if (context == null) return;

    // c.isPasswordMode = true;


    showModalBioContainer(key, payload, themeData, showCloseButton, closeButton, onCancel,
        onError, onClose, onIssued, onConfirm, onDone, context, true);

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
    if(isShowModal == true) {
      Navigator.of(context).pop();
      isShowModal = false; //webview에서 실행되는 쓰레드의 경우 중단되는 버그가 있어서 수행 후 상태변경
    }
  }

  @override
  void transactionConfirm() {
    // if(webView != null) webView!.transactionConfirm(data);
    bioContainer?.transactionConfirm();
    // passwordContainer?.transactionConfirm();
  }
}
