package in.appyflow.paytm;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import com.paytm.pgsdk.PaytmOrder;
import com.paytm.pgsdk.PaytmPaymentTransactionCallback;
import com.paytm.pgsdk.TransactionManager;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * PaytmPlugin
 */
public class PaytmPlugin implements FlutterPlugin, MethodCallHandler, PluginRegistry.ActivityResultListener, ActivityAware {
    private static final int PAYTM_REQUEST_CODE = 7567;
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    String TAG = getClass().getName();
    private static Result flutterResult;
    private static Activity activity;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "paytm");
        channel.setMethodCallHandler(this);
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {

        activity = registrar.activity();
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "paytm");
        PaytmPlugin paytmPlugin = new PaytmPlugin();
        channel.setMethodCallHandler(paytmPlugin);
        registrar.addActivityResultListener(paytmPlugin);
    }

    private static void checkResult(int requestCode, int resultCode, Intent data) {

        if (requestCode == PAYTM_REQUEST_CODE && data != null) {

            Map<String, Object> paramMap = new HashMap<>();

            if (data.getStringExtra("response") != null && data.getStringExtra("response").length() > 0) {

                paramMap.put("error", false);
                for (String key : Objects.requireNonNull(data.getExtras()).keySet()) {
                    paramMap.put(key, data.getExtras().getString(key));
                }
            } else {
                paramMap.put("error", true);
                paramMap.put("errorMessage", data.getStringExtra("nativeSdkForMerchantMessage"));

            }

            sendResponse(paramMap);

        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        flutterResult = result;

        if (call.method.equals("payWithPaytm")) {
            String mId = call.argument("mId").toString();
            String orderId = call.argument("orderId").toString();
            String txnToken = call.argument("txnToken").toString();
            String txnAmount = call.argument("txnAmount").toString();
            String callBackUrl = call.argument("callBackUrl");
            boolean isStaging = call.argument("isStaging");
            beginPayment(mId, orderId, txnToken, txnAmount, callBackUrl,isStaging);
        } else {
            result.notImplemented();
        }
    }

    private void beginPayment(String mId, String orderId, String txnToken, String txnAmount, String callBackUrl,boolean isStaging) {

        String host = "https://securegw.paytm.in/";
        if (isStaging) {
            host = "https://securegw-stage.paytm.in/";
        }

        String  callback;

        if (callBackUrl == null || callBackUrl.trim().length()==0) {
            callback= host + "theia/paytmCallback?ORDER_ID=" + orderId;
        } else {
            callback =callBackUrl;
        }

        PaytmOrder paytmOrder = new PaytmOrder(orderId, mId, txnToken, txnAmount, callback);

        Log.i(TAG, paytmOrder.toString());

        TransactionManager transactionManager = new TransactionManager(paytmOrder, new PaytmPaymentTransactionCallback() {
            @Override
            public void onTransactionResponse(Bundle bundle) {

                Log.i(TAG, bundle.toString());

                Map<String, Object> paramMap = new HashMap<>();

                Map<String, Object> responseMap = new HashMap<>();
                for (String key : bundle.keySet()) {
                    responseMap.put(key, bundle.getString(key));
                }

                paramMap.put("error", false);
                paramMap.put("response", responseMap);

                Log.i(TAG, paramMap.toString());

                sendResponse(paramMap);

            }

            @Override
            public void networkNotAvailable() {
                Map<String, Object> paramMap = new HashMap<>();

                paramMap.put("error", true);
                paramMap.put("errorMessage", "Network Not Available");

                sendResponse(paramMap);
            }

            @Override
            public void onErrorProceed(String s) {

            }

            @Override
            public void clientAuthenticationFailed(String s) {

                Map<String, Object> paramMap = new HashMap<>();

                paramMap.put("error", true);
                paramMap.put("errorMessage", s);

                sendResponse(paramMap);
            }

            @Override
            public void someUIErrorOccurred(String s) {

                Map<String, Object> paramMap = new HashMap<>();

                paramMap.put("error", true);
                paramMap.put("errorMessage", s);

                sendResponse(paramMap);

            }

            @Override
            public void onErrorLoadingWebPage(int i, String s, String s1) {

                Map<String, Object> paramMap = new HashMap<>();

                paramMap.put("error", true);
                paramMap.put("errorMessage", s + " , " + s1.toString());

                sendResponse(paramMap);
            }

            @Override
            public void onBackPressedCancelTransaction() {

                Map<String, Object> paramMap = new HashMap<>();

                paramMap.put("error", true);
                paramMap.put("errorMessage", "Back Pressed Transaction Cancelled");

                sendResponse(paramMap);

            }

            @Override
            public void onTransactionCancel(String s, Bundle bundle) {
                Log.i(TAG, s + bundle.toString());

                Map<String, Object> paramMap = new HashMap<>();


                for (String key : bundle.keySet()) {
                    paramMap.put(key, bundle.getString(key));
                }

                Log.i(TAG, paramMap.toString());

                paramMap.put("error", true);
                paramMap.put("errorMessage", s);


                sendResponse(paramMap);


            }

        });
        transactionManager.setShowPaymentUrl(host + "theia/api/v1/showPaymentPage");
        transactionManager.startTransaction(activity, PAYTM_REQUEST_CODE);

    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private static void sendResponse(Map<String, Object> paramMap) {
        
        flutterResult.success(paramMap);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.i(TAG,"onActivityResult");
        checkResult(requestCode, resultCode, data);
        return false;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }
}
