#pragma once

#include "View.h"
#include "HYAudioPlayer.h"

namespace HYSkiaUI {

class AudioFFTView : public View {
    
public:
    
    AudioFFTView();
    
    ~AudioFFTView();
    
    void setSource(const char *path);
    
    void draw(SkCanvas *canvas) override;
    
    void onShow() override;
    
    void onHide() override;
    
    long getCurrPosition();
    
    long getDuration();
    
    void seek(long timeMills);
    
    bool isPlaying();
    
    void play();
    
    void pause();
    
private:
    
    std::unique_ptr<SkPaint> fftPaint;
    
    uint32_t count = 60;
    
    bool userPause = false;
    
    void innerPause();
    
    void innerPlay();
    
    HYAudioPlayer *player = nullptr;
    
};

}
