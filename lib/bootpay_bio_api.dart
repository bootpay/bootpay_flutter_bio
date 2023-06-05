
import 'package:bootpay/bootpay.dart';
import 'package:flutter/widgets.dart';

import 'models/bio_payload.dart';


abstract class BootpayBioApi {


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
        // BootpayCloseCallback? onCloseHardware,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone
      });


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
        // BootpayCloseCallback? onCloseHardware,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone
      });

  void requestPaymentPasswordNoBilling( {
    Key? key,
    BuildContext? context,
    BioPayload? payload,
    bool? showCloseButton,
    Widget? closeButton,
    BootpayDefaultCallback? onCancel,
    BootpayDefaultCallback? onError,
    BootpayCloseCallback? onClose,
    // BootpayCloseCallback? onCloseHardware,
    BootpayDefaultCallback? onIssued,
    BootpayConfirmCallback? onConfirm,
    BootpayDefaultCallback? onDone
  });

  void requestEditPayment({
        Key? key,
        BuildContext? context,
        String? userToken,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayDefaultCallback? onDone
      });

  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId);
  void transactionConfirm();
  void removePaymentWindow(BuildContext context);
  void dismiss(BuildContext context);
}
