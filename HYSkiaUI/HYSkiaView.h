#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HYSkiaViewDelegate <NSObject>
- (void)skiaViewRenderUpdate:(int)renderCount withDrawCount:(int)drawCount;
@end

@interface HYSkiaView : UIView

- (void)onBackPressed: (float)distance;

- (void)onBackMoved: (float)distance;

@property (nonatomic, weak) id<HYSkiaViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
