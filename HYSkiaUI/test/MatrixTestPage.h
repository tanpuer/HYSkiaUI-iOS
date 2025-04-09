#pragma once

#include "Page.h"
#include "YUVVideoView.h"
#include "ShaderView.h"

namespace HYSkiaUI {

class MatrixTestPage : public Page {

public:

    void init(std::shared_ptr<SkiaUIContext> &context, int width, int height) override;

private:

    void initChildren(ViewGroup *root, int width, int height);

    YUVVideoView *videoView = nullptr;

    ShaderView *shaderView = nullptr;

};

}
