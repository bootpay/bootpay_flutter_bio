import 'dart:convert';
import 'dart:io';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/user_info.dart';
import 'package:bootpay_bio/config/bio_config.dart';
import 'package:bootpay_bio/constants/bio_constants.dart';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:bootpay_bio/models/res/res_wallet_list.dart';
import 'package:bootpay_bio/models/wallet/wallet_data.dart';
import 'package:bootpay_bio/provider/api_provider.dart';
import 'package:bootpay_bio/provider/api_webview_provider.dart';
import 'package:bootpay_webview_flutter/bootpay_webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bio_container.dart';
import '../models/wallet/bio_metric.dart';
import '../models/wallet/next_job.dart';

//data, provider, bio_container's view-model
class BioController extends GetxController {
  /** provider **/
  ApiWebviewProvider? webViewProvider;
  final ApiProvider _provider = ApiProvider();

  /** view model **/
  var isShowWebView = false.obs;
  var isShowWebViewHalfSize = false.obs;
  var easyType = BioConstants.EASY_TYPE_BIO; //비밀번호 간편결제 호출인지
  var isEditMode = false; //편집 모드인지
  var resWallet = ResWalletList().obs;
  var selectedCardIndex = -1;
  final List<String> cardQuotaList = [
    '일시불',
    "2개월",
    "3개월",
    "4개월",
    "5개월",
    "6개월",
    "7개월",
    "8개월",
    "9개월",
    "10개월",
    "11개월",
    "12개월"
  ];

  /** data **/
  var otp = "";
  var selectedQuota = 0;
  var requestType = BioConstants.REQUEST_TYPE_NONE.obs;
  BioPayload? payload;

  /** callback interface **/
  BootpayDefaultCallback? onCallbackCancel;
  BootpayDefaultCallback? onCallbackError;
  BootpayCloseCallback? onCallbackClose;
  BootpayDefaultCallback? onCallbackIssued;
  BootpayConfirmCallback? onCallbackConfirm;
  BootpayAsyncConfirmCallback? onCallbackConfirmAsync;
  BootpayDefaultCallback? onCallbackDone;
  BootpayNextJobCallback? onCallbackNextJob;
  BootpayCloseCallback? onCallbackDebounceClose;

  void initValues(ApiWebviewProvider webViewProvider, BioPayload payload) {
    otp = "";
    selectedQuota = 0;
    selectedCardIndex = -1;
    this.webViewProvider = webViewProvider;
    this.payload = payload;
    isShowWebView = false.obs;
    isShowWebViewHalfSize = false.obs;
    resWallet = ResWalletList().obs;
  }

  void initCallbackEvent(
      BootpayDefaultCallback? onCancel,
      BootpayDefaultCallback? onError,
      BootpayCloseCallback? onClose,
      BootpayDefaultCallback? onIssued,
      BootpayConfirmCallback? onConfirm,
      BootpayAsyncConfirmCallback? onConfirmAsync,
      BootpayDefaultCallback? onDone,
      BootpayNextJobCallback? onNextJob,
      BootpayCloseCallback? onDebounceClose
      ) {
    onCallbackCancel = onCancel;
    onCallbackError = onError;
    onCallbackClose = onClose;
    onCallbackIssued = onIssued;
    onCallbackConfirm = onConfirm;
    onCallbackConfirmAsync = onConfirmAsync;
    onCallbackDone = onDone;
    onCallbackNextJob = onNextJob;
    onCallbackDebounceClose = onDebounceClose;

    webViewProvider?.initWebViewCallback(
        onWebViewCancel,
        onWebViewError,
        onWebViewClose,
        onWebViewIssued,
        onWebViewConfirm,
        onWebViewDone,
        onWebViewRedirect,
        onWebViewEasySuccess,
        onWebViewEasyError
    );
  }
}

extension BCInnerFunction on BioController {
  void setCardQuota(String value) {
    int index = cardQuotaList.indexOf(value);
    if(index <= -1) return;
    if(index == 0) { selectedQuota = index; }
    else { selectedQuota = index + 1; }
  }

  // Future<void> startPayWithSelectedCard() async {
  //
  // }

  Future<void> setPasswordToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("password_token", token);
    payload?.token = token;
  }

  Future<void> setBioDeviceInfo(NextJob data) async {
    if(data.biometricDeviceUuid.isNotEmpty && data.biometricSecretKey.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("biometric_device_uuid", data.biometricDeviceUuid);
      prefs.setString("biometric_secret_key", data.biometricSecretKey);
      prefs.setInt("server_unixtime", data.serverUnixtime);
    }
  }


  Future<void> goConfirmEvent(JavaScriptMessage message) async {
    // if (onConfirm != null) {
    //   bool goTransactionConfirm = onConfirm!(message.message);
    //   if (goTransactionConfirm) {
    //     transactionConfirm();
    //   }
    // } else if(onConfirmAsync != null) {
    //   bool goTransactionConfirm = await onConfirmAsync!(message.message);
    //   if (goTransactionConfirm) {
    //     transactionConfirm();
    //   }
    // }
    BootpayPrint('goConfirmEvent: $requestType, ${message.message}');
    
    if(onCallbackConfirm != null) {
      bool goTransactionConfirm = onCallbackConfirm!(message.message);
      if (goTransactionConfirm) {
        BootpayPrint('transactionConfirm called - waiting for done event');
        webViewProvider?.transactionConfirm();
      } else {
        // 사용자가 false를 반환한 경우, close 처리
        if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
      }
    } else if(onCallbackConfirmAsync != null) {
      bool goTransactionConfirm = await onCallbackConfirmAsync!(message.message);
      if (goTransactionConfirm) {
        BootpayPrint('transactionConfirm called (async) - waiting for done event');
        webViewProvider?.transactionConfirm();
        // transactionConfirm();
      } else {
        // 사용자가 false를 반환한 경우, close 처리
        if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
      }
    }
  }
}

extension BCApiProvider on BioController {
  Future<bool> getWalletList(String userToken) async {
    String deviceId = await UserInfo.getBootpayUUID();

    var res = await _provider.getWalletList(deviceId, userToken);

    // BootpayPrint("getWalletList : ${res.body}");

    if(res.statusCode == HttpStatus.ok) {
      resWallet.value = ResWalletList.fromJson(res.body);
      resWallet.refresh();
      return true;
    }

    Fluttertoast.showToast(
        msg: res.body?.toString() ?? '지갑정보 조회에 실패하였습니다',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0
    );
    return false;
  }
}

extension BCWebViewProvider on BioController {
  Future<void> requestPasswordForPay({int? type, bool? doWorkNow = true}) async {
    if(type == null) {
      requestType.value = BioConstants.REQUEST_PASSWORD_FOR_PAY;
    } else {
      requestType.value = type;
    }
    webViewProvider?.requestPasswordForPay(payload!, requestType.value, doWorkNow: doWorkNow);
  }

  void removePaymentWindow() {
    webViewProvider?.removePaymentWindow();
  }

  Future<void> addNewCard({bool? doWorkNow = true}) async {
    requestType.value = BioConstants.REQUEST_ADD_CARD;
    webViewProvider?.addNewCard(payload!, requestType.value, doWorkNow: doWorkNow);
  }

  void requestTotalPay({bool? doWorkNow = true}) {
    requestType.value = BioConstants.REQUEST_TOTAL_PAY;
    webViewProvider?.requestTotalPay(payload!, requestType.value, doWorkNow: doWorkNow);
  }

  Future<void> requestAddBioData({int? type, bool? doWorkNow = true}) async {
    if(type != null) { requestType.value = type; }
    webViewProvider?.requestAddBioData(payload!, type: type, doWorkNow: doWorkNow);
  }

  Future<void> requestBioForPay(String otp, {String? cardQuota, bool? doWorkNow = true}) async {
    requestType.value = BioConstants.REQUEST_BIO_FOR_PAY;
    this.otp = otp;
    webViewProvider?.requestBioForPay(payload!, otp, requestType.value, cardQuota: '$selectedQuota', doWorkNow: doWorkNow);
  }

  // Future<void> requestBioForPay(BioPayload payload, {String? cardQuota, bool? doWorkNow = true}) async {
  //
  // }

  Future<void> requestPasswordToken({int? type, bool? doWorkNow = true}) async {
    if(type != null) { requestType.value = type; }
    webViewProvider?.requestPasswordToken(payload!, type: type, doWorkNow: doWorkNow);
  }

  Future<void> requestDeleteCard({bool? doWorkNow = true}) async {
    requestType.value = BioConstants.REQUEST_DELETE_CARD;
    webViewProvider?.requestDeleteCard(payload!, requestType.value, doWorkNow: doWorkNow);
  }

  // Future<void> onNextJob(NextJob data) async {
  //   if(payload == null) return;
  //
  //   if(data.initToken) {
  //     await setPasswordToken("");
  //   } else if(data.token.isNotEmpty) {
  //     String token = data.token.replaceAll("\"", "");
  //     await setPasswordToken(token);
  //   }
  //
  //   await setBioDeviceInfo(data);
  //
  //   if(data.nextType == BioConstants.NEXT_JOB_RETRY_PAY) {
  //     // doJobRetry();
  //     // container?.startPayWithSelectedCard();
  //     startPayWithSelectedCard();
  //   } else if(data.nextType == BioConstants.NEXT_JOB_ADD_NEW_CARD) {
  //     addNewCard();
  //   } else if(data.nextType == BioConstants.NEXT_JOB_ADD_DELETE_CARD) {
  //     requestDeleteCard();
  //   } else if(data.nextType == BioConstants.REQUEST_PASSWORD_FOR_PAY) {
  //     requestPasswordForPay();
  //   }
  //   else if(data.nextType == BioConstants.NEXT_JOB_GET_WALLET_LIST) {
  //     // BootpayPrint("onNextJob : ${data.nextType}");
  //
  //     if(data.type == BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY) {
  //
  //       getWalletList(true);
  //     } else {
  //       getWalletList(false);
  //     }
  //   }
  // }
}

extension BCWebViewProviderCallback on BioController {
  void onWebViewCancel(JavaScriptMessage message) {
    BootpayPrint('onWebViewCancel: $requestType, ${message.message}');

    if(onCallbackCancel != null) onCallbackCancel!(message.message);
    if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
    // if(onCancel != null) { onCancel();}
  }

  void onWebViewError(JavaScriptMessage message) {
    if(onCallbackError != null) onCallbackError!(message.message);

    if(payload?.extra?.displayErrorResult != true) {
      if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
    }
  }

  void onWebViewClose(JavaScriptMessage message) {
    BootpayPrint('onWebViewClose: $requestType, ${message.message}');

    if([
      BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY, //토큰 받은 후 결제
      BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY, //토큰 받은 후 결제
    ].contains(requestType.value)) {
      // getWalletList(payload?.userToken ?? '');
      isShowWebView.value = false; //카드 선택화면으로 돌아간다
      return;
    }

    /* close가 가끔 done 보다 빨리올때가 있다. done 으로 옮기자 */
    // if([
    //   BioConstants.REQUEST_ADD_CARD, //카드 추가
    //   BioConstants.REQUEST_DELETE_CARD, //카드 삭제
    // ].contains(requestType.value)) {
    //   // widget.showCardView();
    //   // c.show
    //   getWalletList(payload?.userToken ?? '');
    //   isShowWebView.value = false; //카드 선택화면으로 돌아간다
    //   return;
    // }

    // 생체인증 결제시 confirm 후 done을 기다리는 상태라면 close를 무시
    if([BioConstants.REQUEST_BIO_FOR_PAY,
      BioConstants.REQUEST_ADD_CARD,
      BioConstants.REQUEST_DELETE_CARD
    ].contains(requestType.value)) { 
      // confirm 이후의 close는 무시하고, done에서만 처리하도록 함
      BootpayPrint('onWebViewClose ignored for bio payment - waiting for done event');
      return;
    }

    if(BioConstants.REQUEST_PASSWORD_FOR_PAY == requestType.value) {
      NextJob job = NextJob();
      job.initToken = true;
      if (onCallbackNextJob != null) onCallbackNextJob!(job);
      return;
    }

    if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
  }

  void onWebViewIssued(JavaScriptMessage message) {
    BootpayPrint('onWebViewIssued: ${requestType}, ${message.message}');
    if(onCallbackIssued != null) onCallbackIssued!(message.message);
    if(payload?.extra?.displaySuccessResult != true) {
      if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
    }
  }

  void onWebViewConfirm(JavaScriptMessage message) {
    BootpayPrint('onWebViewConfirm: ${requestType}, ${message.message}');

    goConfirmEvent(message);
  }

  void onWebViewDone(JavaScriptMessage message) {
    BootpayPrint('onWebViewDone: ${requestType}, ${message.message}');

    if(onCallbackDone != null) onCallbackDone!(message.message);
    if(payload?.extra?.displaySuccessResult != true) {
      if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
    }
  }

  void onWebViewRedirect(JavaScriptMessage message) {
    BootpayPrint('onWebViewRedirect: ${requestType}, ${message.message}');

    final data = json.decode(message.message);
    switch(data["event"]) {
      case "cancel":
        // widget.updateProgressShow(false);
        // if (this.widget.onCancel != null) this.widget.onCancel!(message.message);
        // bootpayClose();
        if(onCallbackCancel != null) onCallbackCancel!(message.message);
        if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
        break;
      case "error":
        // widget.updateProgressShow(false);
        // if (this.widget.onError != null) this.widget.onError!(message.message);
        // if(this.widget.payload?.extra?.displayErrorResult != true) {
        //   bootpayClose();
        // }
        if(data["error_code"] == "PASSWORD_TOKEN_STOP") {
          if(onCallbackCancel != null) onCallbackCancel!(message.message);
          if(onCallbackDebounceClose != null) onCallbackDebounceClose!();

        } else {
          if(onCallbackError != null) onCallbackError!(message.message);
          if(payload?.extra?.displayErrorResult != true) {
            if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
          }
        }

        break;
      case "close":
        // widget.updateProgressShow(false);
        if(payload?.extra?.displayErrorResult != true) {
          if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
        }
        // if(this.widget.onClose != null) this.widget.onClose!();
        // BootpayBio().dismiss(context);
        break;
      case "issued":
        // widget.updateProgressShow(false);
        if(onCallbackIssued != null) onCallbackIssued!(message.message);
        if(payload?.extra?.displayErrorResult != true) {
          if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
        }
        break;
      case "confirm":
        goConfirmEvent(message);
        break;
      case "done":
        // widget.updateProgressShow(false);
        // if (this.widget.onDone != null) this.widget.onDone!(message.message);
        // if(this.widget.payload?.extra?.displaySuccessResult != true) {
        //   bootpayClose();
        // }
        if(onCallbackDone != null) onCallbackDone!(message.message);
        if(payload?.extra?.displaySuccessResult != true) {
          if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
        }
        break;
    }
  }

  void onWebViewEasySuccess(JavaScriptMessage message) {
    // BootpayPrint('onWebViewEasySuccess: ${requestType}, ${message.message}');

    NextJob job = NextJob();
    if([BioConstants.REQUEST_PASSWORD_TOKEN,
      BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD,
      BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD,
      BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY,
      BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY
    ].contains(requestType.value)) {
      job.type = requestType.value;
      job.token = message.message.replaceAll("\"", "");
      if(requestType.value != BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD) {
        job.nextType = BioConstants.NEXT_JOB_RETRY_PAY;
      } else {
        job.nextType = BioConstants.REQUEST_DELETE_CARD;
      }
      if (onCallbackNextJob != null) onCallbackNextJob!(job);

    } else if(requestType.value == BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY) {
      BioMetric bioMetric = BioMetric.fromJson(json.decode(message.message));

      // NextJob job = NextJob();
      job.type = requestType.value;
      job.nextType = BioConstants.NEXT_JOB_GET_WALLET_LIST;
      job.biometricSecretKey = bioMetric.biometricSecretKey ?? '';
      job.biometricDeviceUuid = bioMetric.biometricDeviceUuid ?? '';
      job.serverUnixtime = bioMetric.serverUnixtime ?? 0;
      if (onCallbackNextJob != null) onCallbackNextJob!(job);
      // onNextJob(job);
    } else {
      if([
          BioConstants.REQUEST_PASSWORD_FOR_PAY,
          BioConstants.REQUEST_ADD_CARD,
        ].contains(requestType.value)) {
        job.initToken = true;
        // onNextJob(job);
        if (onCallbackNextJob != null) onCallbackNextJob!(job);
        // if (widget.onNextJob != null) widget.onNextJob!(job);
      }

      if([
        BioConstants.REQUEST_DELETE_CARD,
        BioConstants.REQUEST_ADD_CARD,
      ].contains(requestType.value)) {
        //카드 등록과 삭제시에는 confirm을 보내지 않는다
        getWalletList(payload?.userToken ?? '');
        isShowWebView.value = false; //카드 선택화면으로 돌아간다
        return;
      }

      if(payload?.extra?.separatelyConfirmedBio == true) {
        if(onCallbackConfirm != null) {
          onCallbackConfirm!(message.message);
        } else if(onCallbackConfirmAsync != null) {
          onCallbackConfirmAsync!(message.message);
        }
      } else {
        //redirect 가 아니고, 분리승인일 수 있음  (통합결제)
        if(payload?.extra?.openType != 'redirect') {
          final data = json.decode(message.message);
          switch(data["event"]) {
            case "confirm":
              goConfirmEvent(message);
              break;
            case "done":
              if(onCallbackDone != null) onCallbackDone!(message.message);
              if(payload?.extra?.displaySuccessResult != true) {
                if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
              }
              break;
          }
          return;
        }

        //그 외 처리
        if(onCallbackDone != null) onCallbackDone!(message.message);
        
        // 생체인증 결제의 경우 done 이벤트에서만 close 처리
        if(requestType.value == BioConstants.REQUEST_BIO_FOR_PAY) {
          BootpayPrint('Bio payment done - closing payment window');
          if(payload?.extra?.displaySuccessResult != true) {
            if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
          }
        } else {
          // 다른 결제 방식의 경우 기존 로직 유지
          if(onCallbackDebounceClose != null) onCallbackDebounceClose!(); 
        }
      }
    }
  }

  Future<void> initBioAuthDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('biometric_secret_key', "");

  }

  void onWebViewEasyError(JavaScriptMessage message) {
    BootpayPrint('onWebViewEasyError: ${requestType}, ${message.message}');
    final data = json.decode(message.message);
    if(data["error_code"] == "USER_BIOMETRIC_OTP_INVALID") {
      NextJob job = NextJob();
      job.initToken = true;
      if(onCallbackNextJob != null) onCallbackNextJob!(job);
      initBioAuthDevice();
      requestType.value = BioConstants.REQUEST_TYPE_NONE;
      if(onCallbackError != null) onCallbackError!(message.message);

      return;
    }

    if(data["error_code"] == "PASSWORD_TOKEN_STOP") {
      if(onCallbackCancel != null) onCallbackCancel!(message.message);
      if(onCallbackDebounceClose != null) onCallbackDebounceClose!();
      return;
    }

    if(["USER_PW_TOKEN_NOT_FOUND",
        "USER_PW_TOKEN_EXPIRED"].contains(data["error_code"])) {
      NextJob job = NextJob();
      job.initToken = true;
      job.nextType = BioConstants.REQUEST_PASSWORD_FOR_PAY;
      if(onCallbackNextJob != null) onCallbackNextJob!(job);

    } else {
      requestType.value = BioConstants.REQUEST_TYPE_NONE;
      if(onCallbackError != null) onCallbackError!(message.message);
    }
  }
}