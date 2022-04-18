# bootpay_bio 플러터 라이브러리

부트페이에서 생체결제 공식 Flutter 라이브러리 입니다. (클라이언트 용)
* PG 결제창 연동은 클라이언트 라이브러리에서 수행됩니다. (Javascript, Android, iOS, React Native, Flutter 등)
* 결제 검증 및 취소, 빌링키 발급, 본인인증 등의 수행은 서버사이드에서 진행됩니다. (Java, PHP, Python, Ruby, Node.js, Go, ASP.NET 등)

## 기능

1. ios/android 지원
2. 카드정기결제(REST) 를 지원하는 PG사에 한해서 지원 (페이앱, 나이스페이)

## 설치하기
``pubspec.yaml`` 파일에 아래 모듈을 추가해주세요
```yaml
...
dependencies:
 ...
 bootpay_bio: last_version
...
```

## 설정하기

### Android

MainActivity.java를 아래와 같이 변경합니다.
(FlutterActivity 대신 FlutterFragmentActivity을 사용해야 합니다)

```java
import android.os.Bundle;
import io.flutter.embedding.android.FlutterFragmentActivity;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterFragmentActivity {

    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine)
    {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }
}
```


또는

코틀린일 경우 아래와 같이 MainActivity.kt 파일을 수정합니다

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
``` 

 `AndroidManifest.xml` 파일에 아래 2개의 권한을 추가해줍니다.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          package="com.example.app">
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
<manifest>
```

### iOS
** {your project root}/ios/Runner/Info.plist **
``CFBundleURLName``과 ``CFBundleURLSchemes``의 값은 개발사에서 고유값으로 지정해주셔야 합니다. 외부앱(카드사앱)에서 다시 기존 앱으로 앱투앱 호출시 필요한 스키마 값입니다.
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    ...

    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>kr.co.bootpaySample</string> 
            <key>CFBundleURLSchemes</key>
            <array>
                <string>bootpaySample</string> 
            </array>
        </dict>
    </array>

    ...
    <key>NSFaceIDUsageDescription</key>
    <string>생체인증 결제 진행시 권한이 필요합니다</string>
</dict>
</plist>
```

## 결제하기
```dart 

import 'package:bootpay_bio/bootpay_bio.dart';
import 'package:bootpay_bio/config/bio_config.dart';
import 'package:bootpay_bio/constants/bio_constants.dart';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:bootpay_bio/models/bio_price.dart';
import 'package:bootpay_bio/models/boot_extra.dart';
import 'package:bootpay_bio/models/boot_item.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:bootpay/model/stat_item.dart';
import 'package:bootpay/model/user.dart';

import 'deprecated/api_provider.dart';
import 'package:bootpay/bootpay.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ApiProvider _provider = ApiProvider();
  BioPayload bioPayload = BioPayload();
  String _data = ""; // 서버승인을 위해 사용되기 위한 변수

  String get applicationId {
    if(BioConstants.DEBUG) {
      return Bootpay().applicationId(
          '5b8f6a4d396fa665fdc2b5eb',
          '5b9f51264457636ab9a07cdc',
          '5b9f51264457636ab9a07cdd'
      );
    } else {
      return Bootpay().applicationId(
          '5b8f6a4d396fa665fdc2b5e7',
          '5b8f6a4d396fa665fdc2b5e8',
          '5b8f6a4d396fa665fdc2b5e9'
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    bioDataInit(); //결제용 데이터 init
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(builder: (BuildContext context) {
          return Container(
            color: Colors.green,
            child: Center(
                child: TextButton(
                  onPressed: () => goBootpayTest(context),
                  child: Text('부트페이 결제테스트'),
                )
            ),
          );
        }),
      ),
    );
  }


  //통계용 함수
  bootpayAnalyticsUserTrace() async {
    String? ver;
    if(kIsWeb) ver = '1.0'; //web 일 경우 버전 지정, 웹이 아닌 android, ios일 경우 package_info 통해 자동으로 생성


    await Bootpay().userTrace(
        id: 'user_1234',
        email: 'user1234@gmail.com',
        gender: -1,
        birth: '19941014',
        area: '서울',
        applicationId: applicationId,
        ver: ver
    );
  }

  //통계용 함수
  bootpayAnalyticsPageTrace() async {
    String? ver;
    if(kIsWeb) ver = '1.0'; //web 일 경우 버전 지정, 웹이 아닌 android, ios일 경우 package_info 통해 자동으로 생성

    StatItem item1 = StatItem();
    item1.itemName = "미키 마우스"; // 주문정보에 담길 상품명
    item1.unique = "ITEM_CODE_MOUSE"; // 해당 상품의 고유 키
    item1.price = 500; // 상품의 가격
    item1.cat1 = '컴퓨터';
    item1.cat2 = '주변기기';

    StatItem item2 = StatItem();
    item2.itemName = "키보드"; // 주문정보에 담길 상품명
    item2.unique = "ITEM_CODE_KEYBOARD"; // 해당 상품의 고유 키
    item2.price = 500; // 상품의 가격
    item2.cat1 = '컴퓨터';
    item2.cat2 = '주변기기';

    List<StatItem> items = [item1, item2];

    await Bootpay().pageTrace(
        url: 'main_1234',
        pageType: 'sub_page_1234',
        applicationId: applicationId,
        userId: 'user_1234',
        items: items,
        ver: ver
    );
  }

  //결제용 데이터 init
  bioDataInit() {
    BootItem item1 = BootItem();
    item1.name = "미키 마우스"; // 주문정보에 담길 상품명
    item1.qty = 1; // 해당 상품의 주문 수량
    item1.id = "ITEM_CODE_MOUSE"; // 해당 상품의 고유 키
    item1.price = 500; // 상품의 가격

    BootItem item2 = BootItem();
    item2.name = "키보드"; // 주문정보에 담길 상품명
    item2.qty = 1; // 해당 상품의 주문 수량
    item2.id = "ITEM_CODE_KEYBOARD"; // 해당 상품의 고유 키
    item2.price = 500; // 상품의 가격
    List<BootItem> itemList = [item1, item2];

    if(BioConstants.DEBUG) {
      bioPayload.webApplicationId = '5b9f51264457636ab9a07cdb'; // web application id
      bioPayload.androidApplicationId = '5b9f51264457636ab9a07cdc'; // android application id
      bioPayload.iosApplicationId = '5b9f51264457636ab9a07cdd'; // ios application id
    } else {
      bioPayload.webApplicationId = '5b8f6a4d396fa665fdc2b5e7'; // web application id
      bioPayload.androidApplicationId = '5b8f6a4d396fa665fdc2b5e8'; // android application id
      bioPayload.iosApplicationId = '5b8f6a4d396fa665fdc2b5e9'; // ios application id
    }

    bioPayload.pg = 'nicepay';
    bioPayload.method = 'card';
    // payload.methods = ['card', 'phone', 'vbank', 'bank', 'kakao'];
    bioPayload.orderName = '테스트 상품'; //결제할 상품명
    bioPayload.price = 1000.0; //정기결제시 0 혹은 주석

    bioPayload.orderId = DateTime.now().millisecondsSinceEpoch.toString(); //주문번호, 개발사에서 고유값으로 지정해야함
    bioPayload.metadata = {
      "callbackParam1" : "value12",
      "callbackParam2" : "value34",
      "callbackParam3" : "value56",
      "callbackParam4" : "value78",
    }; // 전달할 파라미터, 결제 후 되돌려 주는 값
    bioPayload.items = itemList; // 상품정보 배열

    User user = User(); // 구매자 정보
    user.username = "사용자 이름";
    user.email = "user1234@gmail.com";
    user.area = "서울";
    user.phone = "010-1234-5678";
    user.addr = '서울시 동작구 상도로 222';

    BootExtra extra = BootExtra(); // 결제 옵션
    extra.appScheme = 'bootpayFlutterExample';
    extra.cardQuota = "3";
    // extra.clo

    // extra.carrier = "SKT,KT,LGT"; //본인인증 시 고정할 통신사명
    // extra.ageLimit = 20; // 본인인증시 제한할 최소 나이 ex) 20 -> 20살 이상만 인증이 가능
    bioPayload.user = user;
    bioPayload.extra = extra;
  }


  //버튼클릭시 부트페이 결제요청 실행
  Future<void> goBootpayTest(BuildContext context) async {
    String restApplicationId = "";
    String pk = "";
    if(BioConstants.DEBUG) {
      restApplicationId = "5b9f51264457636ab9a07cde";
      pk = "sfilSOSVakw+PZA+PRux4Iuwm7a//9CXXudCq9TMDHk=";
    } else {
      restApplicationId = "5b8f6a4d396fa665fdc2b5ea";
      pk = "rm6EYECr6aroQVG2ntW0A6LpWnkTgP4uQ3H18sDDUYw=";
    }
    var res = await _provider.getRestToken(restApplicationId, pk);

    BootpayPrint("getRestToken: ${res.body}");

    var user = User();
    user.id = '123411ad122dd1123';
    user.gender = 1;
    user.email = 'test1234@gmail.com';
    user.phone = '01012345678';
    user.birth = '19880610';
    user.username = '홍길동';
    user.area = '서울';

    res = await _provider.getEasyPayUserToken(res.body['access_token'], user);
    BootpayPrint("getEasyPayUserToken: ${res.body}");
    goBootpayRequest(context, res.body["user_token"], user);
  }

  void goBootpayRequest(BuildContext context, String easyUserToken, User user) {

    BootItem item1 = BootItem();
    item1.name = "미키 마우스"; // 주문정보에 담길 상품명
    item1.qty = 1; // 해당 상품의 주문 수량
    item1.id = "ITEM_CODE_MOUSE"; // 해당 상품의 고유 키
    item1.price = 500; // 상품의 가격

    BootItem item2 = BootItem();
    item2.name = "키보드"; // 주문정보에 담길 상품명
    item2.qty = 1; // 해당 상품의 주문 수량
    item2.id = "ITEM_CODE_KEYBOARD"; // 해당 상품의 고유 키
    item2.price = 500; // 상품의 가격
    List<BootItem> itemList = [item1, item2];

    var bioPayload = BioPayload();
    bioPayload.userToken = easyUserToken;
    if(BioConstants.DEBUG) {
      bioPayload.webApplicationId = '5b9f51264457636ab9a07cdb'; // web application id
      bioPayload.androidApplicationId = '5b9f51264457636ab9a07cdc'; // android application id
      bioPayload.iosApplicationId = '5b9f51264457636ab9a07cdd'; // ios application id
    } else {
      bioPayload.webApplicationId = '5b8f6a4d396fa665fdc2b5e7'; // web application id
      bioPayload.androidApplicationId = '5b8f6a4d396fa665fdc2b5e8'; // android application id
      bioPayload.iosApplicationId = '5b8f6a4d396fa665fdc2b5e9'; // ios application id
    }


    bioPayload.pg = 'payapp';
    // bioPayload.method = 'card';
    // payload.methods = ['card', 'phone', 'vbank', 'bank', 'kakao'];
    bioPayload.orderName = '플리츠레이어 카라숏원피스'; //결제할 상품명
    bioPayload.price =  1000.0; //정기결제시 0 혹은 주석

    bioPayload.orderId = DateTime.now().millisecondsSinceEpoch.toString(); //주문번호, 개발사에서 고유값으로 지정해야함
    bioPayload.metadata = {
      "callbackParam1" : "value12",
      "callbackParam2" : "value34",
      "callbackParam3" : "value56",
      "callbackParam4" : "value78",
    }; // 전달할 파라미터, 결제 후 되돌려 주는 값
    bioPayload.items = itemList; // 상품정보 배열


    BootExtra extra = BootExtra(); // 결제 옵션
    extra.appScheme = 'bootpayFlutterExample';
    extra.cardQuota = "3";

    bioPayload.user = user;
    bioPayload.extra = extra;
    bioPayload.names = ["블랙 (COLOR)", "55 (SIZE)"];
    bioPayload.prices = [
      BioPrice(name: '상품가격', price: 89000),
      BioPrice(name: '쿠폰적용', price: -25000),
      BioPrice(name: '배송비', price: 2500),
    ];


    BootpayBio().request(
      context: context,
      payload: bioPayload,
      showCloseButton: false,
      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data) {
        print('------- onCancel: $data');
      },
      onError: (String data) {
        print('------- onError: $data');
      },
      onClose: () {
        print('------- onClose');
        BootpayBio().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        //TODO - 원하시는 라우터로 페이지 이동
      },
      onCloseHardware: () {
        print('------- onCloseHardware');
      },
      onReady: (String data) {
        print('------- onReady: $data');
      },
      onConfirm: (String data) {
        print('------- onConfirm: $data');
        return true; //결제를 최종 승인하고자 할때 return true

        //서버승인을 위한 로직 시작
        // _data = data;
        // Future.delayed(const Duration(milliseconds: 100), () {
        //   Bootpay().transactionConfirm(_data); // 서버승인 이용시 해당 함수 호출
        // });
        // return false;
        //서버 승인을 위한 로직 끝
      },
      onDone: (String data) {
        print('------- onDone: $data');
      },
    );
  }
}


```

## Documentation

[부트페이 개발매뉴얼](https://bootpay.gitbook.io/docs/)을 참조해주세요

## 기술문의

[채팅](https://bootpay.channel.io/)으로 문의

## License

[MIT License](https://opensource.org/licenses/MIT).

