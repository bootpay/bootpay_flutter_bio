import 'dart:async';
import 'package:bootpay/user_info.dart';
import 'package:bootpay_bio/constants/bio_constants.dart';
import 'package:bootpay_bio/constants/card_code.dart';
import 'package:bootpay_bio/controller/bio_controller.dart';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:bootpay_bio/models/wallet/next_job.dart';
import 'package:bootpay_bio/models/wallet/wallet_data.dart';
import 'package:bootpay_bio/webview/bootpay_bio_webview.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bootpay_bio.dart';
import 'package:otp/otp.dart';


List<String> imgList = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

class BioContainer extends StatefulWidget {
  Key? key;
  // BootpayBioWebView? webView;
  BioPayload? payload;
  bool? showCloseButton;

  Widget? closeButton;
  BootpayDefaultCallback? onCancel;
  BootpayDefaultCallback? onError;
  BootpayCloseCallback? onClose;
  BootpayCloseCallback? onCloseHardware;
  BootpayDefaultCallback? onReady;
  BootpayConfirmCallback? onConfirm;
  BootpayDefaultCallback? onDone;


  BioContainer({
      this.key,
      this.payload,
      this.showCloseButton,
      this.closeButton,
      this.onCancel,
      this.onError,
      this.onClose,
      this.onCloseHardware,
      this.onReady,
      this.onConfirm,
      this.onDone}); // BioContainer(this.webView, this.payload);

  @override
  BioRouterState createState() => BioRouterState();
}

class BioRouterState extends State<BioContainer> {
  DateTime? currentBackPressTime = DateTime.now();

  final BioController c = Get.put(BioController());
  bool isShowWebView = false;

  BootpayBioWebView? webView;



  // init
  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    c.getWalletList(widget.payload?.userToken ?? "");
    createWebView();
  }

  createWebView() {
    webView = BootpayBioWebView(
      payload: widget.payload,
      showCloseButton: widget.showCloseButton,
      key: widget.key,
      closeButton: widget.closeButton,
      onCancel: widget.onCancel,
      onError: widget.onError,
      onClose: widget.onClose,
      onCloseHardware: widget.onCloseHardware,
      onReady: widget.onReady,
      onConfirm: widget.onConfirm,
      onDone: widget.onDone,
      onNextJob: onNextJob,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return WillPopScope(

      child: isShowWebView == false ? Wrap(
        children: [
          Container(
            height: 60,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  SizedBox(width: 50),
                  Expanded(child: Text(widget.payload?.pg ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700))),
                  Container(
                      width: 50,
                      child: IconButton(
                        icon: Image.asset('images/close.png', package: 'bootpay_bio'),
                        // icon: Image.asset('assets/close.png'),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            color: Colors.black12
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: ListView.builder(
              shrinkWrap: true,

              itemCount: (widget.payload?.prices?.length ?? 0) + 2,
              // separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (BuildContext context, int index) {

                double topPadding = 20.0;
                if(index != 0) { topPadding = 6.0; }
                double bottomPadding = 6.0;
                if(index == (widget.payload?.prices?.length ?? 0) + 1) { bottomPadding = 20.0; }

                return Padding(
                  padding: EdgeInsets.only(left: 0.0, right: 0.0, top: topPadding, bottom: bottomPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leftWidget(index, (widget.payload?.prices?.length ?? 0) + 2),
                      rightWidget(index, (widget.payload?.prices?.length ?? 0) + 2)
                    ],
                  ),
                );
              }),

            ),
          ),
          Obx(() =>
            Container(
              color: Colors.black12,
              height: 220,
              child: CarouselSlider(
                options: CarouselOptions(
                  aspectRatio: 2.0,
                  enlargeCenterPage: true,
                ),
                items: c.resWallet.value.wallets.map((e) => cardWidget(e)).toList() +  [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: const Color(0xFFf9faff),
                    ),
                    child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: () => addNewCard(),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset('images/ico_plus.png', package: 'bootpay_bio', width: 34.0),
                                  SizedBox(height: 12),
                                  Text('새로운 카드 등록', style: TextStyle(color: CardCode.COLOR_BLUE, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                        )
                    ),
                  ),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: CardCode.COLOR_BLUE
                    ),
                    child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: () => goTotalPay(),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset('images/ico_card.png', package: 'bootpay_bio', width: 34.0),
                                  SizedBox(height: 12),
                                  Text('다른 결제수단', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: CardCode.COLOR_BLUE
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => print(1234),
                      child: const Center(child: Text('결제하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0)))
                  )
                ),
              ),
            ),
          ),
        ],
      ) : Container(
        child: Column(
          children: [
            Container(height: 30.0, color: Colors.white),
            Expanded(
              child: webView!,
            ),
            Container(height: 10.0, color: Colors.white),
          ],
        ),
      ),
      onWillPop: () async {
        // DateTime now = DateTime.now();
        // if (now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
        //   currentBackPressTime = now;
        //   if(widget.webView?.onCloseHardware != null) widget.webView?.onCloseHardware!();
        //   Fluttertoast.showToast(msg: "\'뒤로\' 버튼을 한번 더 눌러주세요.");
        //   return Future.value(false);
        // }
        // return Future.value(true);
        if(webView?.onCloseHardware != null) webView?.onCloseHardware!();
        return Future.value(true);
      },
    );
  }

  addNewCard() async {
    if(!await isAblePasswordToken()) {
      c.requestType.value = BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD;
      showWebView();
      return;
    }
    c.requestType.value = BioConstants.REQUEST_ADD_CARD;
    showWebView();
  }

  startPayWithSelectedCard() async {
    widget.payload?.walletId = c.resWallet.value.wallets[c.selectedCardIndex].wallet_id;
    print(1);

    c.requestType.value = BioConstants.REQUEST_BIO_FOR_PAY;

    if(!await isAblePasswordToken()) {
      print(2);
      c.requestType.value = BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY;
      showWebView();
      return;
    }

    if(!await isAbleBioAuthDevice()) {
      print(3);
      goBioForPay();
      return;
    } else if(nowAbleBioAuthDevice()) {
      print(4);
      //기기활성화 먼저해야함
      goBioForEnableDevice();
      return;
    }
    print(5);
    requestPasswordForPay();
  }

  goBioForPay() {
    c.requestType.value = BioConstants.REQUEST_BIO_FOR_PAY;
    goBiometricAuth();
  }

  goBioForEnableDevice() {
    c.requestType.value = BioConstants.REQUEST_BIOAUTH_FOR_BIO_FOR_PAY;
    goBiometricAuth();
  }

  requestDeleteCard() {
    c.requestType.value = BioConstants.REQUEST_PASSWORD_FOR_PAY;
    showWebView();
  }

  requestPasswordForPay() {
    c.requestType.value = BioConstants.REQUEST_DELETE_CARD;
    showWebView();
  }

  goBiometricAuth() {

  }

  onNextJob(NextJob data) async {
    print(data.toJson());

    if(data.initToken) {
      setPasswordToken("");
      widget.payload?.token = "";
    } else if(data.token.isNotEmpty) {
      setPasswordToken(data.token.replaceAll("\"", ""));
      widget.payload?.token = data.token;
    }

    if(data.biometricDeviceUuid.isNotEmpty && data.biometricSecretKey.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("biometric_device_uuid", data.biometricDeviceUuid);
      prefs.setString("biometric_secret_key", data.biometricSecretKey);
    }

    if(data.nextType == BioConstants.NEXT_JOB_RETRY_PAY) {
      startPayWithSelectedCard();
    } else if(data.nextType == BioConstants.NEXT_JOB_ADD_NEW_CARD) {
      addNewCard();
    } else if(data.nextType == BioConstants.NEXT_JOB_ADD_DELETE_CARD) {
      requestDeleteCard();
    } else if(data.nextType == BioConstants.NEXT_JOB_GET_WALLET_LIST) {
      if(data.type == BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY) {
        getWalletList(true);
      } else {
        getWalletList(false);
      }
    }
  }

  getWalletList(bool requestBioPay) async {
    String userToken = widget.payload?.userToken ?? '';

    await c.getWalletList(userToken);

    if(requestBioPay == true) {
      requestBioForPay();
      return;
    }

    if(c.resWallet.value.biometric?.biometric_confirmed == false) {
      final prefs = await SharedPreferences.getInstance();
      if(c.resWallet.value.wallets.isEmpty) {
        prefs.setString("biometric_secret_key", "");
      }
      prefs.setString("password_token", "");
    }

    if(c.resWallet.value.wallets.isEmpty) {
      addNewCard();
    } else {
      showCardView();
    }
  }

  requestBioForPay() async {
    final prefs = await SharedPreferences.getInstance();
    String secretKey = prefs.getString("biometric_secret_key") ?? '';
    int serverUnixTime = c.resWallet.value.biometric?.server_unixtime ?? 0;

    c.otp = getOTPValue(secretKey, serverUnixTime);
    c.requestType.value = BioConstants.REQUEST_BIO_FOR_PAY;
    showWebView();
  }

  String getOTPValue(String secretKey, int serverTime) {
    // Generate TOTP code. (String versin of function incase of leading 0)
    return OTP.generateTOTPCodeString(secretKey, serverTime);
  }

  setPasswordToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("password_token", token);
  }

  // addNewCard() {
  //
  // }

  Future<bool> isAblePasswordToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String passwordToken =  prefs.getString('password_token') ?? '';
    return passwordToken.isNotEmpty;
  }

  Future<bool> isAbleBioAuthDevice() async {
    return await didAbleBioAuthDevice() && nowAbleBioAuthDevice();
  }


  Future<bool> didAbleBioAuthDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String biometric_secret_key =  prefs.getString('biometric_secret_key') ?? '';
    return (c.resWallet.value.biometric?.biometric_confirmed ?? false) && biometric_secret_key.isNotEmpty;
  }

  bool nowAbleBioAuthDevice() {
    // return bioFailCount <= 3;
    return true;
  }

  goTotalPay() {
    c.requestType.value = BioConstants.REQUEST_TOTAL_PAY;
    showWebView();
  }

  showWebView() {
    if(isShowWebView == false) {
      setState(() {
        isShowWebView = true;
      });
    }
  }

  showCardView() {
    if(isShowWebView == true) {
      setState(() {
        isShowWebView = false;
      });
    }
  }

  Widget leftWidget(int index, int max) {
    // print("index: $index, max: $max, max1: ${(widget.payload?.prices?.length ?? 0)}");
    String label = '결제정보';
    if(index > 0 && index < max - 1) label = widget.payload!.prices![index-1].name ?? '';
    else if(index == max - 1) { label = '총 결제금액'; }
    return Text(label);
  }

  Widget rightWidget(int index, int max) {
    if(index == 0) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(widget.payload!.orderName ?? ''),
            Text(widget.payload!.names!.join(', '), maxLines: 2, textAlign: TextAlign.justify, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black38, fontSize: 12.0))
          ],
        ),
      );
    } else if(index > 0 && index < max - 1) {
      return Text(widget.payload!.prices![index-1].priceComma);
    } else {
      return Text(widget.payload!.priceComma, style: TextStyle(color: CardCode.COLOR_BLUE, fontSize: 18.0, fontWeight: FontWeight.bold));
    }
  }

  Widget cardWidget(WalletData walletData) {
    return  Container(
      height: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: CardCode.getColorBackground(walletData.batch_data.card_company_code ?? '')
      ),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: () {
                c.selectedCardIndex = c.resWallet.value.wallets.indexOf(walletData);
                startPayWithSelectedCard();
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                              walletData.batch_data.card_company ?? '',
                              style: TextStyle(color: CardCode.getColorText(walletData.batch_data.card_company_code ?? ''), fontWeight: FontWeight.bold)
                          ),
                          Expanded(child: Container())
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Container()),
                          Text(
                              walletData.batch_data.card_no ?? '',
                              style: TextStyle(color: CardCode.getColorText(walletData.batch_data.card_company_code ?? ''), fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
          )
      ),
    );
  }
}