import 'dart:io';

import 'package:bootpay/user_info.dart';
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
  BioPayload? bioPayload;
  // var walletList = <Rx<WalletData>>[].obs;
  var resWallet = ResWalletList().obs;
  var requestType = BioConstants.REQUEST_TYPE_NONE.obs;
  var selectedCardIndex = 0;

  final ApiProvider _provider = ApiProvider();

  void initValues() {
    otp = "";
    selectedQuota = 0;
    bioPayload = null;
  }

  Future<bool> getWalletList(String userToken) async {
    // print('getWalletList');

    String deviceId = await UserInfo.getBootpayUUID();

    print("요청: deviceId: $deviceId, userToken: $userToken");

    var res = await _provider.getWalletList(deviceId, userToken);

    print("응답:  ${res.body} ");

    if(res.statusCode == HttpStatus.ok) {
      resWallet.value = ResWalletList.fromJson(res.body);
      // walletList = res.body?.map((e) => WalletData.fromJson(e)).toList();
      return true;
    }


    Fluttertoast.showToast(
        msg: res.body ?? '지갑정보 조회에 실패하였습니다',
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