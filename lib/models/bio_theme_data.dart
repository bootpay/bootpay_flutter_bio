import 'dart:convert';
import 'dart:io';

import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bio_price.dart';
import '../extension/json_query_string.dart';
import 'package:intl/intl.dart';
import 'dart:convert';


class BioThemeData {

  Widget? titleWidget;

  Color? bgColor;
  Color? textColor;
  Color? priceColor;

  Color? card1Color; //카드 배경 1
  Color? cardText1Color; //카드 텍스트 1
  Color? card2Color; //카드 배경 2
  Color? cardText2Color; //카드 텍스트 1
  Color? cardBgColor; //카드 배경 2
  Color? cardIconColor; //아이콘 색상

  Color? buttonBgColor;
  Color? buttonTextColor;

  BioThemeData({
      this.titleWidget,
      this.bgColor,
      this.textColor,
      this.priceColor,
      this.card1Color,
      this.cardText1Color,
      this.card2Color,
      this.cardText2Color,
      this.cardBgColor,
      this.cardIconColor,
      this.buttonBgColor,
      this.buttonTextColor});

// BioThemeData({this.bgColor, this.textColor, this.buttonBgColor, this.buttonTextColor, this.pointColor, this.cardColor, this.cardBgColor, this.titleWidget});
}