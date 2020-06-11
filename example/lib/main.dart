import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paytm/paytm.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String payment_response = null;

  String mid = "";
  String PAYTM_MERCHANT_KEY = "";
  String website = "DEFAULT";
  double amount = 1;
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Paytm example app'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Use Production Details Only'),

                SizedBox(
                  height: 10,
                ),

                TextField(
                  onChanged: (value) {
                    mid = value;
                  },
                  decoration: InputDecoration(hintText: "Enter MID here"),
                  keyboardType: TextInputType.text,
                ),
                TextField(
                  onChanged: (value) {
                    PAYTM_MERCHANT_KEY = value;
                  },
                  decoration:
                      InputDecoration(hintText: "Enter Merchant Key here"),
                  keyboardType: TextInputType.text,
                ),
                TextField(
                  onChanged: (value) {
                    website = value;
                  },
                  decoration: InputDecoration(
                      hintText: "Enter Website here (Probably DEFAULT)"),
                  keyboardType: TextInputType.text,
                ),
                TextField(
                  onChanged: (value) {
                    try {
                      amount = double.tryParse(value);
                    } catch (e) {
                      print(e);
                    }
                  },
                  decoration: InputDecoration(hintText: "Enter Amount here"),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(
                  height: 10,
                ),
                payment_response != null
                    ? Text('Response: $payment_response\n')
                    : Container(),
//                loading
//                    ? Center(
//                        child: Container(
//                            width: 50,
//                            height: 50,
//                            child: CircularProgressIndicator()),
//                      )
//                    : Container(),
                RaisedButton(
                  onPressed: () {
                    //Firstly Generate CheckSum bcoz Paytm Require this
                    generateTxnToken(0);
                  },
                  color: Colors.blue,
                  child: Text(
                    "Pay using Wallet",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    //Firstly Generate CheckSum bcoz Paytm Require this
                    generateTxnToken(1);
                  },
                  color: Colors.blue,
                  child: Text(
                    "Pay using Net Banking",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    //Firstly Generate CheckSum bcoz Paytm Require this
                    generateTxnToken(2);
                  },
                  color: Colors.blue,
                  child: Text(
                    "Pay using UPI",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    //Firstly Generate CheckSum bcoz Paytm Require this
                    generateTxnToken(3);
                  },
                  color: Colors.blue,
                  child: Text(
                    "Pay using Credit Card",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void generateTxnToken(int mode) async {
    setState(() {
      loading = true;
    });
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    String callBackUrl =
        'https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=' + orderId;

    var url =
        'https://desolate-anchorage-29312.herokuapp.com/generateTxnToken' +
            "?mid=" +
            mid +
            "&key_secret=" +
            PAYTM_MERCHANT_KEY +
            "&website=" +
            website +
            "&orderId=" +
            orderId +
            "&amount=" +
            amount.toString() +
            "&callbackUrl=" +
            callBackUrl +
            "&custId=" +
            "122" +
            "&mode=" +
            mode.toString();

    final response = await http.get(url);

    print("Response is");
    print(response.body);
    String txnToken = response.body;
    setState(() {
      payment_response = txnToken;
    });

    var paytmResponse = Paytm.payWithPaytm(
      mid,
      orderId,
      txnToken,
      amount.toString(),
      callBackUrl,
    );

    paytmResponse.then((value) {
      print(value);
      setState(() {
        loading = false;
        payment_response = value.toString();
      });
    });
  }
}
