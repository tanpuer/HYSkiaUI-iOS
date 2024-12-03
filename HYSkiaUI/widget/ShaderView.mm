#include "ShaderView.h"
#include "SkiaUIContext.h"
#include "core/SkPictureRecorder.h"
#include "core/SkPicture.h"
#include "codec/SkAndroidCodec.h"
#include "android/SkAnimatedImage.h"

ShaderView::ShaderView() {
    
}

ShaderView::~ShaderView() {
    
}

void ShaderView::setShaderSource(const char *data, std::vector<std::string> images) {
    shaderStr = data;
    skShaders.clear();
    imageResolutions.clear();
    uniformVector.clear();
    runtimeEffect = nullptr;
    imageSize = images.size();
    if (imageSize == 0) {
        createEffect();
        return;
    }
    for (int i = 0; i < images.size(); ++i) {
        auto image = images[i];
        getContext()->runOnUIThread<const sk_sp<SkImage>>([this, image](){
            auto imageData = getContext()->getAssetManager()->readImage(image.c_str());
            auto skData = SkData::MakeWithProc(imageData->content, imageData->length, nullptr, nullptr);
            auto codec = SkAndroidCodec::MakeFromData(skData);
            auto animatedImage = SkAnimatedImage::Make(std::move(codec));
            delete imageData;
            return animatedImage->getCurrentFrame();
        }, [this, i](const auto& skImage) {
            auto shader = skImage->makeShader(SkSamplingOptions());
            skShaders["iChannel" + std::to_string(i)] = std::move(shader);
            ResolutionUniforms resolutionUniforms;
            if (skImage != nullptr) {
                resolutionUniforms.width = skImage->width();
                resolutionUniforms.height = skImage->height();
            }
            imageResolutions["iChannel" + std::to_string(i) +
                             "Resolution"] = resolutionUniforms;
            this->imageSize--;
            if (this->imageSize == 0) {
                this->createEffect();
            }
        });
    }
}

void ShaderView::setShaderPath(const char *path, std::vector<std::string> images) {
    getContext()->runOnUIThread<char *>([this, path]() {
        MeasureTime measureTime("setShaderPath");
        return getContext()->getAssetManager()->readFile(path);
    }, [this, images](const char* result) {
        if (result != nullptr) {
            setShaderSource(result, images);
            delete result;
            markDirty();
        }
    });
}

void ShaderView::draw(SkCanvas *canvas) {
    if (runtimeEffect != nullptr) {
        SkCanvas *skCanvas;
        SkPictureRecorder recorder;
        skCanvas = recorder.beginRecording(width, height);
        ResolutionUniforms uniforms;
        uniforms.width = width;
        uniforms.height = height;
        SkRuntimeShaderBuilder builder(runtimeEffect);
        builder.uniform("iResolution") = uniforms;
        auto time = getContext()->getCurrentTimeMills();
        builder.uniform("iTime") = (float) time / 1000;
        builder.uniform("shaderTouchX") = shaderTouchX;
        for (const auto &item: uniformVector) {
            builder.uniform(item.first) = item.second;
        }
        for (auto &pair: skShaders) {
            builder.child(pair.first) = pair.second;
        }
        for (auto &pair: imageResolutions) {
            builder.uniform(pair.first) = pair.second;
        }
        auto shader = builder.makeShader(nullptr);
        SkPaint skPaint;
        skPaint.setShader(std::move(shader));
        skCanvas->drawIRect({0, 0, width, height}, skPaint);
        auto picture = recorder.finishRecordingAsPicture();
        canvas->save();
        canvas->translate(left, top);
        canvas->drawPicture(picture);
        canvas->restore();
    }
}

void ShaderView::setPictures(std::vector<sk_sp<SkPicture>> otherPictures) {
    skShaders.clear();
    for (int i = 0; i < otherPictures.size(); ++i) {
        auto shader = otherPictures[i]->makeShader(SkTileMode::kClamp, SkTileMode::kClamp,
                                                   SkFilterMode::kLinear);
        skShaders["iChannel" + std::to_string(i)] = std::move(shader);
    }
    markDirty();
}

void ShaderView::setCustomUniforms(std::string key, float value) {
    uniformVector[key] = value;
}

const char *ShaderView::name() {
    return "ShaderView";
}

bool ShaderView::onTouchEvent(TouchEvent *touchEvent) {
    switch (touchEvent->action) {
        case TouchEvent::ACTION_DOWN:
        case TouchEvent::ACTION_MOVE: {
            shaderTouchX = touchEvent->x - left;
            break;
        }
        case TouchEvent::ACTION_UP:
        case TouchEvent::ACTION_CANCEL: {
            shaderTouchX = -1.0f;
            break;
        }
    }
    return View::onTouchEvent(touchEvent);
}

bool ShaderView::onInterceptTouchEvent(TouchEvent *touchEvent) {
    switch (touchEvent->action) {
        case TouchEvent::ACTION_DOWN: {
            lastScrollX = touchEvent->x;
            lastScrollY = touchEvent->y;
            break;
        }
        case TouchEvent::ACTION_MOVE: {
            auto diffX = abs(touchEvent->x - lastScrollX);
            auto diffY = abs(touchEvent->y - lastScrollY);
            shaderTouchX = touchEvent->x - left;
            return diffX > diffY;
        }
        default:
            break;
    }
    return true;
}

void ShaderView::createEffect() {
    auto createEffect = [this]() {
        auto [effect, error] = SkRuntimeEffect::MakeForShader(SkString(this->shaderStr.c_str()));
        if (!effect) {
            ALOGD("set shader source failed %s", error.data())
            return;
        }
        runtimeEffect = effect;
        markDirty();
    };
    createEffect();
}
