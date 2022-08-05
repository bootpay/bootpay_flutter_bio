//package controller;//package controller;

import 'dart:async';

import 'package:bootpay/bootpay.dart';
import 'package:get/get.dart';

import '../config/bio_config.dart';


class BioDebounceCloseController extends GetxController {
  Timer? _debounce;
  bool isBootpayShow = false;

  void bootpayClose(BootpayCloseCallback? onClose) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {

      if(isBootpayShow == false) return;
      // BootpayPrint("bootpayClose call");
      if (onClose != null) onClose();
      isBootpayShow = false;
      // do something with query
    });
  }
}
