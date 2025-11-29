//
//  ocr_ppredictor.h
//  WaterMeterSDK
//
//  OCR Predictor for Water Meter Recognition
//  Copyright © 2025 EOV Solutions. All rights reserved.
//

#ifndef OCR_PPREDICTOR_H
#define OCR_PPREDICTOR_H

// Include specific OpenCV modules to avoid conflicts with Apple's NO macro
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>

#include "ppredictor.h"
#include <string>
#include <vector>
#include <memory>

namespace ppredictor {

/**
 * OCR Configuration
 */
struct OCR_Config {
    int use_opencl = 0;
    int thread_num = 4;
    paddle::lite_api::PowerMode mode = paddle::lite_api::LITE_POWER_HIGH;
    
    // OBB/YOLO thresholds
    float obb_conf_thres = 0.35f;
    float obb_iou_thres = 0.45f;
    int obb_max_det = 100;
    int obb_pre_topk = 1000;
    float obb_min_area_ratio = 0.0008f;
    float obb_max_area_ratio = 0.4f;
    float obb_min_side = 6.0f;
    float obb_max_aspect = 12.0f;
    float cls_thresh = 0.6f;
};

/**
 * OCR Prediction Result
 */
struct OCRPredictResult {
    std::vector<int> word_index;
    std::vector<std::vector<float>> points;
    std::vector<std::vector<float>> points_new;
    float obb_score = 0.0f;
    int obb_label = -1;
    float score = 0.0f;
    float cls_score = 0.0f;
    int cls_label = -1;
};

/**
 * Classification Result
 */
struct ClsPredictResult {
    float cls_score = 0.0f;
    int cls_label = -1;
    cv::Mat img;
};

/**
 * OCR Predictor class
 * Combines YOLO OBB detection + CRNN recognition + Classification
 */
class OCR_PPredictor : public PPredictor_Interface {
public:
    OCR_PPredictor(const OCR_Config& config);
    virtual ~OCR_PPredictor() {}
    
    /**
     * Initialize from model content buffers
     */
    int init(const std::string& det_model_content,
             const std::string& rec_model_content,
             const std::string& cls_model_content);
    
    /**
     * Initialize from model file paths
     */
    int init_from_file(const std::string& det_model_path,
                       const std::string& rec_model_path,
                       const std::string& cls_model_path);
    
    /**
     * Run OCR inference
     * @param origin Input image
     * @param max_size_len Maximum size for detection
     * @param run_det Run detection
     * @param run_cls Run classification
     * @param run_rec Run recognition
     * @return Vector of OCR results
     */
    std::vector<OCRPredictResult> infer_ocr(cv::Mat& origin,
                                            int max_size_len,
                                            int run_det,
                                            int run_cls,
                                            int run_rec);
    
    virtual NET_TYPE get_net_flag() const override;

private:
    // Detection inference
    void infer_det(cv::Mat& origin, int max_side_len,
                   std::vector<OCRPredictResult>& ocr_results);
    
    // Recognition inference
    void infer_rec(const cv::Mat& origin, int run_cls,
                   OCRPredictResult& ocr_result);
    
    // Classification inference
    ClsPredictResult infer_cls(const cv::Mat& origin, float thresh = 0.5f);
    
    // Post-processing
    std::vector<int> postprocess_rec_word_index(const PredictorOutput& res);
    float postprocess_rec_score(const PredictorOutput& res);
    
    // Crop rotated image
    cv::Mat GetRotateCropImage(const cv::Mat& srcimage,
                               std::vector<std::vector<int>> box);

    std::unique_ptr<PPredictor> _det_predictor;
    std::unique_ptr<PPredictor> _rec_predictor;
    std::unique_ptr<PPredictor> _cls_predictor;
    OCR_Config _config;
};

} // namespace ppredictor

#endif // OCR_PPREDICTOR_H
