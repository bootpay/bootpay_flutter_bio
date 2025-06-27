//package controller;//package controller;

import 'dart:async';

import 'package:bootpay/bootpay.dart';
import 'package:get/get.dart';

import '../config/bio_config.dart';


class BioDebounceCloseController extends GetxController {
  Timer? _debounce;
  bool isBootpayShow = false;
  bool _isClosing = false; // 중복 호출 방지 플래그

  void bootpayClose(BootpayCloseCallback? onClose) { 
    if (_isClosing) {
      BootpayPrint("bootpayClose already in progress - ignored");
      return;
    }
    
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {

      if(isBootpayShow == false || _isClosing) return;
      
      _isClosing = true;
      BootpayPrint("bootpayClose call");
      if (onClose != null) onClose();
      isBootpayShow = false;
      
      // 약간의 딜레이 후 플래그 리셋
      Timer(const Duration(milliseconds: 500), () {
        _isClosing = false;
      });
    });
  }
  
  void setBootpayShow(bool show) {
    isBootpayShow = show;
    if (!show) {
      _isClosing = false; // 다시 보여질 때 플래그 리셋
    }
  }
}
