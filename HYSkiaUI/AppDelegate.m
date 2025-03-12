#import "AppDelegate.h"
#import "ExampleViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 创建窗口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    // 直接初始化你的主 ViewController
    ExampleViewController *mainVC = [[ExampleViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    // 设置为根控制器
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    // 全局导航栏样式
//    if (@available(iOS 13.0, *)) {
//        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
//        [appearance configureWithOpaqueBackground];
//        appearance.backgroundColor = [UIColor whiteColor];
//        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
//        [UINavigationBar appearance].standardAppearance = appearance;
//        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
//    } else {
//        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
//        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
//        [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
//    }
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
