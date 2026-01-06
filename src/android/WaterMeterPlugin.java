package com.eov.cordova.watermeter;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.eov.watermeter.ui.CameraScanActivity;
import com.eov.watermeter.ui.CameraSettingsActivity;
import com.eov.watermeter.WaterMeterSDK;
import com.eov.watermeter.ocr.PredictorManager;
import com.eov.watermeter.ocr.Predictor;

import java.io.ByteArrayOutputStream;
import java.io.File;

/**
 * Cordova Plugin for Water Meter Scanner
 * Bridges JavaScript calls to Android SDK Camera Scanner
 */
public class WaterMeterPlugin extends CordovaPlugin {
    
    private static final String TAG = "WaterMeterPlugin";
    private static final String SDK_VERSION = "1.2.0";
    private static final int REQUEST_CAMERA_SCAN = 1001;
    private static final int REQUEST_CAMERA_PERMISSION = 1002;
    private static final int REQUEST_SETTINGS = 1003;
    
    private CallbackContext scanCallback;
    private CallbackContext permissionCallback;
    private boolean licenseInitialized = false;
    
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.d(TAG, "execute: action=" + action);
        
        if (action.equals("initializeLicense")) {
            this.initializeLicense(args.getString(0), callbackContext);
            return true;
        }
        
        if (action.equals("isLicenseValid")) {
            this.isLicenseValid(callbackContext);
            return true;
        }
        
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
        
        // New features for parity with iOS
        if (action.equals("recognizeBase64")) {
            this.recognizeBase64(args.getString(0), callbackContext);
            return true;
        }
        
        if (action.equals("recognizeFile")) {
            this.recognizeFile(args.getString(0), callbackContext);
            return true;
        }
        
        if (action.equals("openSettings")) {
            this.openSettings(callbackContext);
            return true;
        }
        
        if (action.equals("getVersion")) {
            this.getVersion(callbackContext);
            return true;
        }
        
        if (action.equals("isInitialized")) {
            this.isInitialized(callbackContext);
            return true;
        }
        
        if (action.equals("reset")) {
            this.reset(callbackContext);
            return true;
        }
        
        return false;
    }
    
    /**
     * Initialize SDK with license key
     */
    private void initializeLicense(String licenseKey, CallbackContext callbackContext) {
        cordova.getActivity().runOnUiThread(() -> {
            try {
                WaterMeterSDK.initialize(
                    cordova.getActivity().getApplicationContext(),
                    licenseKey,
                    new WaterMeterSDK.LicenseCallback() {
                        @Override
                        public void onSuccess() {
                            licenseInitialized = true;
                            Log.i(TAG, "License initialized successfully");
                            try {
                                JSONObject result = new JSONObject();
                                result.put("success", true);
                                result.put("message", "License activated successfully");
                                callbackContext.success(result);
                            } catch (JSONException e) {
                                callbackContext.success("License activated");
                            }
                        }
                        
                        @Override
                        public void onError(String errorMessage) {
                            Log.e(TAG, "License initialization failed: " + errorMessage);
                            callbackContext.error("License error: " + errorMessage);
                        }
                    }
                );
            } catch (Exception e) {
                Log.e(TAG, "Error initializing license", e);
                callbackContext.error("Failed to initialize license: " + e.getMessage());
            }
        });
    }
    
    /**
     * Check if license is valid
     */
    private void isLicenseValid(CallbackContext callbackContext) {
        try {
            boolean valid = WaterMeterSDK.isLicenseValid();
            JSONObject result = new JSONObject();
            result.put("valid", valid);
            result.put("status", WaterMeterSDK.getLicenseStatus());
            callbackContext.success(result);
        } catch (Exception e) {
            callbackContext.error("Error checking license: " + e.getMessage());
        }
    }
    
    /**
     * Open camera scanner
     */
    private void scan(JSONObject options, CallbackContext callbackContext) {
        this.scanCallback = callbackContext;
        
        // Check license first
        if (!WaterMeterSDK.isLicenseValid()) {
            callbackContext.error("SDK not initialized or license invalid. Call initializeLicense() first.");
            return;
        }
        
        // Check permission
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
                    if (options.has("imageMaxWidth")) {
                        intent.putExtra(CameraScanActivity.EXTRA_IMAGE_MAX_WIDTH, options.getInt("imageMaxWidth"));
                    }
                    if (options.has("imageMaxHeight")) {
                        intent.putExtra(CameraScanActivity.EXTRA_IMAGE_MAX_HEIGHT, options.getInt("imageMaxHeight"));
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
                        
                        // Convert image to base64 for WebView compatibility
                        String base64Image = convertImageToBase64(imagePath);
                        if (base64Image != null) {
                            result.put("imageBase64", base64Image);
                        }
                    }
                    
                    // Usage quota is now incremented by SDK internally (CameraScanActivity)
                    // No need to call incrementUsage here - SDK handles it for security
                    
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
    
    /**
     * Convert image file to base64 data URL
     */
    private String convertImageToBase64(String imagePath) {
        try {
            File file = new File(imagePath);
            if (!file.exists()) {
                Log.e(TAG, "Image file does not exist: " + imagePath);
                return null;
            }
            
            // Decode with inSampleSize to reduce memory usage
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inSampleSize = 2; // Scale down by 2
            Bitmap bitmap = BitmapFactory.decodeFile(imagePath, options);
            
            if (bitmap == null) {
                Log.e(TAG, "Failed to decode image: " + imagePath);
                return null;
            }
            
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.JPEG, 80, baos);
            byte[] bytes = baos.toByteArray();
            bitmap.recycle();
            
            String base64 = Base64.encodeToString(bytes, Base64.NO_WRAP);
            return "data:image/jpeg;base64," + base64;
            
        } catch (Exception e) {
            Log.e(TAG, "Error converting image to base64", e);
            return null;
        }
    }
    
    // ============= NEW FEATURES FOR IOS PARITY =============
    
    /**
     * Recognize water meter reading from base64 encoded image
     */
    private void recognizeBase64(String base64Image, CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                // Remove data URL prefix if present
                String base64Data = base64Image;
                if (base64Data.contains("base64,")) {
                    base64Data = base64Data.substring(base64Data.indexOf("base64,") + 7);
                }
                
                // Decode base64 to bitmap
                byte[] imageBytes = Base64.decode(base64Data, Base64.DEFAULT);
                Bitmap bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);
                
                if (bitmap == null) {
                    callbackContext.error("Failed to decode base64 image");
                    return;
                }
                
                // Perform OCR
                performOCR(bitmap, callbackContext);
                
            } catch (Exception e) {
                Log.e(TAG, "Error in recognizeBase64", e);
                callbackContext.error("Error: " + e.getMessage());
            }
        });
    }
    
    /**
     * Recognize water meter reading from file path
     */
    private void recognizeFile(String filePath, CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                // Handle file:// prefix
                String path = filePath;
                if (path.startsWith("file://")) {
                    path = path.substring(7);
                }
                
                Bitmap bitmap = BitmapFactory.decodeFile(path);
                if (bitmap == null) {
                    callbackContext.error("Failed to load image from: " + path);
                    return;
                }
                
                performOCR(bitmap, callbackContext);
                
            } catch (Exception e) {
                Log.e(TAG, "Error in recognizeFile", e);
                callbackContext.error("Error: " + e.getMessage());
            }
        });
    }
    
    /**
     * Perform OCR on bitmap using PredictorManager
     */
    private void performOCR(Bitmap bitmap, CallbackContext callbackContext) {
        try {
            PredictorManager manager = PredictorManager.getInstance();
            
            // Initialize if needed
            if (!manager.isInitialized()) {
                boolean initialized = manager.init(cordova.getActivity().getApplicationContext());
                if (!initialized) {
                    callbackContext.error("Failed to initialize OCR predictor");
                    return;
                }
            }
            
            Predictor predictor = manager.getPredictor();
            if (predictor == null) {
                callbackContext.error("OCR predictor not available");
                return;
            }
            
            // Run OCR
            predictor.setInputImage(bitmap);
            boolean success = predictor.runModel(1, 1, 1); // run_det=1, run_cls=1, run_rec=1
            
            // Get results
            JSONObject result = new JSONObject();
            String text = predictor.outputResult();
            float confidence = predictor.conf_rec();
            
            result.put("text", text != null ? text : "");
            result.put("confidence", confidence);
            result.put("success", text != null && !text.isEmpty());
            
            Log.d(TAG, "OCR result: text=" + text + ", confidence=" + confidence);
            callbackContext.success(result);
            
            // Clean up bitmap
            bitmap.recycle();
            
        } catch (Exception e) {
            Log.e(TAG, "OCR Error", e);
            callbackContext.error("OCR Error: " + e.getMessage());
        }
    }
    
    /**
     * Open SDK settings activity
     */
    private void openSettings(CallbackContext callbackContext) {
        cordova.getActivity().runOnUiThread(() -> {
            try {
                Intent intent = new Intent(cordova.getActivity(), CameraSettingsActivity.class);
                cordova.getActivity().startActivity(intent);
                callbackContext.success("Settings opened");
            } catch (Exception e) {
                Log.e(TAG, "Error opening settings", e);
                callbackContext.error("Failed to open settings: " + e.getMessage());
            }
        });
    }
    
    /**
     * Get SDK version
     */
    private void getVersion(CallbackContext callbackContext) {
        callbackContext.success(SDK_VERSION);
    }
    
    /**
     * Check if SDK OCR predictor is initialized
     */
    private void isInitialized(CallbackContext callbackContext) {
        try {
            boolean initialized = PredictorManager.getInstance().isInitialized();
            JSONObject result = new JSONObject();
            result.put("initialized", initialized);
            callbackContext.success(result);
        } catch (Exception e) {
            callbackContext.error("Error: " + e.getMessage());
        }
    }
    
    /**
     * Reset SDK (release resources)
     */
    private void reset(CallbackContext callbackContext) {
        try {
            PredictorManager.getInstance().release();
            Log.i(TAG, "SDK resources released");
            callbackContext.success("SDK reset");
        } catch (Exception e) {
            Log.e(TAG, "Error resetting SDK", e);
            callbackContext.error("Failed to reset SDK: " + e.getMessage());
        }
    }
}
