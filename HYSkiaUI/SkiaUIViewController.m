#import "SkiaUIViewController.h"
#import "HYSkiaView.h"

@interface SkiaUIViewController () <HYSkiaViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *_leftEdgePanGesture;
@property (nonatomic, strong) HYSkiaView *_skiaView;

@property (nonatomic, strong) UITextView *_fpsView;

@property (nonatomic, assign) NSInteger _type;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *customPopGesture;

@end

@implementation SkiaUIViewController

- (instancetype)initWithType:(NSInteger)type {
    if (self = [super init]) {
        self._type = type;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"~SkiaUIViewController");
    [self.view removeGestureRecognizer:self._leftEdgePanGesture];
    [self._skiaView removeFromSuperview];
    self._skiaView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    _customPopGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCustomPopGesture:)];
    _customPopGesture.edges = UIRectEdgeLeft;
    _customPopGesture.delegate = self;
    [self.view addGestureRecognizer:_customPopGesture];
    
    
    int width = [UIScreen mainScreen].bounds.size.width;
    int height = [UIScreen mainScreen].bounds.size.height;
    CGFloat statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = (UIWindowScene *)UIApplication.sharedApplication.connectedScenes.anyObject;
        statusBarHeight = windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
#pragma clang diagnostic pop
    }
    height -= statusBarHeight;
    self._skiaView = [[HYSkiaView alloc]initWithFrame:CGRectMake(0, 0, width, height) type:self._type];
    self._skiaView.delegate = self;
    [self.view addSubview: self._skiaView];
    self._skiaView.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 11.0, *)) {
        UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
        [NSLayoutConstraint activateConstraints:@[
            [self._skiaView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
            [self._skiaView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
            [self._skiaView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
            [self._skiaView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor]
        ]];
    }
    self._leftEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgePan:)];
    self._leftEdgePanGesture.edges = UIRectEdgeLeft;
    self._leftEdgePanGesture.delegate = (id)self;
    [self.view addGestureRecognizer:self._leftEdgePanGesture];
    
    self._fpsView = [[UITextView alloc] init];
    self._fpsView.text = @"";
    self._fpsView.textColor = [UIColor redColor];
    self._fpsView.editable = NO;
    self._fpsView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    self._fpsView.font = [UIFont systemFontOfSize:20];
    self._fpsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self._fpsView];
    [NSLayoutConstraint activateConstraints:@[
        [self._fpsView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:statusBarHeight - 20],
        [self._fpsView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0],
        [self._fpsView.widthAnchor constraintEqualToConstant:200], // 设置宽度为200
        [self._fpsView.heightAnchor constraintLessThanOrEqualToConstant:50], // 设置最大高度为100
    ]];
}

- (void)handleLeftEdgePan:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    if (translation.x < 0) {
        translation.x = 0.0f;
    }
    switch (recognizer.state) {
        case UIGestureRecognizerStateChanged: {
            CGFloat scale = [[UIScreen mainScreen]scale];
            [self._skiaView onBackMoved:translation.x * scale];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGFloat scale = [[UIScreen mainScreen]scale];
            [self._skiaView onBackPressed:translation.x * scale];
            break;
        }
        default:
            break;
    }
}

- (void)skiaViewRenderUpdate:(int)renderCount withDrawCount:(int)drawCount {
    if (self._fpsView != nil) {
        [self._fpsView setText: [NSString stringWithFormat:@"render: %d, draw: %d", renderCount, drawCount]];
    }
}

#pragma mark - 手势处理
- (void)handleCustomPopGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    if (translation.x < 0) {
        translation.x = 0.0f;
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateChanged: {
            CGFloat scale = [[UIScreen mainScreen]scale];
            [self._skiaView onBackMoved:translation.x * scale];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGFloat scale = [[UIScreen mainScreen]scale];
            [self._skiaView onBackPressed:translation.x * scale];
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _customPopGesture) {
        return YES;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

