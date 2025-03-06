#pragma once

#include "HYAudioPlayer.h"

namespace HYSkiaUI {

class JSAudioPlayer {
    
public:
    
    JSAudioPlayer(const char* source);
    
    ~JSAudioPlayer();
    
    void setSource(const char* source);

    void play();

    void pause();

    long getCurrPosition();

    long getDuration();

    void seek(long timeMills);

    bool isPlaying();

    void releasePlayer();
    
private:
    
    HYAudioPlayer *player = nullptr;
    
};

}
