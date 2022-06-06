/**
 * SplashScreen
 * 启动屏
 * from：http://www.devio.org
 * Author:CrazyCodeBoy
 * GitHub:https://github.com/crazycodeboy
 * Email:crazycodeboy@gmail.com
 */

#import "RNSplashScreen.h"
#import <React/RCTBridge.h>

static bool waiting = true;
static bool addedJsLoadErrorObserver = false;
static UIView* loadingView = nil;
static bool isShowing = false;
static UIView *saveRootView = nil;

@implementation RNSplashScreen
- (dispatch_queue_t)methodQueue{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE(SplashScreen)

+ (void)show {
    if (isShowing) {
        return;
    }
    isShowing = true;
    if (!addedJsLoadErrorObserver) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsLoadError:) name:RCTJavaScriptDidFailToLoadNotification object:nil];
        addedJsLoadErrorObserver = true;
    }

    while (waiting) {
        NSDate* later = [NSDate dateWithTimeIntervalSinceNow:0.1];
        [[NSRunLoop mainRunLoop] runUntilDate:later];
    }
}

+ (void)showSplash:(NSString*)splashScreen inRootView:(UIView*)rootView {
    if (isShowing) {
        return;
    }
    saveRootView = rootView;
    isShowing = true;
    if (!loadingView) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        loadingView = vc.view;
        CGRect frame = rootView.frame;
        frame.origin = CGPointMake(0, 0);
        loadingView.frame = frame;
    }
    waiting = false;
    
    [rootView addSubview:loadingView];
}

+ (void)hide {
    if (waiting) {
        dispatch_async(dispatch_get_main_queue(), ^{
            waiting = false;
            isShowing = false;
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [loadingView removeFromSuperview];
            isShowing = false;
        });
    }
}

+ (void) jsLoadError:(NSNotification*)notification
{
    // If there was an error loading javascript, hide the splash screen so it can be shown.  Otherwise the splash screen will remain forever, which is a hassle to debug.
    [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(hide) {
    [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(show) {
    if (saveRootView == nil) {
        [RNSplashScreen show];
    } else {
        [RNSplashScreen showSplash:@"LaunchScreen" inRootView:saveRootView];
    }
}

@end
