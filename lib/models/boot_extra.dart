import 'wallet/bio_card.dart';

class BootExtra {

  String? cardQuota = ''; //할부허용 범위 (5만원 이상 구매시)
  String? sellerName = ''; //노출되는 판매자명 설정
  int? deliveryDay = 1; //배송일자
  String? locale = "ko"; //결제창 언어지원
  String? offerPeriod; //결제창 제공기간에 해당하는 string 값, 지원하는 PG만 적용됨
  bool? displayCashReceipt = true; // 현금영수증 보일지 말지.. 가상계좌 KCP 옵션
  String? depositExpiration = ''; //가상계좌 입금 만료일자 설정

  String? appScheme = ''; //모바일 앱에서 결제 완료 후 돌아오는 옵션 ( 아이폰만 적용 )
  bool? useCardPoint = true; //카드 포인트 사용 여부 (토스만 가능)
  String? directCard = "ko"; //해당 카드로 바로 결제창 (토스만 가능)

  bool? useOrderId = false; //가맹점 order_id로 PG로 전송
  bool? internationalCardOnly = false; //해외 결제카드 선택 여부 (토스만 가능)

  String? phoneCarrier = '';  //본인인증 시 고정할 통신사명, SKT,KT,LGT 중 1개만 가능
  String? directAppCard = ""; //카드사앱으로 direct 호출
  String? directSamsungpay = ""; //삼성페이 바로 띄우기
  String? testDeposit = "";  //가상계좌 모의 입금

  bool? enableErrorWebhook = false; // 결제 오류시 Feedback URL로 webhook
  bool? separatelyConfirmed = false; // confirm 이벤트를 호출할지 말지, false일 경우 자동승인
  bool? confirmOnlyRestApi = false; // REST API로만 승인 처리

  String? openType = "iframe"; //페이지 오픈 type, default: iframe (popup, redirect) 셋 중 1개

  String? redirectUrl = ""; //open_type이 redirect일 경우 페이지 이동할 URL (  오류 및 결제 완료 모두 수신 가능 )
  bool? displaySuccessResult = true; // 결제 완료되면 부트페이가 제공하는 완료창으로 보여주기 ( open_type이 iframe, popup 일때만 가능 )
  bool? displayErrorResult = false; // 결제가 실패하면 부트페이가 제공하는 실패창으로 보여주기 ( open_type이 iframe, popup 일때만 가능 )


  BootExtra();

  BootExtra.fromJson(Map<String, dynamic> json) {
    cardQuota = json["cardQuota"];
    sellerName = json["sellerName"];
    deliveryDay = json["deliveryDay"];
    locale = json["locale"];
    offerPeriod = json["offerPeriod"];
    displayCashReceipt = json["displayCashReceipt"];
    depositExpiration = json["depositExpiration"];

    appScheme = json["appScheme"];
    useCardPoint = json["useCardPoint"];
    directCard = json["directCard"];

    useOrderId = json["useOrderId"];
    internationalCardOnly = json["internationalCardOnly"];

    phoneCarrier = json["phoneCarrier"];
    directAppCard = json["directAppCard"];
    directSamsungpay = json["directSamsungpay"];
    testDeposit = json["testDeposit"];

    enableErrorWebhook = json["enableErrorWebhook"];
    separatelyConfirmed = json["separatelyConfirmed"];
    confirmOnlyRestApi = json["confirmOnlyRestApi"];

    openType = json["openType"];

    redirectUrl = json["redirectUrl"];
    displaySuccessResult = json["displaySuccessResult"];
    displayErrorResult = json["displayErrorResult"];
  }

  Map<String, dynamic> toJson() => {
    "card_quota": cardQuota,
    "seller_name": sellerName,
    "delivery_day": deliveryDay,
    "locale": locale,
    "offer_period": offerPeriod,
    "display_cash_receipt": displayCashReceipt,
    "deposit_expiration": depositExpiration,
    "app_scheme": appScheme,
    "use_card_point": useCardPoint,
    "direct_card": directCard,
    "use_order_id": useOrderId,
    "international_card_only": internationalCardOnly,
    "phone_carrier": phoneCarrier,
    "direct_app_card": directAppCard,
    "direct_samsungpay": directSamsungpay,
    "test_deposit": testDeposit,
    "enable_error_webhook": enableErrorWebhook,
    "separately_confirmed": separatelyConfirmed,
    "confirm_only_rest_api": confirmOnlyRestApi,
    "open_type": openType,
    "redirect_url": redirectUrl,
    "display_success_result": displaySuccessResult,
    "display_error_result": displayErrorResult,
  };


  // String toString() {
  //   // return "{id: '${reVal(id)}', username: '${reVal(username)}', email: '${reVal(email)}', gender: ${reVal(gender)}, birth: '${reVal(birth)}', phone: '${reVal(phone)}', area: '${reVal(area)}', addr: '${reVal(addr)}'}";
  //
  //   return """
  //   {card_quota: '$cardQuota',
  //   seller_name: '$sellerName',
  //   delivery_day: $deliveryDay,
  //   delivery_day: $deliveryDay,
  //   """;
  // }
}