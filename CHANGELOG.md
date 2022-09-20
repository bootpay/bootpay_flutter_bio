## 4.3.7
* 카드등록, 삭제시 confirm 함수를 호출하는 현상은 버그로 정리, 수정  
* 카드 연속해서 등록시 이상현상 버그 수정 

## 4.3.6
* 생체인증 결제 진행 후, 비밀번호 결제 진행시 토큰만료 관련 버그 수정
* 리팩토링 
* 생체인증 분리 승인일때, confirm 후 close 호출되도록 수정 

## 4.3.5
* 셍체인증 진행시 bio 인증을 할 수 없으면 비밀번호 결제로 대체하여 진행 

## 4.3.4
* setState 호출 전 mounted 체크 추가 

## 4.3.3
* 비밀번호 결제 버그 수정 

## 4.3.2
* bootpay 4.3.2 적용
* confirm async 지원

## 4.3.1
* bootpay_webview_flutter 3.2.21 적용 
* bootpay 4.3.1 적용 
* event async 지원 

## 4.3.0
* 중요 
* 간편결제는 생체인증, 통합결제 2가지를 사용중 
* 간편결제시 서버 분리 승인 로직을 추가하면서 사이드 이펙트가 생긴것을 확인하여 아래와 같이 수정함
  * 발견된 사이드 이펙트는 서버 승인 로직이 추가되면서 클라이언트에서 간편결제 승인이 진행되지 않는 것임 (separatelyConfirmed 옵션 기본값이 true)
  * 수정사항) extra -> bio_extra 모델로 대체 
    * bio_extra.separatelyConfirmed 옵션은 통합결제에만 적용되도록 수정 
    * bio_extra.separatelyConfirmedBio 옵션은 간편결제에만 적용되도록 수정 
      - 단 이 옵션이 true일 경우 특성상 서버승인으로만 진행을 해야함 

## 4.2.9
* bootpay js 4.2.2 적용 
* bootpay 4.2.7 적용 

## 4.2.8
* extra.separatelyConfirmed 옵션 일 경우 done -> confirm 으로 이벤트를 주는 것으로 수정 

## 4.2.7
* android 기기에서 onClose가 호출이 간헐적으로 안되는 버그 수정 

## 4.2.6
* bootpay 4.2.6 적용 
* debounceClose 개선시도 (재현이 안되는 버그가 있음)
* bootpay js 4.2.1 적용

## 4.2.4
* 결제수단 삭제 기능 추가 
* 결제수단 편집 API 추가 

## 4.2.3
* bootpay bio 결제창 커스텀 테마 가능하도록 업데이트 

## 4.2.2
* bootpay 4.2.5 적용
* bootpay js 4.2.0 적용
* 생체인증 결제진행시 해당 화면사이즈에서 결제진행하도록 수정
* closeHardware 제거, debounce close 적용 

## 4.2.1
* 생체인증 결제 인증취소시 예외처리 추가 

## 4.2.0
* bootpay js 4.1.0 적용 

## 4.1.6
* 생체인증 결제 후 비밀번호 결제시 간헐적 버그 수정

## 4.1.5
* 생체인증 결제 후 비밀번호 결제시 간헐적 버그 수정

## 4.1.4
* 생체인증 결제 후 비밀번호 결제시 간헐적 버그 수정 

## 4.1.3
* onReady -> onIssued renamed

## 4.1.2
* boot_extra, boot_item 삭제 
* 예제 update 

## 4.1.1
* bootpay 4.1.1 반영

## 4.1.0
* bootpay 4.1.0 반영 
* 생체인식 카드 케로셀 버그 수정 (ipad)


## 4.0.9
* 비밀번호 간편결제 password_token 만료시 창 닫지않고, 재갱신해서 로직수행하도록 버그 수정 

## 4.0.8
* 비밀번호 간편결제 지원

## 4.0.7
* flutter bio 공식 지원 
