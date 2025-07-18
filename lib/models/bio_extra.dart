import 'dart:convert';
import 'dart:io';

import 'package:bootpay/model/browser_open_type.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/extra_card_easy_option.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:flutter/foundation.dart';

import 'bio_price.dart';
import '../extension/json_query_string.dart';
import 'package:intl/intl.dart';
import 'dart:convert';


class BioExtra  {

  String? cardQuota = ''; //할부허용 범위 (5만원 이상 구매시)
  String? sellerName = '';  //노출되는 판매자명 설정
  int? deliveryDay = 1; //배송일자
  String? locale = 'ko'; //결제창 언어지원
  String? offerPeriod = ''; //결제창 제공기간에 해당하는 string 값, 지원하는 PG만 적용됨
  bool? displayCashReceipt = true; // 현금영수증 보일지 말지.. 가상계좌 KCP 옵션
  String? depositExpiration = ""; //가상계좌 입금 만료일자 설정
  String? appScheme;  //모바일 앱에서 결제 완료 후 돌아오는 옵션 ( 아이폰만 적용 )
  bool? useCardPoint = true; //카드 포인트 사용 여부 (토스만 가능)
  String? directCard = ""; //해당 카드로 바로 결제창 (토스만 가능)
  bool? useOrderId = false; //가맹점 order_id로 PG로 전송
  bool? internationalCardOnly = false; //해외 결제카드 선택 여부 (토스만 가능)
  String? phoneCarrier = ""; // //본인인증 시 고정할 통신사명, SKT,KT,LGT 중 1개만 가능
  bool? directAppCard = false; //카드사앱으로 direct 호출
  bool? directSamsungpay = false; //삼성페이 바로 띄우기
  bool? testDeposit = false; //가상계좌 모의 입금
  bool? enableErrorWebhook = false; //결제 오류시 Feedback URL로 webhook
  bool? separatelyConfirmedBio = false; // 중요 - 간편결제에서 true면 무조건 서버 승인(분리승인), false면 바로 승인
  bool? separatelyConfirmed = true; // confirm 이벤트를 호출할지 말지, false일 경우 자동승인, 간편결제에선 적용되지 않음
  bool? confirmOnlyRestApi = false; // REST API로만 승인 처리
  String? openType = 'redirect'; //페이지 오픈 type, [iframe, popup, redirect] 중 택 1
  bool? useBootpayInappSdk = true; //native app에서는 redirect를 완성도있게 지원하기 위한 옵션
  String? redirectUrl = 'https://api.bootpay.co.kr/v2'; //open_type이 redirect일 경우 페이지 이동할 URL (  오류 및 결제 완료 모두 수신 가능 )
  bool? displaySuccessResult = false; // 결제 완료되면 부트페이가 제공하는 완료창으로 보여주기 ( open_type이 iframe, popup 일때만 가능 )
  bool? displayErrorResult = true; // 결제 실패되면 부트페이가 제공하는 실패창으로 보여주기 ( open_type이 iframe, popup 일때만 가능 )
  double? disposableCupDeposit = 0; // 배달대행 플랫폼을 위한 컵 보증급 가격
  ExtraCardEasyOption cardEasyOption = ExtraCardEasyOption();
  List<BrowserOpenType>? browserOpenType = [];
  int? useWelcomepayment = 0; //웰컴 재판모듈 진행시 1
  String? firstSubscriptionComment = ""; // 자동결제 price > 0 조건일 때 첫 결제 관련 메세지
  List<String>? exceptCardCompanies = []; // 제외할 카드사 리스트 ( enable_card_companies가 우선순위를 갖는다 )
  List<String>? enableEasyPayments = []; // 노출될 간편결제 리스트
  int? confirmGraceSeconds = 10; // 결제승인 유예시간 ( 승인 요청을 여러번하더라도 승인 이후 특정 시간동안 계속해서 결제 response_data 를 리턴한다 )

  bool? isShowTotalPay = true;
  bool? hideOtherPaymentMethods = false; // 다른 결제수단 버튼 숨김 옵션


  BioExtra();

  BioExtra.fromJson(Map<String, dynamic> json) {
    cardQuota = json["card_quota"];
    sellerName = json["seller_name"];

    deliveryDay = json["delivery_day"];
    locale = json["locale"];
    offerPeriod = json["offer_period"];

    displayCashReceipt = json["display_cash_receipt"];
    depositExpiration = json["deposit_expiration"];
    appScheme = json["app_scheme"];

    useCardPoint = json["use_card_point"];
    directCard = json["direct_card"];
    useOrderId = json["use_order_id"];
    internationalCardOnly = json["international_card_only"];
    phoneCarrier = json["phone_carrier"];
    directAppCard = json["direct_app_card"];
    directSamsungpay = json["direct_samsungpay"];
    testDeposit = json["test_deposit"];
    enableErrorWebhook = json["enable_error_webhook"];
    separatelyConfirmed = json["separately_confirmed"];
    separatelyConfirmedBio = json['separately_confirmed_bio'];
    confirmOnlyRestApi = json["confirm_only_rest_api"];
    openType = json["open_type"];

    useBootpayInappSdk = json["use_bootpay_inapp_sdk"];
    redirectUrl = json["redirect_url"];
    displaySuccessResult = json["display_success_result"];
    displayErrorResult = json["display_error_result"];
    disposableCupDeposit = json["disposable_cup_deposit"];
    useWelcomepayment = json["use_welcomepayment"];
    firstSubscriptionComment = json["first_subscription_comment"];
    exceptCardCompanies = json["except_card_companies"];
    enableEasyPayments = json["enable_easy_payments"];
    confirmGraceSeconds = json["confirm_grace_seconds"];
    isShowTotalPay = json["isShowTotalPay"];
    hideOtherPaymentMethods = json["hideOtherPaymentMethods"];
  }

  Map<String, dynamic> toJson() => {
    "card_quota": this.cardQuota,
    "seller_name": this.sellerName,
    "delivery_day": this.deliveryDay,
    "locale": this.locale,
    "offer_period": this.offerPeriod,
    "display_cash_receipt": this.displayCashReceipt,
    "deposit_expiration": this.depositExpiration,
    "app_scheme": this.appScheme,
    "use_card_point": this.useCardPoint,
    "direct_card": this.directCard,
    "use_order_id": this.useOrderId,
    "international_card_only": this.internationalCardOnly,
    "phone_carrier": this.phoneCarrier,
    "direct_app_card": this.directAppCard,
    "direct_samsungpay": this.directSamsungpay,
    "test_deposit": this.testDeposit,
    "enable_error_webhook": this.enableErrorWebhook,
    "separately_confirmed": this.separatelyConfirmed,
    "separately_confirmed_bio": this.separatelyConfirmedBio,
    "confirm_only_rest_api": this.confirmOnlyRestApi,
    "open_type": this.openType,
    "use_bootpay_inapp_sdk": this.useBootpayInappSdk,
    "redirect_url": this.redirectUrl,
    "display_success_result": this.displaySuccessResult,
    "display_error_result": this.displayErrorResult,
    "disposable_cup_deposit": this.disposableCupDeposit,
    "use_welcomepayment": this.useWelcomepayment,
    "first_subscription_comment": this.firstSubscriptionComment,
    "except_card_companies": this.exceptCardCompanies,
    "enable_easy_payments": this.enableEasyPayments,
    "confirm_grace_seconds": this.confirmGraceSeconds,
    "is_show_total_pay": this.isShowTotalPay,
    "hide_other_payment_methods": this.hideOtherPaymentMethods
  };


  Map<String, dynamic> toJsonEasyPay() => {
    "card_quota": this.cardQuota,
    "seller_name": this.sellerName,
    "delivery_day": this.deliveryDay,
    "locale": this.locale,
    "offer_period": this.offerPeriod,
    "display_cash_receipt": this.displayCashReceipt,
    "deposit_expiration": this.depositExpiration,
    "app_scheme": this.appScheme,
    "use_card_point": this.useCardPoint,
    "direct_card": this.directCard,
    "use_order_id": this.useOrderId,
    "international_card_only": this.internationalCardOnly,
    "phone_carrier": this.phoneCarrier,
    "direct_app_card": this.directAppCard,
    "direct_samsungpay": this.directSamsungpay,
    "test_deposit": this.testDeposit,
    "enable_error_webhook": this.enableErrorWebhook,
    "separately_confirmed": this.separatelyConfirmedBio,
    "confirm_only_rest_api": this.confirmOnlyRestApi,
    "open_type": this.openType,
    "use_bootpay_inapp_sdk": this.useBootpayInappSdk,
    "redirect_url": this.redirectUrl,
    "display_success_result": this.displaySuccessResult,
    "display_error_result": this.displayErrorResult,
    "disposable_cup_deposit": this.disposableCupDeposit,
    "use_welcomepayment": this.useWelcomepayment,
    "first_subscription_comment": this.firstSubscriptionComment,
    "except_card_companies": this.exceptCardCompanies,
    "enable_easy_payments": this.enableEasyPayments,
    "confirm_grace_seconds": this.confirmGraceSeconds,
    "is_show_total_pay": this.isShowTotalPay,
    "hide_other_payment_methods": this.hideOtherPaymentMethods
  };


  // String toStringEasyPay() {
  //   return "{card_quota: '${reVal(cardQuota)}', seller_name: '${reVal(sellerName)}', delivery_day: ${reVal(deliveryDay)}, locale: '${reVal(locale)}'," +
  //       "offer_period: '${reVal(offerPeriod)}', display_cash_receipt: '${reVal(displayCashReceipt)}', deposit_expiration: '${reVal(depositExpiration)}'," +
  //       "app_scheme: '${reVal(appScheme)}', use_card_point: ${useCardPoint}, direct_card: '${reVal(directCard)}', use_order_id: ${useOrderId}, international_card_only: ${internationalCardOnly}," +
  //       "phone_carrier: '${reVal(phoneCarrier)}', direct_app_card: ${directAppCard}, direct_samsungpay: ${directSamsungpay}, test_deposit: ${reVal(testDeposit)}, enable_error_webhook: ${enableErrorWebhook}, separately_confirmed: ${separatelyConfirmedBio}," +
  //       "confirm_only_rest_api: ${confirmOnlyRestApi}, open_type: '${reVal(openType)}', redirect_url: '${reVal(redirectUrl)}', display_success_result: ${displaySuccessResult}, display_error_result: ${displayErrorResult}, disposable_cup_deposit: ${disposableCupDeposit}," +
  //       "first_subscription_comment: '${reVal(firstSubscriptionComment)}', except_card_companies: [${(exceptCardCompanies ?? []).join(",")}], enable_easy_payments: [${(enableEasyPayments ?? []).join(",")}], confirm_grace_seconds: ${confirmGraceSeconds}," +
  //       "use_bootpay_inapp_sdk: ${useBootpayInappSdk}, use_welcomepayment: ${useWelcomepayment}, first_subscription_comment: '${reVal(firstSubscriptionComment)}' }";
  // }

  String toString() {
    return "{card_quota: '${reVal(cardQuota)}', seller_name: '${reVal(sellerName)}', delivery_day: ${reVal(deliveryDay)}, locale: '${reVal(locale)}'," +
        "offer_period: '${reVal(offerPeriod)}', display_cash_receipt: '${reVal(displayCashReceipt)}', deposit_expiration: '${reVal(depositExpiration)}'," +
        "app_scheme: '${reVal(appScheme)}', use_card_point: ${useCardPoint}, direct_card: '${reVal(directCard)}', use_order_id: ${useOrderId}, international_card_only: ${internationalCardOnly}," +
        "phone_carrier: '${reVal(phoneCarrier)}', direct_app_card: ${directAppCard}, direct_samsungpay: ${directSamsungpay}, test_deposit: ${reVal(testDeposit)}, enable_error_webhook: ${enableErrorWebhook}, separately_confirmed: ${separatelyConfirmed}," +
        "confirm_only_rest_api: ${confirmOnlyRestApi}, open_type: '${reVal(openType)}', redirect_url: '${reVal(redirectUrl)}', display_success_result: ${displaySuccessResult}, display_error_result: ${displayErrorResult}, disposable_cup_deposit: ${disposableCupDeposit}," +
        "first_subscription_comment: '${reVal(firstSubscriptionComment)}', except_card_companies: [${(exceptCardCompanies ?? []).join(",")}], enable_easy_payments: [${(enableEasyPayments ?? []).join(",")}], confirm_grace_seconds: ${confirmGraceSeconds}," +
        "use_bootpay_inapp_sdk: ${useBootpayInappSdk}, use_welcomepayment: ${useWelcomepayment}, first_subscription_comment: '${reVal(firstSubscriptionComment)}' }";
  }

  dynamic reVal(dynamic value) {
    if (value is String) {
      if (value.isEmpty) {
        return '';
      }
      return value.replaceAll("\"", "'").replaceAll("'", "\\'");
    } else {
      return value.toString();
    }
  }
}