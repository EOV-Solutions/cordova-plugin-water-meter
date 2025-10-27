var exec = require('cordova/exec');

/**
 * Water Meter Scanner Plugin
 * Cordova JavaScript interface for Water Meter OCR scanning
 */
var WaterMeter = {
    
    /**
     * Open camera scanner to scan water meter number
     * @param {Function} successCallback - Called with OCR result {text: string, confidence: number}
     * @param {Function} errorCallback - Called on error or user cancellation
     * @param {Object} options - Optional configuration
     * @param {string} options.title - Custom title for scanner screen (default: "Quét số đồng hồ")
     * @param {boolean} options.showCloseButton - Show close button (default: true)
     * @param {boolean} options.autoCloseOnResult - Auto close after scan (default: true)
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
            autoCloseOnResult: options.autoCloseOnResult !== undefined ? options.autoCloseOnResult : true
        };
        
        exec(successCallback, errorCallback, 'WaterMeter', 'scan', [config]);
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
    }
};

module.exports = WaterMeter;
