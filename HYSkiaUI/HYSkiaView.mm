#import "HYSkiaView.h"
#import "memory"
#import "HYSkiaUIApp.hpp"
#import "HYSkiaMetalApp.hpp"
#import "native_log.h"
#import "touch/TouchEvent.h"

@interface TouchEventeWrapper : NSObject
@property (nonatomic, assign) TouchEvent* touchEvent;
@end

@implementation TouchEventeWrapper
@end

@interface SkiaPictureWrapper : NSObject
@property (nonatomic, assign) SkPicture* picture;
@end

@implementation SkiaPictureWrapper
@end

@interface HYSkiaView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) CADisplayLink *_displayLinkUI;
@property int _width;
@property int _height;
@property (nonatomic, strong) SkiaPictureWrapper *_picWrapper;
@property (nonatomic, assign) CGPoint lastTouchLocation;
@property (nonatomic, strong) NSDate *lastTouchTime;

@end

@implementation HYSkiaView {
    std::shared_ptr<HYSkiaUIApp> _skiaUIApp;
    std::shared_ptr<HYSkiaMetalApp> _skiaMetalApp;
    NSThread *_skiaMetalThread;
    NSThread *_skiaUIThread;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self->_skiaUIThread = [[NSThread alloc]initWithTarget:self selector:@selector(drawLoop) object:nullptr];
        [self->_skiaUIThread setName:@"skia-ui"];
        [self->_skiaUIThread start];
        self->_skiaMetalThread = [[NSThread alloc]initWithTarget:self selector:@selector(renderLoop) object:nullptr];
        [self->_skiaMetalThread setName:@"skia-metal"];
        [self->_skiaMetalThread start];
        self.userInteractionEnabled = YES;
        CGFloat scale = [[UIScreen mainScreen]scale];
        self._width = frame.size.width * scale;
        self._height = frame.size.height * scale;
        _skiaUIApp = std::make_shared<HYSkiaUIApp>(self._width, self._height, self->_skiaUIThread);
        _skiaMetalApp = std::make_shared<HYSkiaMetalApp>(self._width, self._height);
        [self.layer addSublayer:_skiaMetalApp->getLayer()];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self._displayLinkUI = [CADisplayLink displayLinkWithTarget:self selector:@selector(onVsync)];
            if (@available(iOS 15.0, *)) {
                CAFrameRateRange rate = CAFrameRateRangeMake(60, 120, 120);
                self._displayLinkUI.preferredFrameRateRange = rate;
            } else {
                self._displayLinkUI.preferredFramesPerSecond = 60;
            }
            [self._displayLinkUI addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        });
    }
    return self;
}

- (void)dealloc {
    [self._displayLinkUI invalidate];
    [self->_skiaUIThread cancel];
    [self->_skiaMetalThread cancel];
}

- (void)onVsync {
    [self performSelector:@selector(draw) onThread:self->_skiaUIThread withObject:nullptr waitUntilDone:NO];
    [self performSelector:@selector(render) onThread:self->_skiaMetalThread withObject:nullptr waitUntilDone:NO];
}

- (void)drawLoop {
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [runLoop run];
}

- (void)renderLoop {
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [runLoop run];
}

- (void)draw {
    CFTimeInterval time = CACurrentMediaTime() * 1000;
    IAnimator::currTime = time;
    auto picture = _skiaUIApp->doFrame(time);
    SkiaPictureWrapper *wrapper = [[SkiaPictureWrapper alloc] init];
    wrapper.picture = picture;
    [self performSelector:@selector(setPic:) onThread:self->_skiaMetalThread withObject:wrapper waitUntilDone:NO];
}

- (void)render {
    if (self._picWrapper != nil) {
        _skiaMetalApp->draw(self._picWrapper.picture);
    }
    self._picWrapper = nil;
}

- (void)setPic: (SkiaPictureWrapper*)wrapper {
    if (self._picWrapper != nil) {
        self._picWrapper.picture->unref();
        self._picWrapper = nil;
    }
    self._picWrapper = wrapper;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        CGPoint p = [t locationInView:self];
        [self dispatchTouchEvent:TouchEvent::MotionEvent::ACTION_DOWN witchTouchX:p.x withTouchY:p.y];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        CGPoint p = [t locationInView:self];
        [self dispatchTouchEvent:TouchEvent::MotionEvent::ACTION_MOVE witchTouchX:p.x withTouchY:p.y];
        self.lastTouchLocation = p;
        self.lastTouchTime = [NSDate date];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        CGPoint p = [t locationInView:self];
        NSDate *currentTime = [NSDate date];
        CGFloat dx = p.x - self.lastTouchLocation.x;
        CGFloat dy = p.y - self.lastTouchLocation.y;
        NSTimeInterval dt = [currentTime timeIntervalSinceDate:self.lastTouchTime];
        if (dt > 0) {
            CGFloat scale = [[UIScreen mainScreen]scale];
            CGFloat vx = dx / dt;
            CGFloat vy = dy / dt;
            [self performBlockOnUIThread:^{
                //TODO velocity calculate
                self->_skiaUIApp->setVelocity(vx * scale, vy * scale);
            }];
        }
        [self dispatchTouchEvent:TouchEvent::MotionEvent::ACTION_UP witchTouchX:p.x withTouchY:p.y];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        CGPoint p = [t locationInView:self];
        [self dispatchTouchEvent:TouchEvent::MotionEvent::ACTION_CANCEL witchTouchX:p.x withTouchY:p.y];
    }
}

- (void)dispatchTouchEvent: (TouchEvent::MotionEvent)action witchTouchX:(float)x withTouchY:(float)y {
    CGFloat scale = [[UIScreen mainScreen]scale];
    auto event = new TouchEvent(action, scale * x, scale * y);
    __block TouchEventeWrapper *wrapper = [[TouchEventeWrapper alloc]init];
    wrapper.touchEvent = event;
    [self performBlockOnUIThread:^{
        self->_skiaUIApp->dispatchTouchEvent(wrapper.touchEvent);
        wrapper = nil;
    }];
}

- (void)setTouchEventToUI: (TouchEventeWrapper*) wrappper {
    _skiaUIApp->dispatchTouchEvent(wrappper.touchEvent);
    wrappper = nil;
}

- (void)performBlockOnUIThread:(void(^)(void))block {
    if ([NSThread currentThread] == self->_skiaUIThread) {
        block();
    } else {
        void (^blockCopy)(void) = [block copy];
        [self performSelector:@selector(executeBlockOnUIThread:)
                     onThread:self->_skiaUIThread
                   withObject:blockCopy
                waitUntilDone:NO];
    }
}

- (void)executeBlockOnUIThread:(void(^)(void))block {
    block();
}

- (void)onBackPressed: (float)distance {
    [self performBlockOnUIThread:^{
        self->_skiaUIApp->onBackPressed(distance);
    }];
}

- (void)onBackMoved:(float)distance {
    [self performBlockOnUIThread:^{
        self->_skiaUIApp->onBackMoved(distance);
    }];
}

@end