#include "JSAudioPlayer.h"

namespace HYSkiaUI {

JSAudioPlayer::JSAudioPlayer(const char* source) {
    player = [[HYAudioPlayer alloc]init];
    [player setSource:source];
}


JSAudioPlayer::~JSAudioPlayer() {
    
}

void JSAudioPlayer::setSource(const char *source) {
    [player setSource:source];
}

void JSAudioPlayer::play() {
    [player play];
}

void JSAudioPlayer::pause() {
    [player pause];
}

long JSAudioPlayer::getDuration() {
    return [player getDuration];
}

long JSAudioPlayer::getCurrPosition() {
    return [player getCurrPosition];
}

void JSAudioPlayer::seek(long timeMills) {
    [player seek:timeMills];
}

bool JSAudioPlayer::isPlaying() {
    return [player isPlaying];
}

void JSAudioPlayer::releasePlayer() {
    [player releasePlayer];
}

}
