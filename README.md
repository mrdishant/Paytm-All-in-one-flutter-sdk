# paytm

A Flutter plugin to use the Paytm as a payment gateway for accepting online payments in Flutter app.

## For Testing/Staging credentials make sure appInvokeEnabled set to FALSE or Paytm APP is not installed on the device.


## Example App in iOS
<!-- ![IMG_0CA99F9C709C-1](https://user-images.githubusercontent.com/25786428/82787888-07fbc180-9e85-11ea-87cb-754c6155b1d3.jpeg) -->
<img src="https://user-images.githubusercontent.com/25786428/82787888-07fbc180-9e85-11ea-87cb-754c6155b1d3.jpeg" width="300">


## First of all get Credentials from Paytm
Plugin will only work with Production Keys
[https://dashboard.paytm.com/next/apikeys](https://dashboard.paytm.com/next/apikeys)


## Let’s begin

iOS Configuration:

In case merchant don’t have callback URL, Add an entry into Info.plist

1. LSApplicationQueriesSchemes(Array) Item 0 (String)-> paytm
![iosInvoke](https://user-images.githubusercontent.com/25786428/82787548-45138400-9e84-11ea-835f-caa0701728cb.png)

2. Add a URL Scheme “paytm”+”MID”
![app-invoke-ios-inti](https://user-images.githubusercontent.com/25786428/82787531-3c22b280-9e84-11ea-9923-c18f2bc904de.png)
 

## Start Payment
```
  void generateTxnToken(int mode) async {
    
        String orderId = DateTime.now().millisecondsSinceEpoch.toString();

        String callBackUrl = (testing
                ? 'https://securegw-stage.paytm.in'
                : 'https://securegw.paytm.in') +
            '/theia/paytmCallback?ORDER_ID=' +
            orderId;

        //Host the Server Side Code on your Server and use your URL here. The following URL may or may not work. Because hosted on free server.
        //Server Side code url: https://github.com/mrdishant/Paytm-Plugin-Server
        var url = 'https://desolate-anchorage-29312.herokuapp.com/generateTxnToken';

        var body = json.encode({
          "mid": mid,
          "key_secret": PAYTM_MERCHANT_KEY,
          "website": website,
          "orderId": orderId,
          "amount": amount.toString(),
          "callbackUrl": callBackUrl,
          "custId": "122",
          "mode": mode.toString(),
          "testing": testing ? 0 : 1
        });

        try {
          final response = await http.post(
            url,
            body: body,
            headers: {'Content-type': "application/json"},
          );
          print("Response is");
          print(response.body);
          String txnToken = response.body;
          setState(() {
            payment_response = txnToken;
          });

          var paytmResponse = Paytm.payWithPaytm(
              mid, orderId, txnToken, amount.toString(), callBackUrl, testing);

          paytmResponse.then((value) {
            print(value);
            setState(() {
              loading = false;
              print("Value is ");
              print(value);
              if(value['error']){
                payment_response = value['errorMessage'];
              }else{
                if(value['response']!=null){
                  payment_response = value['response']['STATUS'];
                }
              }
              payment_response += "\n"+value.toString();
            });
          });
        } catch (e) {
          print(e);
        }
  }
  
  ``` 

## GENERATE TOKEN
For SERVER CODE:
[Paytm Plugin Server Code](https://github.com/mrdishant/Paytm-Plugin-Server)

## Support
<a href="https://www.buymeacoffee.com/mrdishant" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 30px !important;width: 117px !important;" ></a>

For Cloning the example app code visit:
[Paytm Plugin](https://github.com/mrdishant/Paytm-All-in-one-flutter-sdk.git)

For any query :
Mail me at mr.dishantmahajan@gmail.com