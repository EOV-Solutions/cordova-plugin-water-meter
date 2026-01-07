//
//  WMOCRBridge.h
//  WaterMeterSDK
//
//  Objective-C Bridge for C++ OCR Engine
//  Copyright © 2025 EOV Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Detection result from YOLO OBB model
@interface WMDetectionResult : NSObject

/// Bounding box points (4 corners for oriented box)
@property (nonatomic, strong) NSArray<NSValue *> *points;

/// Detection confidence score (0.0 - 1.0)
@property (nonatomic, assign) float confidence;

/// Class label (cs, ct, lt, mdh)
@property (nonatomic, strong) NSString *classLabel;

/// Class index
@property (nonatomic, assign) int classIndex;

/// Rotation angle in radians
@property (nonatomic, assign) float angle;

@end

/// OCR recognition result
@interface WMOCRResult : NSObject

/// Recognized text
@property (nonatomic, strong) NSString *text;

/// Recognition confidence score (0.0 - 1.0)  
@property (nonatomic, assign) float confidence;

/// Detection label (cs, ct, lt, mdh)
@property (nonatomic, strong) NSString *detectionLabel;

/// Detection confidence
@property (nonatomic, assign) float detectionConfidence;

/// Classification label (rotation: 0 or 180)
@property (nonatomic, strong) NSString *classificationLabel;

/// Classification confidence
@property (nonatomic, assign) float classificationConfidence;

/// Bounding box points
@property (nonatomic, strong) NSArray<NSValue *> *boundingBox;

@end

/// Configuration for OCR predictor
@interface WMPredictorConfig : NSObject

/// Number of CPU threads (default: 4)
@property (nonatomic, assign) int threadNum;

/// CPU power mode: LITE_POWER_HIGH, LITE_POWER_LOW, LITE_POWER_FULL, etc.
@property (nonatomic, strong) NSString *cpuPowerMode;

/// Detection model long size (default: 480)
@property (nonatomic, assign) int detLongSize;

/// Score threshold for filtering results (default: 0.1)
@property (nonatomic, assign) float scoreThreshold;

/// Use Metal GPU acceleration (default: NO)
@property (nonatomic, assign) BOOL useGPU;

+ (instancetype)defaultConfig;

@end

/// Main OCR predictor bridge class
@interface WMOCRBridge : NSObject

/// Whether the predictor is loaded and ready
@property (nonatomic, readonly) BOOL isLoaded;

/// Last inference time in milliseconds
@property (nonatomic, readonly) float inferenceTime;

/// Initialize with default configuration
- (instancetype)init;

/// Initialize with custom configuration
- (instancetype)initWithConfig:(WMPredictorConfig *)config;

/// Load models from bundle path
/// @param modelPath Path to models directory containing yolo_v8.nb, rec_crnn.nb, cls.nb
/// @param labelPath Path to label file (ppocr_keys_v1.txt)
/// @return YES if successful
- (BOOL)loadModelsFromPath:(NSString *)modelPath
                 labelPath:(NSString *)labelPath;

/// Load models from main bundle
/// @param modelFolder Folder name in bundle containing models
/// @param labelFile Label file name in bundle
/// @return YES if successful  
- (BOOL)loadModelsFromBundle:(NSString *)modelFolder
                   labelFile:(NSString *)labelFile;

/// Run OCR on image
/// @param image Input UIImage
/// @param runDetection Run YOLO OBB detection
/// @param runClassification Run rotation classification
/// @param runRecognition Run CRNN text recognition
/// @return Array of WMOCRResult objects
- (NSArray<WMOCRResult *> *)processImage:(UIImage *)image
                            runDetection:(BOOL)runDetection
                        runClassification:(BOOL)runClassification
                          runRecognition:(BOOL)runRecognition;

/// Run only detection (YOLO OBB)
/// @param image Input UIImage
/// @return Array of WMDetectionResult objects
- (NSArray<WMDetectionResult *> *)detectInImage:(UIImage *)image;

/// Release model resources
- (void)releaseModel;

/// Get SDK version
+ (NSString *)sdkVersion;

/// Initialize SDK internals (call this before creating any WMOCRBridge instance)
/// This ensures PaddleLite kernels are properly registered
+ (void)initializeSDK;

@end

NS_ASSUME_NONNULL_END
