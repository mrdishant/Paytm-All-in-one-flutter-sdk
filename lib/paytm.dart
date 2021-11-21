import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class Paytm {
  static const MethodChannel _channel = const MethodChannel('paytm');

  static Future<Map<dynamic, dynamic>> payWithPaytm({
    required String mId,
    required String orderId,
    required String txnToken,
    required String txnAmount,
    required String callBackUrl,
    required bool staging,
    bool? appInvokeEnabled,
  }) async {
    assert(mId != null);
    assert(orderId != null);
    assert(txnToken != null);
    assert(txnAmount != null);
    assert(callBackUrl != null);
    assert(staging != null);

    if (appInvokeEnabled == null) {
      appInvokeEnabled = true;
    }

    Map<dynamic, dynamic> response =
        await _channel.invokeMethod('payWithPaytm', {
      "mId": mId,
      'orderId': orderId,
      'txnToken': txnToken,
      'txnAmount': txnAmount,
      'callBackUrl': callBackUrl,
      "isStaging": staging,
      "appInvokeEnabled": appInvokeEnabled
    });

    if (response['response'] != null &&
        response['response'].runtimeType.toString() == "String") {
      response['response'] = json.decode(response['response']);
    }

    return response;
  }
}
