#include "LottieView.h"

using namespace skottie;

namespace HYSkiaUI {

LottieView::LottieView() {
    paint->setColor(SK_ColorWHITE);
}

LottieView::~LottieView() {
    
}

void LottieView::setSource(const char *path) {
    MeasureTime measureTime("LottieView setSource");
    source = path;
    getContext()->runOnUIThread<const sk_sp<skottie::Animation> &>([this, path](){
        auto imageData = getContext()->getAssetManager()->readImage(path);
        auto length = imageData->length;
        auto animation = skottie::Animation::Make(reinterpret_cast<const char *>(imageData->content), length);
        delete imageData;
        return animation;
    }, [this](const sk_sp<skottie::Animation> &){
        auto assetManager = getContext()->getAssetManager();
        auto imageData = assetManager->readImage(source.c_str());
        auto length = imageData->length;
        lottieAnimation = Animation::Make(reinterpret_cast<const char *>(imageData->content),
                                          length);
        startTime = getContext()->getCurrentTimeMills();
        duration = lottieAnimation->duration() * 1000L;
        endTime = startTime + duration;
    });
}

const char *LottieView::getSource() {
    return source.c_str();
}

void LottieView::draw(SkCanvas *canvas) {
    View::draw(canvas);
    if (lottieAnimation == nullptr) {
        return;
    }
    canvas->save();
    canvas->setMatrix(viewMatrix);
    if (autoPlay) {
        auto currentTime = getContext()->getCurrentTimeMills();
        int totalFrames = lottieAnimation->duration() * lottieAnimation->fps();
        if (currentTime > endTime) {
            if (repeat) {
                startTime = currentTime;
                endTime = startTime + duration;
                lottieAnimation->seekFrame(0);
            } else {
                lottieAnimation->seekFrame(totalFrames);
            }
        } else {
            auto frame = (currentTime - startTime) * totalFrames / duration;
            lottieAnimation->seekFrame(frame);
        }
    }
    lottieAnimation->render(canvas, &lottieRect, Animation::RenderFlag::kDisableTopLevelClipping);
    canvas->restore();
    if (autoPlay) {
        markDirty();
    }
}

void LottieView::layout(int l, int t, int r, int b) {
    View::layout(l, t, r, b);
    lottieRect.setLTRB(l, t, r, b);
}

void LottieView::start() {
    if (!autoPlay) {
        auto diff = getContext()->getCurrentTimeMills() - pausedTime;
        startTime += diff;
        endTime += diff;
    }
    autoPlay = true;
    markDirty();
}

void LottieView::pause() {
    autoPlay = false;
    pausedTime = getContext()->getCurrentTimeMills();
}

void LottieView::setRepeat(bool repeat) {
    this->repeat = repeat;
}

const char *LottieView::name() {
    return "LottieView";
}

}
