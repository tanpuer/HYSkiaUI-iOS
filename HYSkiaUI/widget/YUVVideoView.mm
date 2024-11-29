#include "YUVVideoView.h"
#include "core/SkPictureRecorder.h"
#include "core/SkPicture.h"

YUVVideoView::YUVVideoView() {
    videoPaint = std::make_unique<SkPaint>();
    videoPaint->setAntiAlias(true);
}

YUVVideoView::~YUVVideoView() {
    [videoDecoder stop];
    videoDecoder = nullptr;
}

void YUVVideoView::setSource(const char *path) {
    MeasureTime measureTime("VideoView setSource");
    src = std::string(path);
    auto assetManager = getContext()->getAssetManager();
    const char *kYUVtoRGBShader = assetManager->readFile("nv12_fragment_shader.glsl");
    auto [effect, error] = SkRuntimeEffect::MakeForShader(SkString(kYUVtoRGBShader));
    if (!effect) {
        ALOGD("set shader source failed %s", error.data())
        return;
    }
    runtimeEffect = effect;
    firstFrame = true;
    videoDecoder = [[HYVideoDecoder alloc]init:(void *)(getContext().get())];
    [videoDecoder setSource:path];
}

const char *YUVVideoView::getSource() {
    return src.c_str();
}

void YUVVideoView::draw(SkCanvas *canvas) {
    if (videoDecoder == nullptr) {
        return;
    }
    auto yuvData = [videoDecoder getFrameData];
    if (yuvData == nullptr) {
        return;
    }
    int width = yuvData->width;
    int height = yuvData->height;
    int ySize = yuvData->yStride * height;
    int uvSize = yuvData->uvStride * height / 2;
    if (runtimeEffect != nullptr) {
        SkCanvas *skCanvas;
        SkPictureRecorder recorder;
        skCanvas = recorder.beginRecording(width, height);
        auto y_imageInfo = SkImageInfo::Make(yuvData->yStride, height, kGray_8_SkColorType, kPremul_SkAlphaType);
        auto uv_imageInfo = SkImageInfo::Make(yuvData->uvStride / 2, height / 2, kR8G8_unorm_SkColorType, kPremul_SkAlphaType);
        sk_sp<SkData> y_data = SkData::MakeWithCopy(yuvData->yData, ySize);
        sk_sp<SkData> uv_data = SkData::MakeWithCopy(yuvData->uvData, uvSize);
        if (!uv_data) {
            ALOGD("Failed to create UV data copy");
            return;
        }
        auto y_image = SkImages::RasterFromData(y_imageInfo, y_data, yuvData->yStride);
        if (!y_image) {
            ALOGD("Failed to create Y texture");
            return;
        }
        auto uv_image = SkImages::RasterFromData(uv_imageInfo, uv_data, yuvData->uvStride);
        if (!uv_image) {
            ALOGD("Failed to create UV texture. Possible reasons:");
            ALOGD("1. Stride alignment: %d", yuvData->uvStride);
            ALOGD("2. Required size: %zu, Actual size: %zu", 
                  uv_imageInfo.computeMinByteSize(), 
                  uv_data->size());
            return;
        }
        SkRuntimeShaderBuilder builder(runtimeEffect);
        builder.child("y_tex") = y_image->makeShader(SkSamplingOptions());
        builder.child("uv_tex") = uv_image->makeShader(SkSamplingOptions());
        float widthRatio = this->width * 1.0f / width;
        float heightRatio = this->height * 1.0f / height;
        float ratio = std::min(widthRatio, heightRatio);
        builder.uniform("widthRatio") = ratio;
        builder.uniform("heightRatio") = ratio;
        sk_sp<SkShader> shader = builder.makeShader();
        SkPaint skPaint;
        skPaint.setShader(std::move(shader));
        skCanvas->drawRect(SkRect::MakeXYWH(0, 0, width * ratio, height * ratio),
                           skPaint);
        auto picture = recorder.finishRecordingAsPicture();
        canvas->save();
        canvas->translate(left, top);
        canvas->drawPicture(picture);
        canvas->restore();
        if (firstFrame) {
            firstFrame = false;
            if (renderFirstFrameCallback != nullptr) {
                renderFirstFrameCallback();
            }
        }
    }
}

void YUVVideoView::start() {
    if (videoDecoder == nullptr) {
        return;
    }
    [videoDecoder start];
}

void YUVVideoView::pause() {
    if (videoDecoder == nullptr) {
        return;
    }
    [videoDecoder pause];
}

void YUVVideoView::onShow() {
    start();
}

void YUVVideoView::onHide() {
    pause();
}

const char *YUVVideoView::name() {
    return "YUVVideoView";
}

void YUVVideoView::setRenderFirstFrameCallback(std::function<void()> &&callback) {
    this->renderFirstFrameCallback = std::move(callback);
}
