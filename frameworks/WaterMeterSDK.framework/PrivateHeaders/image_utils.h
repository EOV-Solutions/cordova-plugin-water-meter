//
//  image_utils.h
//  WaterMeterSDK
//
//  Image utility functions for OBB processing
//  Copyright © 2025 EOV Solutions. All rights reserved.
//

#ifndef IMAGE_UTILS_H
#define IMAGE_UTILS_H

// Include specific OpenCV modules to avoid conflicts with Apple's NO macro
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <vector>
#include <tuple>
#include <cmath>
#include <algorithm>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

namespace ppredictor {

/**
 * Expand and crop OBB (Oriented Bounding Box)
 */
inline std::vector<std::vector<float>> expand_and_crop_obb(
    const cv::Mat& image, 
    const std::vector<std::vector<float>>& obb_points, 
    float expand_ratio = 1.0f) {
    
    std::vector<cv::Point2f> points;
    for (const auto& p : obb_points) {
        points.emplace_back(p[0], p[1]);
    }
    
    // Calculate center
    cv::Point2f center(0, 0);
    for (const auto& p : points) {
        center += p;
    }
    center *= (1.0f / points.size());
    
    // Expand points from center
    std::vector<std::vector<float>> expanded;
    for (const auto& p : points) {
        float dx = p.x - center.x;
        float dy = p.y - center.y;
        float new_x = center.x + dx * expand_ratio;
        float new_y = center.y + dy * expand_ratio;
        
        // Clamp to image bounds
        new_x = std::max(0.0f, std::min(new_x, static_cast<float>(image.cols - 1)));
        new_y = std::max(0.0f, std::min(new_y, static_cast<float>(image.rows - 1)));
        
        expanded.push_back({new_x, new_y});
    }
    
    return expanded;
}

/**
 * Get rotated crop image with perspective transform
 * Returns: (cropped_image, transformed_points, transform_matrix, indices, check_rot90)
 */
inline std::tuple<cv::Mat, std::vector<cv::Point2f>, cv::Mat, std::vector<int>, bool>
get_rotate_crop_image_new(const cv::Mat& image, 
                          const std::vector<std::vector<float>>& points) {
    std::vector<cv::Point2f> src_pts;
    for (const auto& p : points) {
        src_pts.emplace_back(p[0], p[1]);
    }
    
    // Sort points: top-left, top-right, bottom-right, bottom-left
    cv::Point2f center(0, 0);
    for (const auto& p : src_pts) {
        center += p;
    }
    center *= 0.25f;
    
    std::vector<std::pair<float, int>> angles;
    for (int i = 0; i < 4; i++) {
        float angle = std::atan2(src_pts[i].y - center.y, src_pts[i].x - center.x);
        angles.push_back({angle, i});
    }
    std::sort(angles.begin(), angles.end());
    
    // Find top-left (smallest x+y after angle sort)
    std::vector<int> indices = {angles[1].second, angles[2].second, 
                                 angles[3].second, angles[0].second};
    
    std::vector<cv::Point2f> ordered_pts;
    for (int idx : indices) {
        ordered_pts.push_back(src_pts[idx]);
    }
    
    // Calculate output size
    float width = std::max(
        cv::norm(ordered_pts[0] - ordered_pts[1]),
        cv::norm(ordered_pts[2] - ordered_pts[3])
    );
    float height = std::max(
        cv::norm(ordered_pts[0] - ordered_pts[3]),
        cv::norm(ordered_pts[1] - ordered_pts[2])
    );
    
    bool check_rot90 = (height > width * 1.5f);
    
    if (check_rot90) {
        std::swap(width, height);
    }
    
    std::vector<cv::Point2f> dst_pts = {
        cv::Point2f(0, 0),
        cv::Point2f(width, 0),
        cv::Point2f(width, height),
        cv::Point2f(0, height)
    };
    
    cv::Mat M = cv::getPerspectiveTransform(ordered_pts, dst_pts);
    
    cv::Mat cropped;
    cv::warpPerspective(image, cropped, M, cv::Size(static_cast<int>(width), static_cast<int>(height)));
    
    return std::make_tuple(cropped, ordered_pts, M, indices, check_rot90);
}

/**
 * Transform coordinates using perspective matrix
 */
inline std::vector<std::vector<float>> transform_coordinates(
    const std::vector<std::vector<float>>& points,
    const cv::Mat& M,
    const std::vector<int>& /*indices*/) {
    
    std::vector<cv::Point2f> src_pts;
    for (const auto& p : points) {
        src_pts.emplace_back(p[0], p[1]);
    }
    
    std::vector<cv::Point2f> dst_pts;
    cv::perspectiveTransform(src_pts, dst_pts, M);
    
    std::vector<std::vector<float>> result;
    for (const auto& p : dst_pts) {
        result.push_back({p.x, p.y});
    }
    
    return result;
}

/**
 * Crop image with polygon mask
 */
inline cv::Mat crop_image_with_polygon(const cv::Mat& image,
                                       const std::vector<std::vector<float>>& polygon,
                                       bool /*check_rot90*/) {
    if (polygon.size() < 3 || image.empty()) {
        return cv::Mat();
    }
    
    // Get bounding rect
    std::vector<cv::Point> pts;
    for (const auto& p : polygon) {
        pts.emplace_back(static_cast<int>(p[0]), static_cast<int>(p[1]));
    }
    
    cv::Rect bbox = cv::boundingRect(pts);
    
    // Clamp to image bounds
    bbox.x = std::max(0, bbox.x);
    bbox.y = std::max(0, bbox.y);
    bbox.width = std::min(bbox.width, image.cols - bbox.x);
    bbox.height = std::min(bbox.height, image.rows - bbox.y);
    
    if (bbox.width <= 0 || bbox.height <= 0) {
        return cv::Mat();
    }
    
    return image(bbox).clone();
}

} // namespace ppredictor

#endif // IMAGE_UTILS_H
