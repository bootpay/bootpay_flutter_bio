
import 'package:get/get.dart';

import '../config/bio_config.dart';
import '../constants/bio_constants.dart';

class ApiProvider extends GetConnect {
  // get defaultUrl => 'https://api.bootpay.co.kr';
  // get defaultUrl => 'https://dev-api.bootpay.co.kr';
  String get defaultUrl {
    if(BootpayBioConfig.ENV == BootpayBioConfig.ENV_DEBUG) {
      // if (BootpayConfig.ENV == BootpayConfig.ENV_DEBUG)
      return 'https://dev-api.bootpay.co.kr';
    } else {
      return 'https://api.bootpay.co.kr';
    }
  }



  Future<Response> getWalletList(String deviceUUID, String userToken) async {
    var url = "$defaultUrl/v2/sdk/easy/wallet.json";

    var headers =  {
    'Accept': 'application/json',
    'Bootpay-Device-UUID': deviceUUID,
    'Bootpay-User-Token': userToken,
    };

    print('url: $url, headers: $headers');

    return get(
        url,
        contentType: 'application/json',
        headers: headers
    );
  }
}