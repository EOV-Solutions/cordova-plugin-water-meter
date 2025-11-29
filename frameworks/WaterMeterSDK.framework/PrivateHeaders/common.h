//
//  common.h
//  WaterMeterSDK
//
//  Common definitions and utilities
//  Copyright © 2025 EOV Solutions. All rights reserved.
//

#ifndef COMMON_H
#define COMMON_H

#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <vector>
#include <string>

// Logging macros for iOS
#ifdef __APPLE__
#include <os/log.h>
#define LOGI(...) os_log_info(OS_LOG_DEFAULT, __VA_ARGS__)
#define LOGD(...) os_log_debug(OS_LOG_DEFAULT, __VA_ARGS__)
#define LOGW(...) os_log_error(OS_LOG_DEFAULT, __VA_ARGS__)
#define LOGE(...) os_log_error(OS_LOG_DEFAULT, __VA_ARGS__)
#else
#include <cstdio>
#define LOGI(...) printf(__VA_ARGS__)
#define LOGD(...) printf(__VA_ARGS__)
#define LOGW(...) printf(__VA_ARGS__)
#define LOGE(...) printf(__VA_ARGS__)
#endif

// Return codes
#define RETURN_OK 0
#define RETURN_ERROR -1

// Network types
enum NET_TYPE {
    NET_OCR = 0,
    NET_OCR_INTERNAL = 1
};

// Helper functions

/**
 * Find argmax in array
 */
template <typename T>
inline int64_t argmax(const T* data, size_t len) {
    int64_t max_idx = 0;
    T max_val = data[0];
    for (size_t i = 1; i < len; i++) {
        if (data[i] > max_val) {
            max_val = data[i];
            max_idx = i;
        }
    }
    return max_idx;
}

template <typename T>
inline int64_t argmax(const T* begin, const T* end) {
    return argmax(begin, end - begin);
}

// Note: penalized_conf, weighted_mean_conf implementations are in utility.cpp

#endif // COMMON_H
