#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
// 防重复弹窗（1秒内同一URL不重复）
static NSString *_lastURL = nil;
static NSDate   *_lastTime = nil;
static void showQRAlert(NSString *urlString) {
    if (!urlString || urlString.length < 8) return;
    // 去重判断
    NSDate *now = [NSDate date];
    if (_lastURL && [_lastURL isEqualToString:urlString] &&
        _lastTime && [now timeIntervalSinceDate:_lastTime] < 1.5) {
        return;
    }
    _lastURL  = urlString;
    _lastTime = now;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"🔍 识别成功"
            message:[NSString stringWithFormat:@"URL：%@", urlString]
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction
            actionWithTitle:@"复制链接"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *a) {
                [UIPasteboard generalPasteboard].string = urlString;
            }]];
        [alert addAction:[UIAlertAction
            actionWithTitle:@"关闭"
            style:UIAlertActionStyleCancel
            handler:nil]];
        UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (top.presentedViewController) top = top.presentedViewController;
        [top presentViewController:alert animated:YES completion:nil];
    });
}
// ===== Hook 1: 系统相机二维码解码（最核心）=====
%hook AVMetadataMachineReadableCodeObject
- (NSString *)stringValue {
    NSString *v = %orig;
    if (v.length > 0) {
        showQRAlert(v);
    }
    return v;
}
%end
// ===== Hook 2: WKWebView URL拦截 =====
%hook WKWebView
- (void)loadRequest:(NSURLRequest *)request {
    NSString *url = request.URL.absoluteString;
    if (url.length > 10 &&
        ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"] ||
         [url hasPrefix:@"weread://"])) {
        NSString *path = request.URL.path ?: @"";
        if ([path containsString:@"qr"] || [path containsString:@"scan"] ||
            [url containsString:@"qrcode"] || [url containsString:@"scanResult"]) {
            showQRAlert(url);
        }
    }
    %orig;
}
%end
