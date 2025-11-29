//
//  ppredictor.h
//  WaterMeterSDK
//
//  PaddleLite Predictor wrapper
//  Copyright © 2025 EOV Solutions. All rights reserved.
//

#ifndef PPREDICTOR_H
#define PPREDICTOR_H

#include "common.h"
#include "paddle_api.h"
// NOTE: paddle_use_kernels.h and paddle_use_ops.h are included in ppredictor.cpp ONLY
// Including them in a header causes duplicate symbols when header is included by multiple files
#include <memory>
#include <vector>
#include <string>

namespace ppredictor {

/**
 * Predictor input wrapper
 */
class PredictorInput {
public:
    PredictorInput(std::unique_ptr<paddle::lite_api::Tensor> tensor)
        : _tensor(std::move(tensor)) {}
    
    void set_dims(const std::vector<int64_t>& dims) {
        _tensor->Resize(dims);
    }
    
    float* get_mutable_float_data() {
        return _tensor->mutable_data<float>();
    }
    
    std::vector<int64_t> get_shape() const {
        return _tensor->shape();
    }

private:
    std::unique_ptr<paddle::lite_api::Tensor> _tensor;
};

/**
 * Predictor output wrapper
 */
class PredictorOutput {
public:
    PredictorOutput(std::unique_ptr<const paddle::lite_api::Tensor> tensor)
        : _tensor(std::move(tensor)) {}
    
    const float* get_float_data() const {
        return _tensor->data<float>();
    }
    
    const int* get_int_data() const {
        return _tensor->data<int>();
    }
    
    std::vector<int64_t> get_shape() const {
        return _tensor->shape();
    }
    
    int64_t get_size() const {
        int64_t size = 1;
        auto shape = _tensor->shape();
        for (auto dim : shape) {
            size *= dim;
        }
        return size;
    }
    
    std::vector<std::vector<uint64_t>> get_lod() const {
        return _tensor->lod();
    }

private:
    std::unique_ptr<const paddle::lite_api::Tensor> _tensor;
};

/**
 * Predictor interface
 */
class PPredictor_Interface {
public:
    virtual ~PPredictor_Interface() {}
    virtual NET_TYPE get_net_flag() const = 0;
};

/**
 * PaddleLite predictor wrapper
 */
class PPredictor : public PPredictor_Interface {
public:
    PPredictor(int use_opencl, int thread_num, NET_TYPE net_type, 
               paddle::lite_api::PowerMode mode);
    
    virtual ~PPredictor() {}
    
    // Initialize from file
    int init_from_file(const std::string& model_path);
    
    // Initialize from buffer
    int init_nb(const std::string& model_content);
    
    // Get input tensor
    PredictorInput get_first_input();
    PredictorInput get_input(int index);
    
    // Run inference
    std::vector<PredictorOutput> infer();
    
    virtual NET_TYPE get_net_flag() const override {
        return _net_type;
    }

private:
    std::shared_ptr<paddle::lite_api::PaddlePredictor> _predictor;
    int _thread_num;
    int _use_opencl;
    NET_TYPE _net_type;
    paddle::lite_api::PowerMode _mode;
};

} // namespace ppredictor

#endif // PPREDICTOR_H
