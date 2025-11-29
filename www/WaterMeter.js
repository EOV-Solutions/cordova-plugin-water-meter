/**
 * WaterMeter Cordova Plugin
 * 
 * JavaScript interface for water meter OCR scanning
 * Supports both Android and iOS platforms
 * 
 * @version 1.2.0
 * @author EOV Solutions
 */

var exec = require('cordova/exec');

var WaterMeter = {
    /**
     * SDK Version
     */
    VERSION: '1.2.0',
    
    /**
     * Initialize the WaterMeter SDK
     * Must be called before using other methods (iOS only, Android auto-initializes)
     * 
     * @param {Object} options - Configuration options
     * @param {number} [options.threadCount=2] - Number of threads for inference
     * @param {boolean} [options.useGPU=false] - Whether to use GPU acceleration
     * @param {number} [options.maxSideLength=640] - Maximum image dimension
     * @param {Function} success - Success callback
     * @param {Function} error - Error callback
     * 
     * @example
     * WaterMeter.initialize(
     *     { threadCount: 2 },
     *     function(result) { console.log('SDK initialized:', result); },
     *     function(err) { console.error('Init error:', err); }
     * );
     */
    initialize: function(options, success, error) {
        options = options || {};
        exec(success, error, 'WaterMeter', 'initialize', [options]);
    },
    
    /**
     * Open camera scanner to scan water meter number
     * 
     * @param {Function} successCallback - Called with OCR result
     * @param {Function} errorCallback - Called on error or user cancellation
     * @param {Object} options - Optional configuration
     * @param {string} options.title - Custom title for scanner screen (default: "Quét số đồng hồ")
     * @param {boolean} options.showCloseButton - Show close button (default: true)
     * @param {boolean} options.autoCloseOnResult - Auto close after scan (default: true)
     * @param {boolean} options.autoCapture - Auto capture when meter detected (default: true)
     * @param {number} options.minConfidence - Minimum confidence threshold (default: 0.7)
     * @param {number} options.imageMaxWidth - Max width for saved image in pixels
     * @param {number} options.imageMaxHeight - Max height for saved image in pixels
     * 
     * @example
     * WaterMeter.scan(
     *     function(result) {
     *         console.log('Reading:', result.text);
     *         console.log('Confidence:', result.confidence);
     *         console.log('Formatted:', result.formattedReading);
     *         if (result.isReliable) {
     *             // Save the reading
     *         }
     *     },
     *     function(err) {
     *         if (err === 'User cancelled') {
     *             console.log('User cancelled scan');
     *         } else {
     *             console.error('Scan error:', err);
     *         }
     *     },
     *     { 
     *         title: 'Hướng camera vào đồng hồ',
     *         autoCapture: true,
     *         minConfidence: 0.8
     *     }
     * );
     */
    scan: function(successCallback, errorCallback, options) {
        options = options || {};
        
        // Validate callbacks
        if (typeof successCallback !== 'function') {
            console.error('WaterMeter.scan: successCallback must be a function');
            return;
        }
        if (typeof errorCallback !== 'function') {
            console.error('WaterMeter.scan: errorCallback must be a function');
            return;
        }
        
        // Default options
        var config = {
            title: options.title || 'Quét số đồng hồ',
            showCloseButton: options.showCloseButton !== undefined ? options.showCloseButton : true,
            autoCloseOnResult: options.autoCloseOnResult !== undefined ? options.autoCloseOnResult : true,
            autoCapture: options.autoCapture !== undefined ? options.autoCapture : true,
            minConfidence: options.minConfidence || 0.7
        };
        
        // Add image resize options if specified
        if (options.imageMaxWidth && typeof options.imageMaxWidth === 'number') {
            config.imageMaxWidth = Math.floor(options.imageMaxWidth);
        }
        if (options.imageMaxHeight && typeof options.imageMaxHeight === 'number') {
            config.imageMaxHeight = Math.floor(options.imageMaxHeight);
        }
        
        exec(successCallback, errorCallback, 'WaterMeter', 'scan', [config]);
    },
    
    /**
     * Recognize water meter reading from base64 encoded image
     * 
     * @param {string} base64Image - Base64 encoded image (with or without data URL prefix)
     * @param {Function} success - Success callback with OCR result
     * @param {Function} error - Error callback
     * 
     * @example
     * WaterMeter.recognizeBase64(
     *     base64ImageData,
     *     function(result) {
     *         console.log('Reading:', result.text);
     *         console.log('Confidence:', result.confidence);
     *     },
     *     function(err) { console.error('Error:', err); }
     * );
     */
    recognizeBase64: function(base64Image, success, error) {
        if (!base64Image) {
            error && error('Missing base64 image data');
            return;
        }
        exec(success, error, 'WaterMeter', 'recognizeBase64', [base64Image]);
    },
    
    /**
     * Recognize water meter reading from file path
     * 
     * @param {string} filePath - Path to image file (supports file://, cdvfile://)
     * @param {Function} success - Success callback with OCR result
     * @param {Function} error - Error callback
     */
    recognizeFile: function(filePath, success, error) {
        if (!filePath) {
            error && error('Missing file path');
            return;
        }
        exec(success, error, 'WaterMeter', 'recognizeFile', [filePath]);
    },
    
    /**
     * Check if camera permission is granted
     * @param {Function} successCallback - Called with {granted: boolean}
     * @param {Function} errorCallback - Called on error
     */
    checkPermission: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'WaterMeter', 'checkPermission', []);
    },
    
    /**
     * Request camera permission
     * @param {Function} successCallback - Called with {granted: boolean}
     * @param {Function} errorCallback - Called on error
     */
    requestPermission: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'WaterMeter', 'requestPermission', []);
    },
    
    /**
     * Get SDK version
     * @param {Function} success - Success callback with version string
     * @param {Function} error - Error callback
     */
    getVersion: function(success, error) {
        exec(success, error, 'WaterMeter', 'getVersion', []);
    },
    
    /**
     * Check if SDK is initialized
     * @param {Function} success - Success callback with boolean
     * @param {Function} error - Error callback
     */
    isInitialized: function(success, error) {
        exec(success, error, 'WaterMeter', 'isInitialized', []);
    },
    
    /**
     * Reset SDK (release resources)
     * @param {Function} success - Success callback
     * @param {Function} error - Error callback
     */
    reset: function(success, error) {
        exec(success, error, 'WaterMeter', 'reset', []);
    },
    
    // Helper functions
    
    /**
     * Convert file to base64 (helper)
     * Requires cordova-plugin-file
     * 
     * @param {string} filePath - Path to file
     * @returns {Promise<string>} Base64 encoded content
     */
    fileToBase64: function(filePath) {
        return new Promise(function(resolve, reject) {
            if (!window.resolveLocalFileSystemURL) {
                reject(new Error('cordova-plugin-file is required'));
                return;
            }
            window.resolveLocalFileSystemURL(filePath, function(fileEntry) {
                fileEntry.file(function(file) {
                    var reader = new FileReader();
                    reader.onloadend = function() {
                        var base64 = reader.result.split(',')[1];
                        resolve(base64);
                    };
                    reader.onerror = reject;
                    reader.readAsDataURL(file);
                }, reject);
            }, reject);
        });
    },
    
    /**
     * Format meter reading with decimal point
     * 
     * @param {string} text - Raw reading text
     * @param {number} [decimalPlaces=3] - Number of decimal places
     * @returns {string} Formatted reading
     */
    formatReading: function(text, decimalPlaces) {
        decimalPlaces = decimalPlaces || 3;
        if (!text || text.length <= decimalPlaces) {
            return text;
        }
        var intPart = text.slice(0, -decimalPlaces);
        var decPart = text.slice(-decimalPlaces);
        return intPart + '.' + decPart;
    }
};

module.exports = WaterMeter;
