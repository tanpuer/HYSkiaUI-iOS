#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYAudioPlayer : NSObject

- (void)setSource:(const char*) source;

- (void)play;

- (void)pause;

- (long)getCurrPosition;

- (long)getDuration;

- (void)seek:(long) timeMills;

- (bool)isPlaying;

- (void)releasePlayer;

@end

NS_ASSUME_NONNULL_END
