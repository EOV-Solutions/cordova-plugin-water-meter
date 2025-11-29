//
//  preprocess.h
//  WaterMeterSDK
//
//  Image preprocessing utilities
//  Copyright © 2025 EOV Solutions. All rights reserved.
//

#ifndef PREPROCESS_H
#define PREPROCESS_H

// Include specific OpenCV modules to avoid conflicts with Apple's NO macro
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <vector>
#include <tuple>

/**
 * NEON optimized mean and scale normalization
 * Converts HWC to CHW format while applying normalization
 */
void neon_mean_scale(const float* din, float* dout, int size,
                     const std::vector<float>& mean,
                     const std::vector<float>& scale);

// Note: The following functions have been moved to ocr_cls_process.cpp and ocr_crnn_process.cpp
// - crnn_resize_img, cls_resize_img
// - get_rotate_crop_image, get_rotate_crop_image_new
// - expand_and_crop_obb, transform_coordinates

#endif // PREPROCESS_H
