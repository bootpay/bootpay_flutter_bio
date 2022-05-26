import 'dart:io';

import 'package:bootpay/user_info.dart';
import 'package:bootpay_bio/config/bio_config.dart';
import 'package:bootpay_bio/constants/bio_constants.dart';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:bootpay_bio/models/res/res_wallet_list.dart';
import 'package:bootpay_bio/models/wallet/wallet_data.dart';
import 'package:bootpay_bio/provider/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:fluttertoast/fluttertoast.dart';


class BioController extends GetxController {
  var otp = "";
  var selectedQuota = 0;
  // BioPayload? bioPayload;
  // var walletList = <Rx<WalletData>>[].obs;
  var resWallet = ResWalletList().obs;
  var requestType = BioConstants.REQUEST_TYPE_NONE.obs;
  var isPasswordMode = false; //비밀번호 간편결제 호출인지
  var selectedCardIndex = 0;

  final ApiProvider _provider = ApiProvider();
  final List<String> cardQuotaList = ['일시불', "2개월", "3개월", "4개월", "5개월", "6개월",
    "7개월","8개월","9개월","10개월","11개월","12개월"];

  void initValues() {
    otp = "";
    selectedQuota = 0;
  }

  void setCardQuota(String value) {
    int index = cardQuotaList.indexOf(value);
    if(index <= -1) return;
    if(index == 0) { selectedQuota = index; }
    else { selectedQuota = index + 1; }
  }

  Future<bool> getWalletList(String userToken) async {
    // print('getWalletList');

    String deviceId = await UserInfo.getBootpayUUID();

    BootpayPrint("요청: deviceId: $deviceId, userToken: $userToken");

    var res = await _provider.getWalletList(deviceId, userToken);

    BootpayPrint("응답:  ${res.body} ");

    if(res.statusCode == HttpStatus.ok) {
      resWallet.value = ResWalletList.fromJson(res.body);
      // walletList = res.body?.map((e) => WalletData.fromJson(e)).toList();
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