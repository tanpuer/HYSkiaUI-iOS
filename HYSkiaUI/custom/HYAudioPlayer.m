#import "HYAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface HYAudioPlayer()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end

@implementation HYAudioPlayer

- (void)dealloc {
    NSLog(@"HYAudioPlayer dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)setSource:(const char*) source {
    NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithUTF8String:source] withExtension:nil];
    if (!url) {
        NSLog(@"audio file not found %s", source);
        return;
    }
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.player.muted = NO;
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:self.playerItem.asset.tracks.firstObject];
    [audioInputParams setVolume:[AVAudioSession sharedInstance].outputVolume atTime:kCMTimeZero];
    audioMix.inputParameters = @[audioInputParams];
    self.playerItem.audioMix = audioMix;
    [self.player play];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
}

- (void)play {
    if (self.player == nil) {
        return;
    }
    [self.player play];
}

- (void)pause {
    if (self.player == nil) {
        return;
    }
    [self.player pause];
}

- (long)getCurrPosition {
    if (self.player == nil) {
        return 0L;
    }
    CMTime time = self.player.currentTime;
    CMTimeScale timescale = time.timescale;
    int64_t seconds = time.value / timescale;
    int64_t milliseconds = (time.value % timescale) * 1000 / timescale;
    return seconds * 1000 + milliseconds;
}

- (long)getDuration {
    if (self.player == nil) {
        return 0L;
    }
    CMTime time = self.player.currentItem.duration;
    CMTimeScale timescale = time.timescale;
    int64_t seconds = time.value / timescale;
    int64_t milliseconds = (time.value % timescale) * 1000 / timescale;
    return seconds * 1000 + milliseconds;
}

- (void)seek:(long) timeMills {
    if (self.player == nil) {
        return;
    }
    CMTime time = CMTimeMakeWithSeconds((double)timeMills / 1000.0, NSEC_PER_SEC);
    [self.player seekToTime:time];
}

- (bool)isPlaying {
    if (self.player == nil) {
        return false;
    }
    return self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying;
}

- (void)releasePlayer {
    if (self.player == nil) {
        return;
    }
    self.player = nil;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    NSLog(@"audio play end");
    [self.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
        if (finished) {
            [self.player play];
        }
    }];
}

@end
