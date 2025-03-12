#import "ExampleViewController.h"
#import "SkiaUIViewController.h"

@interface ExampleViewController ()
@property (nonatomic, strong) UIButton *buttonCpp;
@property (nonatomic, strong) UIButton *buttonReact;
@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建第一个按钮
    self.buttonCpp = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.buttonCpp setTitle:@"Cpp Demo" forState:UIControlStateNormal];
    [self.buttonCpp addTarget:self action:@selector(button1Clicked) forControlEvents:UIControlEventTouchUpInside];
    self.buttonCpp.frame = CGRectMake(100, 200, 200, 40);
    [self.view addSubview:self.buttonCpp];
    
    // 创建第二个按钮
    self.buttonReact = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.buttonReact setTitle:@"Reactjs Demo" forState:UIControlStateNormal];
    [self.buttonReact addTarget:self action:@selector(button2Clicked) forControlEvents:UIControlEventTouchUpInside];
    self.buttonReact.frame = CGRectMake(100, 300, 200, 40);
    [self.view addSubview:self.buttonReact];
}

- (void)button1Clicked {
    SkiaUIViewController *vc = [[SkiaUIViewController alloc] initWithType:0];
    vc.navigationItem.hidesBackButton = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)button2Clicked {
    SkiaUIViewController *vc = [[SkiaUIViewController alloc] initWithType:1];
    vc.navigationItem.hidesBackButton = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
