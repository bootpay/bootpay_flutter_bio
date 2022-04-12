

import 'package:get/get.dart';
import 'package:bootpay/model/user.dart';

@Deprecated('예제를 위해 제공되는 클래스입니다. 이 작업은 서버사이드에서 수행되어야 합니다.')
class ApiProvider extends GetConnect {
  get defaultUrl => 'https://dev-api.bootpay.co.kr';

  Future<Response> getRestToken(String applicationId, String privateKey) async {
    var payload = {
      'application_id': applicationId,
      'private_key': privateKey
    };

    return post(
        "$defaultUrl/v2/request/token",
        payload,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json'
        }
    );
  }

  Future<Response> getEasyPayUserToken(String token, User user) async {
    var payload = {
      'user_id': user.id,
      'email': user.email,
      'name': user.username,
      'gender': user.gender,
      'birth': user.birth,
      'phone': user.phone,
    };

    return post(
        "$defaultUrl/v2/request/user/token",
        payload,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          'Authorization': "Bearer $token"
        }
    );
  }
}