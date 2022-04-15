import 'dart:convert';
import 'dart:io';

import 'package:bootpay/user_info.dart';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:bootpay_bio/models/boot_extra.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BioConstants {
  // static const int REQUEST_TYPE_NONE = -1;
  // static const int REQUEST_TYPE_VERIFY_PASSWORD = 1; // 생체인식 활성화용도
  // static const int REQUEST_TYPE_VERIFY_PASSWORD_FOR_PAY = 2; //비밀번호로 결제 용도
  // static const int REQUEST_TYPE_REGISTER_CARD = 3; //카드 생성
  // static const int REQUEST_TYPE_PASSWORD_CHANGE = 4; //카드 삭제
  // static const int REQUEST_TYPE_ENABLE_DEVICE = 5; //해당 기기 활성화
  // static const int REQUEST_TYPE_OTHER = 6; //다른 결제수단
  // static const int REQUEST_TYPE_PASSWORD_PAY = 7; //생체인증 이용 불가시 비밀번호로 간편결제
  // static const int REQUEST_TYPE_RESULT_FAILED = -100; //생체인증 이용 불가시 비밀번호로 간편결제

  static const bool DEBUG = true;
  static const bool PRINT_ABLE = true;

  static const int REQUEST_TYPE_NONE = -1;
  static const int REQUEST_PASSWORD_TOKEN = 10; //최초요청시 - 비밀번호 설정하기
  static const int REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD = 11; //카드 등록 전 토큰이 없을 때
  static const int REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY = 12; //생체인증 결제 전 토큰이 없을 때
  static const int REQUEST_BIOAUTH_FOR_BIO_FOR_PAY = 13; //생체인증 결제 전 기기등록이 안 됬을때

  static const int REQUEST_ADD_BIOMETRIC = 15; //생체인식 정보등록
  static const int REQUEST_ADD_BIOMETRIC_FOR_PAY = 16; //결제 전 생체인식 정보등록

  static const int REQUEST_ADD_BIOMETRIC_NONE = 17; ////생체인식 정보등록 수행 후 NONE 처리 (이벤트가 재귀함수 호출되지 않도록)
  static const int REQUEST_ADD_CARD = 20; //카드 등록

  static const int REQUEST_ADD_CARD_NONE = 21;  //카드 등록 수행 후 NONE 처리 (이벤트가 재귀함수 호출되지 않도록)
  static const int REQUEST_BIO_FOR_PAY = 30; //결제를 위해 생체인증 진행
  static const int REQUEST_PASSWORD_FOR_PAY = 40; //비밀번호로 결제 진행
  static const int REQUEST_TOTAL_PAY = 50; //통합결제

  static const int REQUEST_PASSWORD_TOKEN_DELETE_CARD = 60; //카드 삭제
  static const int REQUEST_DELETE_CARD = 61; //카드 삭제

  static const int NEXT_JOB_RETRY_PAY = 100;
  static const int NEXT_JOB_ADD_NEW_CARD = 101;
  static const int NEXT_JOB_ADD_DELETE_CARD = 102;
  static const int NEXT_JOB_GET_WALLET_LIST = 103;


  static Future<List<String>> getBootpayJSBeforeContentLoaded() async {
    List<String> result = [];
    result.add("document.addEventListener('bootpayclose', function (e) { BootpayClose.postMessage('결제창이 닫혔습니다'); });");
    if(BioConstants.DEBUG) {
      result.add("Bootpay.setEnvironmentMode('development', 'gosomi.bootpay.co.kr');");
      result.add("BootpaySDK.setEnvironmentMode('development', 'gosomi.bootpay.co.kr');");
    }
    result.add("Bootpay.setLogLevel(4);");
    if (Platform.isAndroid) {
      result.add("Bootpay.setDevice('ANDROID');");
      result.add("BootpaySDK.setDevice('ANDROID');");
    } else if (Platform.isIOS) {
      result.add("Bootpay.setDevice('IOS');");
      result.add("BootpaySDK.setDevice('IOS');");
    }
    result.add("BootpaySDK.setUUID('" + await UserInfo.getBootpayUUID() + "');");


    // result.add(await getAnalyticsData());
    // if (this.widget.payload?.extra?.quickPopup == 1 &&
    //     this.widget.payload?.extra?.popup == 1) {
    //
    //   result.add("setTimeout(function() {BootPay.startQuickPopup();}, 30);");
    //
    //   // result.add("(function() { " + "BootPay.startQuickPopup();" + " })();");
    //
    // }
    return result;
  }

  static String confirm() {
    var script = "if (window.BootpayConfirm && window.BootpayConfirm.postMessage) { BootpayConfirm.postMessage(JSON.stringify(data)); }";
    return  "if (data.event === 'confirm') { $script }";
  }

  static String done() {
    var script = "if (window.BootpayDone && window.BootpayDone.postMessage) { BootpayDone.postMessage(JSON.stringify(data)); }";
    return  "if (data.event === 'done') { $script }";
  }

  static String issued() {
    var script = "if (window.BootpayIssued && window.BootpayIssued.postMessage) { BootpayIssued.postMessage(JSON.stringify(data)); }";
    return  "if (data.event === 'issued') { $script }";
  }

  static String cancel() {
    var script = "if (window.BootpayCancel && window.BootpayCancel.postMessage) { BootpayCancel.postMessage(JSON.stringify(data)); }";
    // var script = "BootpayCancel.postMessage(JSON.stringify(data));";
    return  "if (data.event === 'cancel') { $script }";
  }


  static String easySuccess() {
    return "if (window.BootpayEasySuccess && window.BootpayEasySuccess.postMessage) { BootpayEasySuccess.postMessage(JSON.stringify(data)); }";
  }


  static String error() {
    var script = "if (window.BootpayError && window.BootpayError.postMessage) { BootpayError.postMessage(JSON.stringify(data)); }";
    // var script = "BootpayError.postMessage(JSON.stringify(data));";
    return "else { $script };";
  }


  static String easyError() {
    var script = "if (window.BootpayEasyError && window.BootpayEasyError.postMessage) { BootpayEasyError.postMessage(JSON.stringify(data)); }";
    // var script = "BootpayError.postMessage(JSON.stringify(data));";
    return "else { $script };";
  }


  static String getJSPasswordToken(BioPayload payload) {
    var token = payload.userToken ?? "";
    return "BootpaySDK.requestPasswordToken('" +
        token +
        "')" +
        ".then( function (data) {" +
        easySuccess() +
        "}, function (data) {" +
        cancel() +
        easyError() +
        "})";
  }

  static String getJSChangePassword(BioPayload payload) {
    var token = payload.userToken ?? "";
    return "BootpaySDK.requestChangePassword('" +
        token +
        "')" +
        ".then( function (data) {" +
        easySuccess() +
        "}, function (data) {" +
        cancel() +
        easyError() +
        "})";
  }

  static String getJSAddCard(BioPayload payload) {
    var token = payload.userToken ?? "";
    return "BootpaySDK.requestAddCard('" +
        token +
        "')" +
        ".then( function (data) {" +
        easySuccess() +
        "}, function (data) {" +
        cancel() +
        easyError() +
        "})";
  }


  static String getJSBioOTPPay(BioPayload payload, String otp, String cardQuota) {
    // var token = payload.userToken ?? "";
    payload.authenticateType = "otp";
    payload.token = otp;
    // if(payload.price! >= 50000) {
    //   payload.extra ??= BootExtra();
    //   payload.extra?.cardQuota = cardQuota;
    // }
    payload.extra ??= BootExtra();
    payload.extra?.cardQuota = cardQuota;

    return "BootpaySDK.requestWalletPayment(" +
        payload.toString() +
        ")" +
        ".then( function (data) {" +
        easySuccess() +
        "}, function (data) {" +
        cancel() +
        easyError() +
        "})";
  }


  static Future<String> getJSBiometricAuthenticate(BioPayload payload) async {
    String? token = payload.token;
    if(token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString("password_token");
    }
    String os = "";
    if(Platform.isAndroid) {
      os = "android";
    } else if(Platform.isIOS) {
      os = "ios";
    }

    var otpPayload = {
      "userToken": payload.userToken,
      "os": os,
      "token": token
    };

    return "BootpaySDK.createBiometricAuthenticate(" +
        json.encode(otpPayload) +
        ")" +
        ".then( function (data) {" +
        easySuccess() +
        "}, function (data) {" +
        cancel() +
        easyError() +
        "})";
  }


  static String getJSTotalPay(BioPayload payload) {
    // var otpPayload = {
    //   "userToken": payload.userToken,
    //   "os": "android",
    //   "token": payload.token
    // };
    payload.userToken = "";

    return "Bootpay.requestPayment(" +
        payload.toString() +
        ")" +
        ".then( function (data) {" +
        easySuccess() +
        "}, function (data) {" +
        cancel() +
        easyError() +
        "})";
  }

  static String getJSDestroyWallet(BioPayload payload) {
    var wallet = {
      "authenticate_type": "password",
      "user_token": payload.userToken,
      "wallet_id": payload.walletId,
      "token": payload.token,
    };

    return "BootpaySDK.destroyWallet('" +
        json.encode(wallet) +
        "')" +
        ".then( function (data) {" +
        easySuccess() +
        "}, function (data) {" +
        cancel() +
        easyError() +
        "})";
  }
}