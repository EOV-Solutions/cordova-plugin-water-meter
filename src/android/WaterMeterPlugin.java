package com.eov.cordova.watermeter;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.eov.watermeter.ui.CameraScanActivity;

/**
 * Cordova Plugin for Water Meter Scanner
 * Bridges JavaScript calls to Android SDK Camera Scanner
 */
public class WaterMeterPlugin extends CordovaPlugin {
    
    private static final String TAG = "WaterMeterPlugin";
    private static final int REQUEST_CAMERA_SCAN = 1001;
    private static final int REQUEST_CAMERA_PERMISSION = 1002;
    
    private CallbackContext scanCallback;
    private CallbackContext permissionCallback;
    
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.d(TAG, "execute: action=" + action);
        
        if (action.equals("scan")) {
            this.scan(args.getJSONObject(0), callbackContext);
            return true;
        }
        
        if (action.equals("checkPermission")) {
            this.checkPermission(callbackContext);
            return true;
        }
        
        if (action.equals("requestPermission")) {
            this.requestPermission(callbackContext);
            return true;
        }
        
        return false;
    }
    
    /**
     * Open camera scanner
     */
    private void scan(JSONObject options, CallbackContext callbackContext) {
        this.scanCallback = callbackContext;
        
        // Check permission first
        if (!hasPermission()) {
            callbackContext.error("Camera permission not granted. Call requestPermission() first.");
            return;
        }
        
        // Launch scanner activity
        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    Intent intent = new Intent(cordova.getActivity(), CameraScanActivity.class);
                    
                    // Optional parameters
                    if (options.has("title")) {
                        intent.putExtra(CameraScanActivity.EXTRA_TITLE, options.getString("title"));
                    }
                    if (options.has("showCloseButton")) {
                        intent.putExtra(CameraScanActivity.EXTRA_SHOW_CLOSE_BUTTON, options.getBoolean("showCloseButton"));
                    }
                    if (options.has("autoCloseOnResult")) {
                        intent.putExtra(CameraScanActivity.EXTRA_AUTO_CLOSE_ON_RESULT, options.getBoolean("autoCloseOnResult"));
                    }
                    
                    cordova.startActivityForResult(WaterMeterPlugin.this, intent, REQUEST_CAMERA_SCAN);
                    
                    // Keep callback for result
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
                    pluginResult.setKeepCallback(true);
                    callbackContext.sendPluginResult(pluginResult);
                    
                } catch (Exception e) {
                    Log.e(TAG, "Error launching scanner", e);
                    callbackContext.error("Failed to launch scanner: " + e.getMessage());
                }
            }
        });
    }
    
    /**
     * Check if camera permission is granted
     */
    private void checkPermission(CallbackContext callbackContext) {
        try {
            JSONObject result = new JSONObject();
            result.put("granted", hasPermission());
            callbackContext.success(result);
        } catch (JSONException e) {
            callbackContext.error("Error checking permission: " + e.getMessage());
        }
    }
    
    /**
     * Request camera permission
     */
    private void requestPermission(CallbackContext callbackContext) {
        this.permissionCallback = callbackContext;
        
        if (hasPermission()) {
            try {
                JSONObject result = new JSONObject();
                result.put("granted", true);
                callbackContext.success(result);
            } catch (JSONException e) {
                callbackContext.error("Error: " + e.getMessage());
            }
            return;
        }
        
        // Request permission
        cordova.requestPermission(this, REQUEST_CAMERA_PERMISSION, Manifest.permission.CAMERA);
        
        // Keep callback for permission result
        PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
    }
    
    /**
     * Check if camera permission is granted
     */
    private boolean hasPermission() {
        return cordova.hasPermission(Manifest.permission.CAMERA);
    }
    
    /**
     * Handle activity result from scanner
     */
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d(TAG, "onActivityResult: requestCode=" + requestCode + ", resultCode=" + resultCode);
        
        if (requestCode == REQUEST_CAMERA_SCAN) {
            if (scanCallback == null) {
                Log.e(TAG, "scanCallback is null!");
                return;
            }
            
            if (resultCode == Activity.RESULT_OK && data != null) {
                String text = data.getStringExtra(CameraScanActivity.EXTRA_RESULT_TEXT);
                float confidence = data.getFloatExtra(CameraScanActivity.EXTRA_RESULT_CONFIDENCE, 0f);
                String imagePath = data.getStringExtra(CameraScanActivity.EXTRA_RESULT_IMAGE_PATH);
                
                try {
                    JSONObject result = new JSONObject();
                    result.put("text", text != null ? text : "");
                    result.put("confidence", confidence);
                    result.put("success", text != null && !text.isEmpty());
                    if (imagePath != null && !imagePath.isEmpty()) {
                        result.put("imagePath", imagePath);
                    }
                    
                    Log.d(TAG, "Scan result: " + result.toString());
                    scanCallback.success(result);
                    
                } catch (JSONException e) {
                    Log.e(TAG, "Error creating result JSON", e);
                    scanCallback.error("Error processing result: " + e.getMessage());
                }
            } else {
                // User cancelled
                Log.d(TAG, "User cancelled scan");
                scanCallback.error("User cancelled");
            }
            
            scanCallback = null;
        }
    }
    
    /**
     * Handle permission request result
     */
    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        Log.d(TAG, "onRequestPermissionResult: requestCode=" + requestCode);
        
        if (requestCode == REQUEST_CAMERA_PERMISSION) {
            if (permissionCallback == null) {
                Log.e(TAG, "permissionCallback is null!");
                return;
            }
            
            boolean granted = grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;
            
            JSONObject result = new JSONObject();
            result.put("granted", granted);
            
            if (granted) {
                permissionCallback.success(result);
            } else {
                permissionCallback.error("Camera permission denied");
            }
            
            permissionCallback = null;
        }
    }
}
