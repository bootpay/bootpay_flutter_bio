
import 'package:get/get.dart';

class ApiProvider extends GetConnect {
  // get defaultUrl => 'https://api.bootpay.co.kr';
  get defaultUrl => 'https://dev-api.bootpay.co.kr';



  Future<Response> getWalletList(String deviceUUID, String userToken) async {
    var url = "$defaultUrl/v2/sdk/easy/wallet.json";

    return get(
        url,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          'Bootpay-Device-UUID': deviceUUID,
          'Bootpay-User-Token': userToken,
        }
    );
  }
}