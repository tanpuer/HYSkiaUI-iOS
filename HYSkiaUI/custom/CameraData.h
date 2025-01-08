#pragma once

namespace HYSkiaUI {

struct CameraData {
    uint8_t* y;
    size_t yWidth;
    size_t yHeight;
    
    uint8_t* uv;
    size_t uvWidth;
    size_t uvHeight;
    
    ~CameraData() {
        free(y);
        free(uv);
    }
};

}
