## 5.0.15
* 최신폰(S25)에서 생체인증 결제 버그 수정

## 5.0.14
* 다른 결제수단 버그 수정 

## 5.0.12
* android webview version update

## 4.9.1
* android webview ssl error 개선 

## 4.9.0
* bootpay webview android 삼성폰 버그 개선 
* extra isShowTotalPay 옵션 추가 

## 4.6.4
* bootpay version update
* 비밀번호 자동결제 추가 

## 4.5.1
* more_horiz icon customization option provided
* BootPay version update

## 4.5.0
* BootPay version update

## 4.4.8
* Close the easy payment window


## 4.4.7
* A number of logical changes in the amount that does not go to the full input window in ios at the end of precision

## 4.4.6
* Since debounce close is not called when showModal is closehill, add immediate execution logic

## 4.4.5
* Improved cancellation returned as an error to cancellation

## 4.4.4
* BootPay 4.4.2 update

## 4.4.3
* apply bootpay_webview 3.x

## 4.4.2
*Improved the problem that close was responded first during comprehensive payment intermittently

## 4.4.1
* Modified so that the conditional issuance completion window is displayed when issuing a virtual payment in the integrated payment window

## 4.4.0
* Added a function to keep the custom theme even in the payment method deletion pop-up window
* Original bioTheme.buttonBgColor -> modified to bioTheme.buttonActiveColor

## 4.3.9
* Improved the phenomenon that the card list is refreshed intermittently when adding or deleting a card

## 4.3.8
* When registering or deleting a card, if it does not close immediately and continues, it is processed gradually
* Improved usability for users working and ongoing requests

## 4.3.7
* Arranged and corrected a bug requesting confirmation when registering or deleting a card
* Fix abnormal bug when registering cards consecutively

## 4.3.6
* Fixed bug related to token expiry when proceeding with password payment after biometric authentication payment
* Refactoring
* Modified so that close is called after confirmation when biometric separation approval is given

## 4.3.5
* If bio authentication is not possible during biometric authentication, proceed with password payment instead.

## 4.3.4
* Added mounted check before calling setState

## 4.3.3
* Fixed password payment bug

## 4.3.2
* Apply bootpay 4.3.2
* confirm async support

## 4.3.1
* Apply bootpay_webview_flutter 3.2.21
* Apply bootpay 4.3.1
* event async support

## 4.3.0
* important
* For simple payment, biometric authentication and integrated payment are being used.
* After adding server separation approval logic during simple payment, it was confirmed that a side effect occurred and modified as follows.
  * The discovered side effect is that simple payment approval is not processed on the client as server approval logic is added (separatelyConfirmed option default value is true)
  * Fix) Extra -> replaced with bio_extra model
    * The bio_extra.separatelyConfirmed option is modified to apply only to integrated payment.
    * The bio_extra.separatelyConfirmedBio option is modified to apply only to simple payment.
      - However, if this option is true, you must proceed only with server approval due to its nature.

## 4.2.9
* apply bootpay js 4.2.2
* apply bootpay 4.2.7

## 4.2.8
* In the case of the extra.separatelyConfirmed option, it is modified to give an event as done -> confirm

## 4.2.7
* Fixed a bug where onClose could not be called intermittently on android devices

## 4.2.6
* Apply bootpay 4.2.6
* Attempt to improve debounceClose (there is a bug that cannot be reproduced)
* apply bootpay js 4.2.1

## 4.2.4
* Added payment method deletion function
* Payment method edit API added

## 4.2.3
* Bootpay bio payment window custom theme updated

## 4.2.2
* apply bootpay 4.2.5
* apply bootpay js 4.2.0
* Modified to proceed with payment in the corresponding screen size when proceeding with biometric authentication payment
* Remove closeHardware, apply debounce close

## 4.2.1
* Addition of exception handling when biometric payment authentication is canceled

## 4.2.0
* apply bootpay js 4.1.0

## 4.1.6
* Fixed intermittent bug when paying password after biometric payment

## 4.1.5
* Fixed intermittent bug when paying password after biometric payment

## 4.1.4
* Fixed intermittent bug when paying password after biometric payment

## 4.1.3
* onReady -> onIssued renamed

## 4.1.2
* Delete boot_extra, boot_item
* example update

## 4.1.1
* Reflect bootpay 4.1.1

## 4.1.0
* Reflect bootpay 4.1.0
* Fixed biometric card kerosell bug (ipad)


## 4.0.9
* Fixed a bug so that when the password easy payment password_token expires, the window is not closed, and the logic is performed by renewing

## 4.0.8
* Password easy payment support

## 4.0.7
* Flutter bio official support
