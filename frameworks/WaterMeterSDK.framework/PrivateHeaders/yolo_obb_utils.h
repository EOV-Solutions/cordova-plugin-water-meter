//
//  yolo_obb_utils.h
//  WaterMeterSDK
//
//  YOLO OBB utilities for oriented bounding box detection
//  Copyright © 2025 EOV Solutions. All rights reserved.
//

#ifndef YOLO_OBB_UTILS_H
#define YOLO_OBB_UTILS_H

#pragma once

// Include specific OpenCV modules to avoid conflicts with Apple's NO macro
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <vector>
#include <cmath>
#include <tuple>
#include <string>
#include <map>
#include "common.h"

namespace yolo_obb_utils {

/**
 * Detector configuration
 */
struct DetectorConfig {
    int use_opencl = 0;
    int thread_num = 4;
    int input_size = 480;  // iOS default (matching model training)
    
    // OBB / YOLO related thresholds (matching OCR_PPredictor structure)
    float obb_conf_thres = 0.5f;
    float obb_iou_thres = 0.5f;
    int obb_max_det = 300;
    int obb_pre_topk = 1000;
    float obb_min_area_ratio = 0.0008f;
    float obb_max_area_ratio = 0.4f;
    float obb_min_side = 6.0f;
    float obb_max_aspect = 12.0f;
};

/**
 * Detection result structure
 */
struct DetectionResult {
    std::vector<cv::Point2f> boundingBox; // x,y,w,h (raw coordinates)
    std::vector<cv::Point2f> points;      // x1,y1,x2,y2,x3,y3,x4,y4 (corner points)
    float radians;      // rotation angle in radians
    float confidence;
    std::string classLabel;
    int classIndex;
};

// Clip XYWH coordinates before converting to rotated box (matching Python logic)
void clipXYWH(float& x, float& y, float& w, float& h, const cv::Size& imageSize);

// Clip boxes to image bounds
void clipBoxes(std::vector<cv::Point2f>& boxes, const cv::Size& imageSize);

// Scale boxes from input size to original image size
void scaleBoxes(
    std::vector<cv::Point2f>& boxes,
    const cv::Size& inputSize,
    const cv::Size& originalSize,
    float ratio,
    const cv::Point2f& pad
);

// Box area calculation using Shoelace formula
float boxArea(const std::vector<cv::Point2f>& box);

// IoU calculation for oriented bounding boxes
float calculateOBBIoU(
    const std::vector<cv::Point2f>& box1,
    const std::vector<cv::Point2f>& box2
);

// Convert xywhr format to 4 corner points
std::vector<cv::Point2f> xywhr2xyxyxyxy(float cx, float cy, float w, float h, float r);

// Letterbox preprocessing
cv::Mat letterbox(
    const cv::Mat& image,
    const cv::Size& newShape,
    float& ratio,
    cv::Point2f& pad,
    const cv::Scalar& color = cv::Scalar(114, 114, 114),
    bool auto_pad = false,
    bool scaleFill = false,
    bool scaleup = true,
    int stride = 32
);

// Non-maximum suppression for oriented bounding boxes
std::vector<int> nmsOBB(
    const std::vector<std::vector<cv::Point2f>>& boxes,
    const std::vector<float>& scores,
    float iouThreshold
);

// Probabilistic IoU calculation 
float probIoU(
    const std::vector<cv::Point2f>& obb1,
    const std::vector<cv::Point2f>& obb2
);

// Helper function to get covariance matrix
std::tuple<float, float, float> getCovarianceMatrix(
    float w, float h, float angle
);

// Preprocess image: letterbox + normalization
cv::Mat preprocess(const cv::Mat& origin, int max_size_len, float& ratio, cv::Point2f& pad);

// NMS wrapper for DetectionResult
std::vector<DetectionResult> nonMaxSuppressionOBB(
    const std::vector<DetectionResult>& detections,
    float iouThreshold
);

// NMS with letterbox scaling (main entry for YOLO output)
std::vector<DetectionResult> non_max_suppression_obb_letterbox(
    const float* pred, int num_detections,
    float ratio, float pad_x, float pad_y,
    int input_w, int input_h, int orig_w, int orig_h,
    float conf_thres, float iou_thres, int max_det
);

// Main postprocess entry point for YOLO OBB
std::vector<DetectionResult> calc_filtered_boxes_yolo_letterbox(
    const float *pred, int pred_size,
    int input_height, int input_width,
    const cv::Mat &origin, 
    float ratio, float pad_x, float pad_y,
    float conf_thres, float iou_thres, int max_det, 
    bool is_transposed
);

// Postprocess wrapper using output shape
std::vector<DetectionResult> postprocess(
    const cv::Mat& image,
    const float* tensor_data,
    std::vector<int64_t> output_shape,
    cv::Size input_new,
    float ratio,
    cv::Point2f pad
);

// Check if point is inside OBB
bool isInsideOBB(const cv::Point2f& p, const std::vector<cv::Point2f>& obb);

} // namespace yolo_obb_utils

#endif // YOLO_OBB_UTILS_H
