import 'dart:async';
import 'package:bootpay/bootpay.dart';
import 'package:bootpay_bio/constants/bio_constants.dart';
import 'package:bootpay_bio/constants/card_code.dart';
import 'package:bootpay_bio/controller/bio_controller.dart';
import 'package:bootpay_bio/models/bio_payload.dart';
import 'package:bootpay_bio/models/wallet/next_job.dart';
import 'package:bootpay_bio/models/wallet/wallet_data.dart';
import 'package:bootpay_bio/webview/bio_webview.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import 'bootpay_bio.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';


import 'package:otp/otp.dart';

import 'config/bio_config.dart';
import 'controller/bio_debounce_close_controller.dart';
import 'models/bio_theme_data.dart';
import 'provider/api_webview_provider.dart';


typedef void BootpayNextJobCallback(NextJob data);

class BioContainer extends StatefulWidget {


  final BioController c = Get.put(BioController());

  Key? key;
  BioWebView? webView;
  BioPayload? payload;
  BioThemeData? themeData;
  bool? showCloseButton;

  Widget? closeButton;
  BootpayDefaultCallback? onCancel;
  BootpayDefaultCallback? onError;
  BootpayCloseCallback? onClose;
  // BootpayCloseCallback? onCloseHardware;
  BootpayDefaultCallback? onIssued;
  BootpayConfirmCallback? onConfirm;
  BootpayAsyncConfirmCallback? onConfirmAsync;
  BootpayDefaultCallback? onDone;
  bool? isPasswordMode;
  bool? isEditMode;


  BioContainer({
      this.key,
      this.payload,
      this.showCloseButton,
      this.themeData,
      this.closeButton,
      this.onCancel,
      this.onError,
      this.onClose,
      // this.onCloseHardware,
      this.onIssued,
      this.onConfirm,
      this.onConfirmAsync,
      this.onDone,
      this.isPasswordMode,
      this.isEditMode,
  }) {
  } // BioContainer(this.webView, this.payload);

  @override
  BioRouterState createState() => BioRouterState();

  transactionConfirm() {
    // webView?.transactionConfirm();
    c.webViewProvider?.transactionConfirm();
  }
}

class BioRouterState extends State<BioContainer> {
  final BioDebounceCloseController closeController = Get.put(BioDebounceCloseController());

  DateTime? currentBackPressTime = DateTime.now();


  int currentCardIndex = 0;


  String _selectedValue = "일시불";

  get isShowQuotaSelectBox => (widget.payload?.price ?? 0 ) >= 50000 && widget.c.resWallet.value.wallets.isNotEmpty;

  // init
  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    widget.c.isPasswordMode = widget.isPasswordMode ?? false;
    if(widget.isPasswordMode == true) {
      setPasswordToken('');
    }
    createWebView();
    widget.c.initValues(createWebViewProvider(), widget.payload!);
    widget.c.initCallbackEvent(
      widget.onCancel,
      widget.onError,
      widget.onClose,
      widget.onIssued,
      widget.onConfirm,
      widget.onConfirmAsync,
      widget.onDone,
      onNextJob,
      bootpayClose
    );
    // widget.c

    widget.c.getWalletList(widget.payload?.userToken ?? "").then((value) {
      if(value) updateSelectedCardIndexForButton();
    });

    // auth.isDeviceSupported().then(
    //       (bool isSupported) => setState(() => _supportState = isSupported
    //       ? _SupportState.supported
    //       : _SupportState.unsupported),
    // );
  }


  @override
  void dispose() {
    bootpayClose();
    super.dispose();
  }


  createWebView() {
    widget.webView = BioWebView(
      payload: widget.payload,
      showCloseButton: widget.showCloseButton,
      key: widget.key,
      closeButton: widget.closeButton,
      isEditMode: widget.isEditMode,
    );
    widget.webView?.onProgressShow = (isShow) {
      updateProgressShow(isShow);
    };
  }

  ApiWebviewProvider createWebViewProvider() {
    return ApiWebviewProvider(
        widget,
        widget.webView!,
        widget.onCancel,
        widget.onError,
        widget.onClose,
        widget.onIssued,
        widget.onConfirm,
        widget.onConfirmAsync,
        widget.onDone,
        onNextJob
    );
  }


  void bootpayClose() {
    closeController.bootpayClose(widget.onClose);
  }

  void updateProgressShow(bool isShow) {
    // BootpayPrint("onProgressShow11 : $isShow");
    // setState(() {
    //   isProgressShow = isShow;
    // });
  }

  Color get bgColor => widget.themeData?.bgColor ?? Colors.white;
  Color get textColor => widget.themeData?.textColor ?? const Color(0xFF3B3B46);
  Color get priceColor => widget.themeData?.priceColor ?? CardCode.COLOR_BLUE;

  Color get card1Color => widget.themeData?.card1Color ?? const Color(0xFFf9faff);
  Color get cardText1Color => widget.themeData?.cardText1Color ?? CardCode.COLOR_BLUE;
  Color get card2Color => widget.themeData?.card2Color ??  CardCode.COLOR_BLUE;
  Color get cardText2Color => widget.themeData?.cardText2Color ?? const Color(0xFFf9faff);
  Color get cardBgColor => widget.themeData?.cardBgColor ?? const Color(0x12000000);
  Color get cardIconColor => widget.themeData?.cardIconColor ?? CardCode.COLOR_BLUE;

  Color get buttonBgColor => widget.themeData?.buttonBgColor ?? CardCode.COLOR_BLUE;
  Color get buttonTextColor => widget.themeData?.buttonTextColor ?? Colors.white;

  Widget payInfoContainer() {
    return widget.isEditMode == true ? Container() : Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,

            itemCount: (widget.payload?.prices?.length ?? 0) + 2,
            // separatorBuilder: (BuildContext context, int index) => Divider(),

            itemBuilder: (BuildContext context, int index) {

              double topPadding = 20.0;
              if(index != 0) { topPadding = 6.0; }
              if(index == (widget.payload?.prices?.length ?? 0) + 1) { topPadding = 4.75;}

              double bottomPadding = 6.0;
              if(index == (widget.payload?.prices?.length ?? 0) + 1) { bottomPadding = 20.0; }

              return Container(
                child: Padding(
                  padding: EdgeInsets.only(left: 0.0, right: 0.0, top: topPadding, bottom: bottomPadding),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        leftWidget(index, (widget.payload?.prices?.length ?? 0) + 2),
                        rightWidget(index, (widget.payload?.prices?.length ?? 0) + 2)
                      ],
                    ),
                  ),
                ),
              );
            }),

      ),
    );
  }

  List<Widget> cardScrollChildrenWidget() {
    if(widget.isEditMode == true) {
      return widget.c.resWallet.value.wallets.map((e) => cardWidget(e)).toList() +  [
        Container(
          // height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: card1Color,
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
                        CircleAvatar(
                            backgroundColor: cardIconColor,
                            child: Image.asset('images/ico_plus_outline.png', package: 'bootpay_bio', width: 34.0, color: card1Color)
                        ),
                        SizedBox(height: 12),
                        Text('새로운 카드 등록', style: TextStyle(color: cardText1Color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
              )
          ),
        ),
      ];
    }

    return widget.c.resWallet.value.wallets.map((e) => cardWidget(e)).toList() +  [
      Container(
        // height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: card1Color,
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
                      CircleAvatar(
                          backgroundColor: cardIconColor,
                          child: Image.asset('images/ico_plus_outline.png', package: 'bootpay_bio', width: 34.0)
                      ),
                      SizedBox(height: 12),
                      Text('새로운 카드 등록', style: TextStyle(color: cardText1Color, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
            )
        ),
      ),
      Container(
        // height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: card2Color
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
                      CircleAvatar(
                          backgroundColor: card1Color,
                          child: Image.asset('images/ico_card_outline.png', package: 'bootpay_bio', width: 34.0, color: cardIconColor)
                      ),
                      SizedBox(height: 12),
                      Text('다른 결제수단', style: TextStyle(color: cardText2Color, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
            )
        ),
      ),
    ];
  }


  Widget cardContainer(double cardViewHeight) {
    // if(isShowWebViewHalfSize) {
    //   return  SizedBox(
    //     height: cardViewHeight,
    //     // child: widget.webView!,
    //     child: widget.webView!,
    //   );
    // }

    return Container(
      color: bgColor,
      child: Column(
        children: [

          Container(
            height: 50,
            // color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  SizedBox(width: 40),
                  Expanded(child:
                    widget.themeData?.titleWidget ?? Text(
                        '등록된 결제수단',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: textColor)
                    )
                  ),
                  SizedBox(
                      width: 40,
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: Image.asset('images/close.png', package: 'bootpay_bio', color: textColor),
                          // icon: Image.asset('assets/close.png'),
                          iconSize: 20,
                          onPressed: () {
                            if (widget.onCancel != null) {
                              widget.onCancel!('{"action":"BootpayCancel","status":-100,"message":"사용자에 의한 취소"}');
                            }
                            bootpayClose();
                            // if (widget.onClose != null) {
                            //   widget.onClose!();
                            // }
                            BootpayBio().dismiss(context);
                            // Navigator.of(context).pop();
                          },
                        ),
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
          payInfoContainer(),
          Obx(() =>
              Container(
                // color: Color(0xFFEDEDED),
                color: cardBgColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: Container(
                    width: double.infinity,
                    height: cardViewHeight,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          if(mounted) {
                            setState(() {
                              currentCardIndex = index;
                            });
                          }
                        }
                      ),
                      items: cardScrollChildrenWidget(),
                    ),
                  ),
                ),
              ),
          ),
          isShowQuotaSelectBox ? Column(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,

                    value: _selectedValue,
                    items: widget.c.cardQuotaList.map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),

                    )).toList(),
                    onChanged: (e) {
                      _selectedValue = e.toString();
                      widget.c.setCardQuota(_selectedValue);
                    },
                  )
              ),
              SizedBox(height: 60)
            ],

          ) : Container(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Stack(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: buttonBgColor,
                  ),
                  child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                          onTap: () {
                            clickCardButton();
                          },
                          child: Center(child: Text(cardButtonTitle(), style: TextStyle(color: buttonTextColor, fontWeight: FontWeight.w600, fontSize: 16.0)))
                      )
                  ),
                ),
                widget.c.isShowWebViewHalfSize.value == true ? SizedBox(
                  height: 50,
                  child: Opacity(
                      opacity: 0.2,
                      child: widget.webView
                  ),
                ) : Container(),
                widget.c.isShowWebViewHalfSize.value == true ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 7.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                ) : Container()
              ],
            ),
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }

  String cardButtonTitle() {
    int index = widget.c.resWallet.value.wallets.length - currentCardIndex;
    if(index == 0 ) {
      return "새로운 카드 등록하기";
    } else if(index == -1) {
      return "다른 결제수단으로 결제하기";
    } else {
      return widget.isEditMode == true ? "이 카드를 편집하기" :  "이 카드로 결제하기";
    }
  }

  void clickCardButton() {
    int index = widget.c.resWallet.value.wallets.length - currentCardIndex;
    if(index == 0 ) {
      addNewCard();
    } else if(index == -1) {
      goTotalPay();
    } else {
      widget.c.selectedCardIndex = currentCardIndex;
      startPayWithSelectedCard();
      // if(widget.c.selectedCardIndex >= 0) {
      //   startPayWithSelectedCard();
      // }

      // return "이 카드로 결제하기";
    }
  }


  Widget webviewContainer(BuildContext context) {
    double height = MediaQuery.of(context).size.height - 50;

    return Container(
      height: height,
      // child: widget.webView!,
      child: Column(
        children: [
          // Container(height: 10.0, color: Colors.white),
          Expanded(
            child: widget.webView!,
          ),
          Container(height: 20.0, color: Colors.white),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    double cardViewHeight = MediaQuery.of(context).size.width * 0.6;

    return WillPopScope(
      child: Wrap(

        children: [
          Obx(() =>
            widget.c.isShowWebView.value == false || widget.c.isShowWebViewHalfSize.value == true ? cardContainer(cardViewHeight) : webviewContainer(context)
          )

        ],
      ),
      onWillPop: () async {
        // if(widget.webView?.onCloseHardware != null) widget.webView?.onCloseHardware!();
        return Future.value(true);
      },
    );
  }

  addNewCard() async {
    // if(!await isAblePasswordToken()) {
    //   widget.c.requestPasswordToken(type: BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD, doWorkNow: false);
    //   showWebView();
    //   return;
    // }

    widget.c.addNewCard(doWorkNow: false);
    showWebView();
  }



  startPayWithSelectedCard() async {
    BootpayPrint("startPayWithSelectedCard : ${widget.c.requestType.value}");

    // BootpayPrint("widget.c.selectedCardIndex: ${widget.c.selectedCardIndex}, wallets: ${widget.c.resWallet.value.wallets.length}");
    widget.payload?.walletId = widget.c.resWallet.value.wallets[widget.c.selectedCardIndex].wallet_id;
    widget.c.payload?.walletId = widget.c.resWallet.value.wallets[widget.c.selectedCardIndex].wallet_id;

    if(widget.isEditMode == true) {
      alertDialogDeleteConfirm(widget.c.resWallet.value.wallets[widget.c.selectedCardIndex]);
      return;
    }

    if(widget.c.isPasswordMode) {
      requestPasswordForPay();
      return;
    }

    // widget.c.requestType.value = BioConstants.REQUEST_BIO_FOR_PAY;

    if(!await isAblePasswordToken()) {
      // widget.c.requestType.value = BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY;
      // showWebView();
      widget.c.requestPasswordToken(type: BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY, doWorkNow: false);
      showWebView();
      return;
    }

    if(await isAbleBioAuthDevice()) {
      goBioForPay();
      return;
    } else if(nowAbleBioAuthDevice()) {
      //기기활성화 먼저해야함
      goBioForEnableDevice();
      return;
    }
    requestPasswordForPay();
  }

  goBioForPay() {
    // widget.c.requestType.value = BioConstants.REQUEST_BIO_FOR_PAY;
    goBiometricAuth(BioConstants.REQUEST_BIO_FOR_PAY);
  }

  goBioForEnableDevice() {
    // widget.c.requestType.value = BioConstants.REQUEST_BIOAUTH_FOR_BIO_FOR_PAY;
    goBiometricAuth(BioConstants.REQUEST_BIOAUTH_FOR_BIO_FOR_PAY);
  }

  requestDeleteCard({WalletData? walletData}) async {
    if(walletData != null) {
      widget.payload?.walletId = walletData.wallet_id;
      // widget.webView?.payload = widget.payload;
      widget.c.payload?.walletId = walletData.wallet_id;
    }

    // showWebView();
    if(!await isAblePasswordToken()) {
      if(widget.c.isShowWebView.value == true) {
        widget.c.requestPasswordToken(type: BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD);
      } else {
        widget.c.requestPasswordToken(type: BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD, doWorkNow: false);
        showWebView();
      }
      return;
    }


    if(widget.c.isShowWebView.value == true) {
      widget.c.requestDeleteCard();
    } else {
      widget.c.requestDeleteCard(doWorkNow: false);
      showWebView();
    }
  }

  //무조건 비밀번호를 얻는 쪽으로 하자
  requestPasswordForPay() async {
    updateProgressShow(true);

    if(!await isAblePasswordToken()) {
      if(widget.c.isShowWebView.value == true) {
        // widget.webView?.requestPasswordToken();
        widget.c.requestPasswordToken(type: BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY);
      } else {
        widget.c.requestPasswordToken(type: BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY, doWorkNow: false);
        showWebView();
      }
      return;
    }

    if(widget.c.isShowWebView.value == true) {
      widget.c.requestPasswordForPay();
    } else {
      widget.c.requestPasswordForPay(doWorkNow: false);
      showWebView();
    }

    // if(widget.c.isShowWebView.value == true) {
    //   // widget.webView?.requestPasswordToken();
    //   widget.c.requestPasswordToken(type: BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY);
    // } else {
    //   widget.c.requestPasswordToken(type: BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY, doWorkNow: false);
    //   showWebView();
    // }
  }

  requestAddBioData(int type) {
    BootpayPrint("requestAddBioData : $type");
    updateProgressShow(true);

    // widget.c.requestType.value = type;
    if(widget.c.isShowWebView.value == true) {
      widget.c.requestAddBioData(type: type);
    } else {
      widget.c.requestAddBioData(type: type, doWorkNow: false);
      showWebView(isShowWebViewHalf: true);
    }
  }

  Future<bool> isAbleBioAuth(LocalAuthentication localAuth) async {
    final bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    final bool isDeviceSupported = await localAuth.isDeviceSupported();

    final List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();
    BootpayPrint("goBiometricAuth : $canCheckBiometrics, :$isDeviceSupported, ${availableBiometrics.map((e) => e.name).join(', ')}");


    return canCheckBiometrics && isDeviceSupported && availableBiometrics.isNotEmpty;
  }

  goBiometricAuth(int type) async {
    final LocalAuthentication localAuth = LocalAuthentication();


    if(!(await isAbleBioAuth(localAuth))) {
      // Fluttertoast.showToast(
      //     msg: "생체인식이 지원되지 않는 기기입니다. 비밀번호 결제로 진행합니다.",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.black54,
      //     textColor: Colors.white,
      //     fontSize: 16.0
      // );
      requestPasswordForPay();
      return;
    }

    try {

      bool authenticated = await localAuth.authenticate(
          localizedReason: '인증 후 결제가 진행됩니다',
          authMessages:  const <AuthMessages>[
            AndroidAuthMessages(
                signInTitle: '생체 인증 후 결제가 진행됩니다',
                biometricHint: ''
            ),
            IOSAuthMessages(
              localizedFallbackTitle: "생체 인증 후 결제가 진행됩니다"
            ),
          ],
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            biometricOnly: true
          )
      );


      // bool authenticated = await localAuth.authenticate(
      //     localizedReason:
      //     '인증 후 결제가 진행됩니다',
      //     androidAuthStrings: AndroidAuthMessages(
      //       signInTitle: '생체 인증',
      //       biometricHint: ''
      //     ),
      //     iOSAuthStrings: IOSAuthMessages(
      //       localizedFallbackTitle: "비밀번호를 입력해주세요"
      //     ),
      //     // stickyAuth: true,
      //     useErrorDialogs: true);

      if(authenticated) {
        onAuthenticationSucceeded(type);
      } else {
        if(widget.onCancel != null) { widget.onCancel!('{"action":"BootpayCancel","status":-100,"message":"인증이 취소되었거나 실패하였습니다."}'); }
        bootpayClose();
        // if(widget.onClose != null) { widget.onClose!(); }
        // BootpayBio().dismiss(context);
      }
    } on PlatformException catch (e) {
      if(widget.onError != null) { widget.onError!(e.toString()); }
      bootpayClose();
      // if(widget.onClose != null) { widget.onClose!(); }
      // BootpayBio().dismiss(context);
      // Widget.on
    }
  }

  onAuthenticationSucceeded(int type) {
    onVibration();

    BootpayPrint("onAuthenticationSucceeded : $type, ${widget.c.requestType.value}");

    if(type == BioConstants.REQUEST_ADD_BIOMETRIC) {
      requestAddBioData(BioConstants.REQUEST_ADD_BIOMETRIC);
    } else if(type == BioConstants.REQUEST_BIOAUTH_FOR_BIO_FOR_PAY) {
      requestAddBioData(BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY);
    } else if(type == BioConstants.REQUEST_BIO_FOR_PAY) {
      requestBioForPay();
    }
  }

  onVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200, amplitude: 64);
    }
  }

  onNextJob(NextJob data) async {
    BootpayPrint("onNextJob: ${data.toJson()}");

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
      prefs.setInt("server_unixtime", data.serverUnixtime);
    }

    if(data.nextType == BioConstants.NEXT_JOB_RETRY_PAY) {
      startPayWithSelectedCard();
    } else if(data.nextType == BioConstants.NEXT_JOB_ADD_NEW_CARD) {
      addNewCard();
    } else if(data.nextType == BioConstants.NEXT_JOB_ADD_DELETE_CARD) {
      requestDeleteCard();
    } else if(data.nextType == BioConstants.REQUEST_PASSWORD_FOR_PAY) {
      requestPasswordForPay();
    } else if(data.nextType == BioConstants.REQUEST_DELETE_CARD) {
      requestDeleteCard(); //토큰 받아왔으니 재시도
    } else if(data.nextType == BioConstants.NEXT_JOB_GET_WALLET_LIST) {
      if(data.type == BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY) {
        getWalletList(true);
      } else {
        getWalletList(false);
      }
    }
    // else if()
  }

  updateSelectedCardIndexForButton() {

    if(widget.c.resWallet.value.wallets.isNotEmpty) {
      if(widget.c.selectedCardIndex < 0) {
        if(mounted) {
          setState(() {
            widget.c.selectedCardIndex = 0;
          });
        }
      }
    }
  }

  getWalletList(bool requestBioPay) async {
    String userToken = widget.payload?.userToken ?? '';

    await widget.c.getWalletList(userToken);
    updateSelectedCardIndexForButton();

    if(requestBioPay == true) {
      requestBioForPay();
      return;
    }


    if(widget.c.resWallet.value.biometric?.biometric_confirmed == false) {
      final prefs = await SharedPreferences.getInstance();
      if(widget.c.resWallet.value.wallets.isEmpty) {
        prefs.setString("biometric_secret_key", "");
      }
      prefs.setString("password_token", "");
    }

    if(widget.c.resWallet.value.wallets.isEmpty) {
      addNewCard();
    } else {
      showCardView();
    }
  }

  requestBioForPay() async {
    // isProgressShow
    updateProgressShow(true);

    final prefs = await SharedPreferences.getInstance();
    String secretKey = prefs.getString("biometric_secret_key") ?? '';
    int serverUnixTime = widget.c.resWallet.value.biometric?.server_unixtime ?? 0;

    BootpayPrint("key: $secretKey, time: $serverUnixTime, otp: ${widget.c.otp}, ${widget.c.isShowWebView.value}");

    if(widget.c.isShowWebView.value == true) {
      widget.c.requestBioForPay(getOTPValue(secretKey, serverUnixTime));
    } else {
      widget.c.requestBioForPay(getOTPValue(secretKey, serverUnixTime), doWorkNow: false);
      showWebView(isShowWebViewHalf: true);
    }
  }

  String getOTPValue(String secretKey, int serverTime) {
    try {
      return OTP.generateTOTPCodeString(secretKey, serverTime * 1000, length: 8, interval: 30, algorithm: Algorithm.SHA512, isGoogle: true);
    } catch(e) {
      BootpayPrint(e);
      return "";
    }
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
    BootpayPrint('isAblePasswordToken : $passwordToken, ${widget.c.requestType.value}');
    return passwordToken.isNotEmpty;
  }

  Future<bool> isAbleBioAuthDevice() async {
    return await didAbleBioAuthDevice() && nowAbleBioAuthDevice();
  }


  Future<bool> didAbleBioAuthDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String biometric_secret_key =  prefs.getString('biometric_secret_key') ?? '';
    BootpayPrint("didAbleBioAuthDevice: ${biometric_secret_key}, ${widget.c.resWallet.value.biometric?.biometric_confirmed}, ${(widget.c.resWallet.value.biometric?.biometric_confirmed ?? false) && biometric_secret_key.isNotEmpty}");
    return (widget.c.resWallet.value.biometric?.biometric_confirmed ?? false) && biometric_secret_key.isNotEmpty;
  }

  bool nowAbleBioAuthDevice() {
    // return bioFailCount <= 3;
    return true;
  }

  goTotalPay() {
    // widget.c.requestTotalPay();
    if(widget.c.isShowWebView.value == true) {
      // widget.c.requestBioForPay(getOTPValue(secretKey, serverUnixTime));
      widget.c.requestTotalPay();
    } else {
      // widget.c.requestBioForPay(getOTPValue(secretKey, serverUnixTime), doWorkNow: false);
      widget.c.requestTotalPay(doWorkNow: false);
      showWebView();
    }
  }

  showWebView({bool? isShowWebViewHalf}) {
    if(widget.c.isShowWebView.value == false) {
      if(mounted) {
        setState(() {
          widget.c.isShowWebView.value = true;
          if(isShowWebViewHalf != null) {
            widget.c.isShowWebViewHalfSize.value = isShowWebViewHalf;
          }
        });
      }
    }
  }

  showCardView() {
    if(widget.c.isShowWebView.value == true) {
      if(mounted) {
        setState(() {
          widget.c.isShowWebView.value = false;
          widget.c.isShowWebViewHalfSize.value = false;
        });
      }
    }
  }

  Widget leftWidget(int index, int max) {
    // print("index: $index, max: $max, max1: ${(widget.payload?.prices?.length ?? 0)}");
    String label = '결제정보';
    if(index > 0 && index < max - 1) label = widget.payload!.prices![index-1].name ?? '';
    else if(index == max - 1) { label = '총 결제금액'; }
    return Padding(
      padding: EdgeInsets.only(top: index == max - 1 ? 2.5 : 0.0),
      child: Text(label, style: TextStyle(color: textColor)),
    );
  }

  Widget rightWidget(int index, int max) {
    if(index == 0) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(widget.payload!.orderName ?? '', style: TextStyle(color: textColor)),
            Opacity(
              opacity: 0.5,
              child: Text(widget.payload!.names!.join(', '), maxLines: 2, textAlign: TextAlign.justify, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor))
            )
          ],
        ),
      );
    } else if(index > 0 && index < max - 1) {
      return Text(widget.payload!.prices![index-1].priceComma, style: TextStyle(color: textColor));
    } else {
      return Text(widget.payload!.priceComma, style: TextStyle(color: priceColor, fontSize: 18.0, fontWeight: FontWeight.w600));
    }
  }

  Future<void> alertDialogDeleteConfirm(WalletData walletData) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('카드 삭제', style: TextStyle(fontSize: 16)),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('등록된 카드를 삭제합니다.', style: TextStyle(fontSize: 14)),
                Text('정말 삭제하시겠습니까?', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                Navigator.of(context).pop();
                setPasswordToken(''); //결제수단 삭제 전 무조건 초기화하여, 비밀번호를 재입력하도록 한다
                requestDeleteCard(walletData: walletData);
              },
            ),
          ],
        );
      },
    );
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
                widget.c.selectedCardIndex = widget.c.resWallet.value.wallets.indexOf(walletData);
                startPayWithSelectedCard();
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 20.0, left: 20.0, right: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        walletData.batch_data.card_company ?? '',
                                        style: TextStyle(color: CardCode.getColorText(walletData.batch_data.card_company_code ?? ''), fontWeight: FontWeight.bold)
                                    ),
                                    SizedBox(height: 8),
                                    Image.asset('images/card_chip.png', package: 'bootpay_bio', height: 30.0),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.more_horiz, color: Colors.white),
                                // icon: Image.asset('assets/close.png'),
                                // iconSize: 20,
                                onPressed: () {
                                  alertDialogDeleteConfirm(walletData);

                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(child: Container()),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                                walletData.batch_data.card_no ?? '',
                                style: TextStyle(color: CardCode.getColorText(walletData.batch_data.card_company_code ?? ''), fontWeight: FontWeight.bold)
                            ),
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