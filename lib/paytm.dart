import 'dart:async';

import 'package:flutter/services.dart';

class Paytm {
  static const MethodChannel _channel = const MethodChannel('paytm');

  static Future<Map<dynamic, dynamic>> payWithPaytm(
    String mId,
    String orderId,
    String txnToken,
    String txnAmount,
    String callBackUrl,
    bool isStaging,
  ) async {
    assert(mId != null);
    assert(orderId != null);
    assert(txnToken != null);
    assert(txnAmount != null);
    assert(callBackUrl != null);

    Map<dynamic, dynamic> response =
        await _channel.invokeMethod('payWithPaytm', {
      "mId": mId,
      'orderId': orderId,
      'txnToken': txnToken,
      'txnAmount': txnAmount,
      'callBackUrl': callBackUrl,
      'isStaging': isStaging,
    });

    return response;
  }
}
