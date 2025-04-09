import 'dart:convert';
import 'dart:io';

import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:flutter/foundation.dart';

import 'bio_extra.dart';
import 'bio_price.dart';
import '../extension/json_query_string.dart';
import 'package:intl/intl.dart';
import 'dart:convert';


class BioPayload  {

  String? webApplicationId = '';
  String? androidApplicationId = '';
  String? iosApplicationId = '';

  String? pg = '';
  String? method = '';
  List<String>? methods = [];
  String? orderName = '';

  double? price = 0;
  double? taxFree = 0;

  String? orderId = '';
  // int? useOrderId = 0;
  String? subscriptionId = "";
  String? authenticationId = "";

  String? walletId = '';
  String? token = '';
  String? authenticateType = '';
  String? userToken = '';
  // String? easyType = 'easy_subscribe';
  String? easyType = '';
  Map<String, dynamic>? metadata = {};

  get priceComma => NumberFormat('###,###,###,###').format(price) + '원';

  // String? accountExpireAt = '';
  // bool showAgreeWindow = false;
  // String? userToken = '';

  // Extra? extra = Extra();
  BioExtra? extra = BioExtra();
  User? user = User();
  // List<Item>? items = [];
  List<Item>? items = [];



  List<String>? names = [];
  List<BioPrice>? prices = [];
  // int? imageResources = -1;


  BioPayload();

  BioPayload.fromJson(Map<String, dynamic> json) {
    androidApplicationId = json["android_application_id"];
    iosApplicationId = json["ios_application_id"];

    pg = json["pg"];
    method = json["method"];
    methods = json["methods"];
    orderName = json["orderName"];

    price = json["price"];
    taxFree = json["tax_free"];

    orderId = json["order_id"];
    // useOrderId = json["use_order_id"];


    subscriptionId = json["subscriptionId"];
    authenticationId = json["authenticationId"];
    walletId = json["walletId"];
    token = json["token"];
    authenticateType = json["authenticateType"];
    userToken = json["userToken"];

    metadata = json["metadata"];

    if(json["user"] != null) user = User.fromJson(json["user"]);
    if(json["extra"] != null) extra = BioExtra.fromJson(json["extra"]);
    if(json["items"] != null) items = json["items"].map((e) => Item.fromJson(e)).toList();

    names = json["names"];
    if(json["prices"] != null) prices = json["prices"].map((e) => BioPrice.fromJson(e)).toList();
  }


  //실제 사용되지 않음
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'application_id': getApplicationId(),
      'pg': pg,
      'method': method,
      'order_name': orderName,
      'price': price,
      'tax_free': taxFree,
      'order_id': orderId,
      'subscription_id': subscriptionId,
      'authentication_id': authenticationId,
      'wallet_id': walletId,
      'token': token,
      'authenticate_type': authenticateType,
      'easy_type': easyType,
      'user_token': userToken
    };
    if(this.methods != null && this.methods!.length > 0) {
      if(kIsWeb) result['methods'] = this.methods;
      else result['methods'] = methodListString();
    } else if(this.method != null && this.method!.length > 0) {
      result['method'] = this.method;
    }
    if(user != null) {
      result['user'] = user!.toJson();
    }
    if(extra != null) {
      result['extra'] = extra!.toJson();
    }
    if(items!.length > 0) {
      result['items'] = items!.map((e) => e.toJson()).toList();
    }

    return result;
  }


  getApplicationId() {
    if(kIsWeb) return this.webApplicationId;
    if(Platform.isIOS) return this.iosApplicationId;
    else return this.androidApplicationId;
  }

  //toJson 대신에 이 함수가 사용됨
  String toString() {
    return """
    {application_id: '${getApplicationId()}', 
     pg: '$pg', 
     method: '$method', 
     methods: ${methodListString()}, 
     order_name: '${orderName?.queryReplace()}', 
     price: $price, 
     tax_free: $taxFree, 
     order_id: '${orderId.queryReplace()}', 
     subscription_id: '$subscriptionId',
     authentication_id: '$authenticationId',      
     wallet_id: '$walletId', 
     token: '$token', 
     authenticate_type: '$authenticateType', 
     user_token: '$userToken',       
     easy_type: '$easyType',
     metadata: ${getMetadataStringAndroid()},
     extra: ${json.encode(extra?.toJson()).replaceAll("\"", "'")},
     user: ${user.toString()},
     items: ${getItems()}
   }
    """;

    // extra: ${json.encode(extra?.toJson())},
    // user_info: ${user.toString()},
    // items: ${getItems()}}
    // return "{application_id: '${getApplicationId()}', pg: '$pg', method: '$method', methods: ${methodListString()}, name: '${name.queryReplace()}', price: $price, tax_free: $taxFree, order_id: '${orderId.queryReplace()}', use_order_id: $useOrderId, params: ${getMetadataStringAndroid()}, account_expire_at: '$accountExpireAt', show_agree_window: $showAgreeWindow, user_token: '$userToken', extra: ${extra.toString()}, user_info: ${user.toString()}, items: ${getItems()}}";
  }

  String toTotalPay() {
    return """
    {application_id: '${getApplicationId()}', 
     pg: '$pg',  
     order_name: '${orderName?.queryReplace()}', 
     price: $price, 
     tax_free: $taxFree, 
     order_id: '${orderId.queryReplace()}', 
     subscription_id: '$subscriptionId',
     authentication_id: '$authenticationId',      
     wallet_id: '$walletId', 
     token: '$token', 
     authenticate_type: '$authenticateType', 
     user_token: '$userToken',       
     easy_type: '$easyType',
     metadata: ${getMetadataStringAndroid()},
     extra: ${json.encode(extra?.toJson()).replaceAll("\"", "'")},
     user: ${user.toString()},
     items: ${getItems()}
   }
    """;
  }


  //toJson 대신에 이 함수가 사용됨
  String toStringEasyPay() {
    return """
    {application_id: '${getApplicationId()}', 
     pg: '$pg', 
     method: '$method', 
     methods: ${methodListString()}, 
     order_name: '${orderName?.queryReplace()}', 
     price: $price, 
     tax_free: $taxFree, 
     order_id: '${orderId.queryReplace()}', 
     subscription_id: '$subscriptionId',
     authentication_id: '$authenticationId',      
     wallet_id: '$walletId', 
     token: '$token', 
     authenticate_type: '$authenticateType', 
     user_token: '$userToken',       
     easy_type: '$easyType',
     metadata: ${getMetadataStringAndroid()},
     extra: ${json.encode(extra?.toJsonEasyPay()).replaceAll("\"", "'")},
     user: ${user.toString()},
     items: ${getItems()}
   }
    """;

    // extra: ${json.encode(extra?.toJson())},
    // user_info: ${user.toString()},
    // items: ${getItems()}}
    // return "{application_id: '${getApplicationId()}', pg: '$pg', method: '$method', methods: ${methodListString()}, name: '${name.queryReplace()}', price: $price, tax_free: $taxFree, order_id: '${orderId.queryReplace()}', use_order_id: $useOrderId, params: ${getMetadataStringAndroid()}, account_expire_at: '$accountExpireAt', show_agree_window: $showAgreeWindow, user_token: '$userToken', extra: ${extra.toString()}, user_info: ${user.toString()}, items: ${getItems()}}";
  }



  String methodListString() {
    List<String> result = [];
    if(this.method != null) {
      for(String method in this.methods!) {
        result.add("\'$method\'");
      }
    }

    return "[${result.join(",")}]";
  }

  String getItems() {
    List<String> result = [];

    if(this.items != null) {
      for(Item item in this.items!) {
        result.add(item.toString());
      }
    }

    return "[${result.join(",")}]";
  }

  String getMetadataStringAndroid() {
    return reVal(json.encode(metadata));
    // return '{}';
  }

  String getParamsString() {
    if (metadata != null || metadata!.isEmpty) return "{}";
    return reVal(metadata.toString());
  }

  dynamic reVal(dynamic value) {
    if (value is String) {
      if (value.isEmpty) {
        return '';
      }
      return value.replaceAll("\"", "'");
    } else {
      return value;
    }
  }

  String getMethods() {
    if (methods != null || methods!.isEmpty) return '';
    String result = '';
    for (String method in methods!) {
      if (result.length > 0) result += ',';
      result += method;
    }
    return result;
  }


  // BioPayload.fromJson(Map<String, dynamic> json) {
  //   Payload.fromJson(json);
  //   names = json["names"];
  //   prices = json["prices"];
  //   imageResources = json["imageResources"];
  // }
  //
  // Map<String, dynamic> toJson() {
  //   Map<String, dynamic> result = super.toJson();
  //   result["names"] = names ?? [];
  //   result["prices"] = prices?.map((e) => e.toJson()) ?? [];
  //   result["image_resources"] = imageResources;
  //   return result;
  // }
}