#import "ViewController.h"
#import "HYSkiaView.h"

@interface ViewController ()

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *_leftEdgePanGesture;
@property (nonatomic, strong) HYSkiaView *_skiaView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    int width = [UIScreen mainScreen].bounds.size.width;
    int height = [UIScreen mainScreen].bounds.size.height;
    self._skiaView = [[HYSkiaView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
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
}

- (void)handleLeftEdgePan:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
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

@end