
import 'dart:ui';

import 'package:flutter/material.dart';

class CardCode {
  static const String BC = "01";
  static const String KB = "02"; //국민카드
  static const String HN = "03"; //하나카드
  static const String SS = "04"; //삼성카드
  static const String SH = "06"; //신한카드
  static const String HD = "07"; //현대카드
  static const String LT = "08"; //롯데카드
  static const String CT = "11"; //씨티카드
  static const String NH = "12"; //농협카드
  static const String SH2 = "13"; //수협카드
  static const String SH3 = "14"; //신협카드
  static const String GJ = "21"; //광주카드
  static const String JB = "22"; //전북카드
  static const String JJ = "23"; //제주카드
  static const String SHCPT = "24"; //신한캐피탈카드
  static const String GVS = "25"; //해외비자
  static const String GMST = "26"; //해외마스터

  static const String GDNS = "27"; //해외디아너스카드
  static const String GAMX = "28"; //해외AMX
  static const String GJCB = "29"; //해외JCB
  static const String SKOK = "31"; //SK OK Cashbag
  static const String POST = "32"; //우체국

  static const String SM = "33"; //새마을체크카드
  static const String CH = "34"; //중국은행 체크카드
  static const String KDB = "35"; //KDB체크카드
  static const String HD2 = "36"; //현대증권 체크카드
  static const String JC = "37"; //저축은행


  static const Color COLOR_BC = Color(0xFF585657);
  static const Color COLOR_SH = Color(0xFF585657);
  static const Color COLOR_DEFAULT = Color(0xFFF7F7F7);

  static const Color COLOR_SM = Color(0xFF111822);
  static const Color COLOR_CH = Color(0xFFC4C0CA);

  static const Color COLOR_KDB = Color(0xFFd0f7fe);
  static const Color COLOR_HD2 = Color(0xFFE2E9FC);

  static const Color COLOR_LT = Color(0xFFd91822);
  static const Color COLOR_CT = Color(0xFF03397c);
  static const Color COLOR_NH = Color(0xFF095BAA);

  static const Color COLOR_SH2 = Color(0xFF0c61ae);
  static const Color COLOR_SH3 = Color(0xFF0e75c6);
  static const Color COLOR_JB = Color(0xFF052967);


  static const Color COLOR_JJ = Color(0xFF112269);
  static const Color COLOR_GVS = Color(0xFF075498);
  static const Color COLOR_GJCB = Color(0xFF0d0d0d);


  static const Color COLOR_BLUE = Color(0xFF507cf3);
  static const Color COLOR_NEW_CARD_BG = Color(0xFFf9faff);
  static const Color COLOR_NEW_CARD_BORDER = Color(0xFFdae4fd);

  static const Color COLOR_FONT = Color(0xFF3b3b46);
  static const Color COLOR_FONT_OPTION = Color(0xFFb3b3b3);
  static const Color COLOR_FONT_INFO = Color(0xFF666666);
  static const Color COLOR_PAGER_BG = Color(0xFFededed);

  static Color getColorText(String code) {
    switch (code) {
      case BC:
        return COLOR_BC;
      case KB:
        return Colors.white;
      case HN:
        return Colors.white;
      case SS:
        return Colors.white;
      case SH:
        return COLOR_SH;
      case HD:
        return Colors.black;
      case LT:
        return COLOR_LT;
      case CT:
        return COLOR_CT;
      case NH:
        return Colors.white;
      case SH2:
        return COLOR_SH2;
      case SH3:
        return COLOR_SH3;
      case GJ:
        return Colors.white;
      case JB:
        return COLOR_JB;
      case JJ:
      case SHCPT:
        return COLOR_JJ;
      case GVS:
        return COLOR_GVS;
      case GMST:
      case GDNS:
        return COLOR_GJCB;
      case GAMX:
        return Colors.white;
      case GJCB:
        return Colors.white;
      case SKOK:
      case POST:
        return Colors.white;
      case SM:
        return COLOR_SM;
      case CH:
        return COLOR_CH;
      case KDB:
        return COLOR_KDB;
      case HD2:
        return COLOR_HD2;
      case JC:
        return Colors.white;
      default:
        return COLOR_DEFAULT;
    }
  }


  static Color getColorBackground(String code) {

    switch (code) {
      case BC:
        return COLOR_NEW_CARD_BG;
      case KB:
        return const Color(0xFF73695F);
      case HN:
        return const Color(0xFF085baa);
      case SS:
        return const Color(0xFF3281f5);
      case SH:
      case HD:
      return COLOR_NEW_CARD_BG;
      case LT:
        return COLOR_DEFAULT;
      case CT:
      case SH2:
      case SH3:
        return COLOR_NEW_CARD_BG;
      case GJ:
        return const Color(0xFF49c7E6);
      case JB:
      case JJ:
      case SHCPT:
        return COLOR_NEW_CARD_BG;
      case GVS:
      case GMST:
      case GDNS:
        return COLOR_DEFAULT;
      case GAMX:
        return const Color(0xFF808080);
      case GJCB:
        return const Color(0xFF04317B);
      case SKOK:
        return COLOR_DEFAULT;
      case POST:
        return const Color(0xFF8062a6);
      case SM:
        return const Color(0xFF111822);
      case CH:
        return const Color(0xFFb34d4F);
      case KDB:
        return const Color(0xFF1dB7EE);
      case HD2:
        return const Color(0xFF808CAD);
      case JC:
        return const Color(0xFF423c3c);
      case NH:
        return const Color(0xFF095BAA);
      default:
        return COLOR_DEFAULT;
    }
  }
}