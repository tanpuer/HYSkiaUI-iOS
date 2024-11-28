#include "AudioFFTView.h"

AudioFFTView::AudioFFTView() {
    fftPaint = std::make_unique<SkPaint>();
    fftPaint->setAntiAlias(true);
    fftPaint->setColor(SK_ColorRED);
    fftPaint->setStrokeWidth(5);
    player = [[HYAudioPlayer alloc]init];
}

AudioFFTView::~AudioFFTView() {
    player = nullptr;
}

void AudioFFTView::setSource(const char *path) {
    [player setSource:path];
}

void AudioFFTView::draw(SkCanvas *canvas) {
    View::draw(canvas);
    auto widthDiff = width * 1.0f / count;
    auto heightDiff = height * 1.0f / count;
    //    if (audioPlayer != nullptr) {
    //        auto jni = context->getJniEnv();
    //        auto fft = static_cast<jfloatArray>(jni->CallObjectMethod(audioPlayer, getFFTDataMethodID));
    //        auto length = jni->GetArrayLength(fft);
    //        if (length <= 0) {
    //            return;
    //        }
    //        jfloat *floatArray = jni->GetFloatArrayElements(fft, NULL);
    //        for (int i = 0; i < length; ++i) {
    //            auto x0 = left + i * widthDiff;
    //            auto y0 = bottom - floatArray[i] * 2;
    //            auto x1 = x0 + widthDiff;
    //            auto y1 = bottom;
    //            canvas->drawLine(x0, y0, x0, y1, *fftPaint);
    //        }
    //        jni->ReleaseFloatArrayElements(fft, floatArray, 0);
    //    }
}

void AudioFFTView::onShow() {
    if (userPause) {
        return;
    }
    innerPlay();
}

void AudioFFTView::onHide() {
    if (userPause) {
        return;
    }
    innerPause();
}

long AudioFFTView::getCurrPosition() {
    if (player == nullptr) {
        return 0L;
    }
    return [player getCurrPosition];
}

long AudioFFTView::getDuration() {
    if (player == nullptr) {
        return 0L;
    }
    return [player getDuration];
}

void AudioFFTView::seek(long timeMills) {
    if (player == nullptr) {
        return;
    }
    [player seek:timeMills];
}

bool AudioFFTView::isPlaying() {
    if (player == nullptr) {
        return false;
    }
    return [player isPlaying];
}

void AudioFFTView::play() {
    userPause = false;
    innerPlay();
}

void AudioFFTView::pause() {
    userPause = true;
    innerPause();
}

void AudioFFTView::innerPause() {
    if (player == nullptr) {
        return;
    }
    [player pause];
}

void AudioFFTView::innerPlay() {
    if (player == nullptr) {
        return;
    }
    [player play];
}
