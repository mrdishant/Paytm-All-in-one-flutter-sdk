import Flutter
import UIKit
import AppInvokeSDK

public class SwiftPaytmPlugin: NSObject, FlutterPlugin, AIDelegate{
    public func didFinish(with status: AIPaymentStatus, response: [String : Any]) {
        print("Response")
        print(type(of: response))
        print(response)
        
        var paramMap = [String: Any]()
    
        if(status==AIPaymentStatus.failed){
            paramMap["error"]=true
            paramMap["errorMessage"]=response["RESPMSG"]
            paramMap["response"]=response
        }else{
            paramMap["error"]=false
            paramMap["response"]=response
        }

        
        self.flutterResult!(paramMap)
    }
    
    
    private var appInvoke : AIHandler = AIHandler()
    
    public func openPaymentWebVC(_ controller: UIViewController?) {
        print("Response2")
        
        if let vc = controller {
            
            DispatchQueue.main.async {[weak self] in
                UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "paytm", binaryMessenger: registrar.messenger())
        let instance = SwiftPaytmPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    
    private var flutterResult:FlutterResult?
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        
        self.flutterResult=result
        
        let arguements = call.arguments as? NSDictionary
        print(arguements)
        print(call.method)
        
        if(call.method.elementsEqual("payWithPaytm")){
            let mId = arguements!["mId"] as! String
            let orderId = arguements!["orderId"] as! String
            let amount = arguements!["txnAmount"] as! String
            let txnToken = arguements!["txnToken"] as! String
            let callBackUrl = arguements!["callBackUrl"] as! String
            let isStaging = arguements!["isStaging"] as! Bool
            
            var environment:AIEnvironment;
            
            if(isStaging){
                environment=AIEnvironment.staging
            }else{
                environment=AIEnvironment.production
            }
            
            print(callBackUrl);
            
            
            appInvoke.openPaytm(merchantId: mId, orderId: orderId, txnToken: txnToken, amount: amount, callbackUrl: callBackUrl , delegate: self, environment: environment)
            
        }
        
        
    }
    
    
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Response in Plugin")
        print(url.absoluteString)
        
        var dict = [String:String]()
        
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if let queryItems = components.queryItems {
            for item in queryItems {
                dict[item.name] = item.value!
            }
        }
        print(dict)
        
        var paramMap = [String: Any]()

        if dict["response"] != nil && dict["response"]!.count > 0{
            paramMap["error"]=false
            paramMap["response"]=dict["response"]

        }else{
            paramMap["error"]=true
            paramMap["errorMessage"]="Transaction Cancelled"
            paramMap["status"]=dict["status"]
        }
        
        
        self.flutterResult!(paramMap)
        
        return true
    }
    
    
    
    
}
