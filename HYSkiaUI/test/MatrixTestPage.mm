#include "MatrixTestPage.h"
#include "ScrollView.h"
#include "TextView.h"
#include "ImageView.h"
#include "YUVVideoView.h"
#include "ProgressBar.h"

namespace HYSkiaUI {


void MatrixTestPage::init(std::shared_ptr<SkiaUIContext> &context, int width, int height) {
    setContext(context);
    setWidth(width);
    setHeight(height);
    setFlexWrap(YGWrapWrap);
    setFlexDirection(YGFlexDirectionColumn);
    setJustifyContent(YGJustifyCenter);
    setAlignItems(YGAlignCenter);
    setAlignContent(YGAlignCenter);
    setStyle(SkPaint::kFill_Style);
    initChildren(this, width, height);
}

void MatrixTestPage::initChildren(ViewGroup *root, int width, int height) {
    auto scrollView = new ScrollView();
    config = YGConfigNew();
    scrollView->setContext(this->context);
    scrollView->setFlexWrap(YGWrapNoWrap);
    scrollView->setFlexDirection(YGFlexDirectionColumn);
    scrollView->setJustifyContent(YGJustifyFlexStart);
    scrollView->setAlignItems(YGAlignCenter);
    scrollView->setAlignContent(YGAlignCenter);
    scrollView->setStyle(SkPaint::kFill_Style);
    scrollView->setBackgroundColor(SK_ColorWHITE);
    scrollView->setWidth(width);
    scrollView->setHeight(height);
    root->addView(scrollView);

    auto scaleXProgressBar = new ProgressBar();
    scaleXProgressBar->setContext(this->context);
    scaleXProgressBar->setBackgroundColor(SK_ColorGRAY);
    scaleXProgressBar->setBarColor(SK_ColorGREEN);
    scaleXProgressBar->setStrokeWidth(10.0);
    scaleXProgressBar->setAutoMode(false);
    scaleXProgressBar->setType(ProgressBar::ProgressBarType::LINEAR);
    scaleXProgressBar->setProgress(50);
    scaleXProgressBar->setStyle(SkPaint::kStroke_Style);
    scaleXProgressBar->setWidth(width);
    scaleXProgressBar->setHeight(60);
    scaleXProgressBar->setMargin({50, 50, 50, 50});
    scrollView->addView(scaleXProgressBar);
    scaleXProgressBar->setProgressCallback([this](int progress, bool finished) {
        auto scaleX = 1.0f;
        if (progress >= 50) {
            scaleX = progress / 50.0f;
        } else {
            scaleX = 0.5f + progress / 100.0f;
        }
        videoView->setScaleX(scaleX);
        shaderView->setScaleX(scaleX);
    });

    auto scaleYProgressBar = new ProgressBar();
    scaleYProgressBar->setContext(this->context);
    scaleYProgressBar->setBackgroundColor(SK_ColorGRAY);
    scaleYProgressBar->setBarColor(SK_ColorGREEN);
    scaleYProgressBar->setStrokeWidth(10.0);
    scaleYProgressBar->setAutoMode(false);
    scaleYProgressBar->setType(ProgressBar::ProgressBarType::LINEAR);
    scaleYProgressBar->setProgress(50);
    scaleYProgressBar->setStyle(SkPaint::kStroke_Style);
    scaleYProgressBar->setWidth(width);
    scaleYProgressBar->setHeight(60);
    scaleYProgressBar->setMargin({50, 50, 50, 50});
    scrollView->addView(scaleYProgressBar);
    scaleYProgressBar->setProgressCallback([this](int progress, bool finished) {
        auto scaleY = 1.0f;
        if (progress >= 50) {
            scaleY = progress / 50.0f;
        } else {
            scaleY = 0.5f + progress / 100.0f;
        }
        videoView->setScaleY(scaleY);
        shaderView->setScaleY(scaleY);
    });

    auto rotateZProgressBar = new ProgressBar();
    rotateZProgressBar->setContext(this->context);
    rotateZProgressBar->setBackgroundColor(SK_ColorGRAY);
    rotateZProgressBar->setBarColor(SK_ColorBLUE);
    rotateZProgressBar->setStrokeWidth(10.0);
    rotateZProgressBar->setAutoMode(false);
    rotateZProgressBar->setType(ProgressBar::ProgressBarType::LINEAR);
    rotateZProgressBar->setProgress(0);
    rotateZProgressBar->setStyle(SkPaint::kStroke_Style);
    rotateZProgressBar->setWidth(width);
    rotateZProgressBar->setHeight(60);
    rotateZProgressBar->setMargin({50, 50, 50, 50});
    scrollView->addView(rotateZProgressBar);
    rotateZProgressBar->setProgressCallback([this](int progress, bool finished) {
        auto rotateZ = progress / 100.0f * 360.0f;
        videoView->setRotateZ(rotateZ);
        shaderView->setRotateZ(rotateZ);
    });

    auto transXProgressBar = new ProgressBar();
    transXProgressBar->setContext(this->context);
    transXProgressBar->setBackgroundColor(SK_ColorGRAY);
    transXProgressBar->setBarColor(SK_ColorGREEN);
    transXProgressBar->setStrokeWidth(10.0);
    transXProgressBar->setAutoMode(false);
    transXProgressBar->setType(ProgressBar::ProgressBarType::LINEAR);
    transXProgressBar->setProgress(50);
    transXProgressBar->setStyle(SkPaint::kStroke_Style);
    transXProgressBar->setWidth(width);
    transXProgressBar->setHeight(60);
    transXProgressBar->setMargin({50, 50, 50, 50});
    scrollView->addView(transXProgressBar);
    transXProgressBar->setProgressCallback([this](int progress, bool finished) {
        auto transX = (progress - 50) * 4;
        videoView->setTransX(transX);
        shaderView->setTransX(transX);
    });

    auto transYProgressBar = new ProgressBar();
    transYProgressBar->setContext(this->context);
    transYProgressBar->setBackgroundColor(SK_ColorGRAY);
    transYProgressBar->setBarColor(SK_ColorGREEN);
    transYProgressBar->setStrokeWidth(10.0);
    transYProgressBar->setAutoMode(false);
    transYProgressBar->setType(ProgressBar::ProgressBarType::LINEAR);
    transYProgressBar->setProgress(50);
    transYProgressBar->setStyle(SkPaint::kStroke_Style);
    transYProgressBar->setWidth(width);
    transYProgressBar->setHeight(60);
    transYProgressBar->setMargin({50, 50, 50, 50});
    scrollView->addView(transYProgressBar);
    transYProgressBar->setProgressCallback([this](int progress, bool finished) {
        auto transY = (progress - 50) * 2;
        videoView->setTransY(transY);
        shaderView->setTransY(transY);
    });

    {
        videoView = new YUVVideoView();
        videoView->setContext(this->context);
        videoView->setWidth(1080);
        videoView->setHeight(360 * 1080 / 640);
        videoView->setMarginTop(200);
        videoView->setSource("yiluxiangbei.mp4");
        videoView->setStyle(SkPaint::kStroke_Style);
        scrollView->addView(videoView);
    }

    {
        shaderView = new ShaderView();
        shaderView->setContext(this->context);
        shaderView->setShaderPath("raining.glsl", {"raining.gif"});
        shaderView->setWidth(1080);
        shaderView->setHeight(520);
        scrollView->addView(shaderView);
    }

}

}
