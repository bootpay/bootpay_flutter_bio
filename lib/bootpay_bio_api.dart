
import 'package:flutter/widgets.dart';

import 'bootpay_bio.dart';
import 'models/bio_payload.dart';


abstract class BootpayBioApi {


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
        BootpayDefaultCallback? onReady,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone
      });

  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId);
  void transactionConfirm(String data);
  void removePaymentWindow(BuildContext context);
  void dismiss(BuildContext context);
}
