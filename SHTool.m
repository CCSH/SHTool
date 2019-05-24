//
//  SHTool.m
//  SHExtensionExample
//
//  Created by CSH on 2019/5/24.
//  Copyright © 2019 CSH. All rights reserved.
//

#import "SHTool.h"
#import <WebKit/WebKit.h>

@interface SHTool () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, copy) toolBlock block;

@property (nonatomic, assign) CGFloat webH;

@end

@implementation SHTool

#pragma mark - 私有方法
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        _webView.frame = CGRectMake(0, 0, 0, 1);
        _webView.scrollView.bounces = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        _webView.scrollView.scrollEnabled = NO;
        _webView.navigationDelegate = self;
        [self addSubview:_webView];
    }
    return _webView;
}

#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 计算WKWebView高度
    [webView evaluateJavaScript:@"document.body.offsetHeight"
              completionHandler:^(id _Nullable result, NSError *_Nullable error) {

                  if (self.webH != [result floatValue]) {
                      self.webH = [result floatValue];
                      [self dealBlock];
                  }

                  [self dealView];
              }];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self dealBlock];
    [self dealView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"] && object == self.webView.scrollView) {
        CGSize size = [[change valueForKey:NSKeyValueChangeNewKey] CGSizeValue];

        if (self.webH != size.height) {
            self.webH = size.height;
            [self dealBlock];
        }
    }
}

- (void)dealView {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.webView.navigationDelegate = nil;
    self.webView = nil;
    self.block = nil;
    [self removeFromSuperview];
}

- (void)dealBlock {
    if (self.block) {
        self.block([NSString stringWithFormat:@"%f", self.webH]);
    }
}

- (void)configWebWithMaxW:(CGFloat)maxW
                isInstant:(BOOL)isInstant
                    block:(toolBlock)block {
    self.hidden = YES;
    self.webH = 0;
    self.block = block;

    CGRect frame = self.webView.frame;
    frame.size.width = maxW;
    self.webView.frame = frame;

    if (isInstant) {
        [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }

    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:self];
}

#pragma mark - 公共方法
#pragma mark 获取毫秒值
+ (NSString *)getTimeMs {
    NSDate *date = [NSDate date];
    UInt64 recordTime = [date timeIntervalSince1970] * 1000;
    return [NSString stringWithFormat:@"%llu", recordTime];
}

#pragma mark 获取时间（毫秒）
+ (NSString *)getTimeMsWithMs:(NSString *)ms
                       format:(NSString *)format {
    if (!ms.length) {
        return @"";
    }

    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[ms longLongValue] / 1000];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];

    return [formatter stringFromDate:date];
}

#pragma mark 获取时间
+ (NSString *)getTimeWithTime:(NSString *)time
                       format:(NSString *)format
                 targetFormat:(NSString *)targetFormat {
    if (time.length) {
        return @"";
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];

    NSDate *date = [formatter dateFromString:time];
    [formatter setDateFormat:targetFormat];

    return [formatter stringFromDate:date];
}

#pragma mark 获取即时时间
+ (NSString *)getInstantTimeWithTime:(NSString *)time {
    if (!time) {
        return @"";
    }

    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = sh_fomat_1;
    NSDate *currentDate = [format dateFromString:time];

    //当前
    NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:currentDate];

    //今天
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];

    //昨天
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
    NSDateComponents *yesterdayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:yesterday];

    if (currentComponents.year == todayComponents.year && currentComponents.month == todayComponents.month && currentComponents.day == todayComponents.day) { //今天

        //获取当前时时间戳差
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:currentDate];

        if (time < 60) { //1分钟内

            return @"刚刚";
        } else if (time < 60 * 60) { //1小时内

            return [NSString stringWithFormat:@"%.0f分钟前", time / 60];
        } else if (time < 60 * 60 * 24) { //1天内

            return [NSString stringWithFormat:@"%.0f小时前", time / 60 / 60];
        } else { //保护

            format.dateFormat = sh_fomat_4;
            return [format stringFromDate:currentDate];
        }
    } else if (currentComponents.year == yesterdayComponents.year && currentComponents.month == yesterdayComponents.month && currentComponents.day == yesterdayComponents.day) { //昨天

        format.dateFormat = sh_fomat_5;
        return [NSString stringWithFormat:@"昨天 %@", [format stringFromDate:currentDate]];
    } else if (currentComponents.year == todayComponents.year) { //今年

        format.dateFormat = sh_fomat_4;
        return [format stringFromDate:currentDate];
    } else {
        format.dateFormat = sh_fomat_3;
        return [format stringFromDate:currentDate];
    }
}

#pragma mark 比较两个日期大小
+ (NSInteger)compareStartDate:(NSString *)startDate
                      endDate:(NSString *)endDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:sh_fomat_1];
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] init];
    date1 = [formatter dateFromString:startDate];
    date2 = [formatter dateFromString:endDate];

    NSComparisonResult result = [date1 compare:date2];
    switch (result) {
        case NSOrderedAscending: //date1 < date2
            return -1;
            break;
        case NSOrderedSame: //date1 == date2
            return 0;
            break;
        case NSOrderedDescending: //date1 > date2
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

#pragma mark 获取两个时间间隔
+ (NSTimeInterval)getTimeIntervalWithTimeOne:(NSString *)timeOne
                                     timeTwo:(NSString *)timeTwo
                                      format:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];

    NSDate *dateOne = [dateFormatter dateFromString:timeOne];
    NSDate *dateTwo = [dateFormatter dateFromString:timeTwo];

    return [dateTwo timeIntervalSinceDate:dateOne];
}

#pragma mark 处理个数
+ (NSString *)dealCount:(NSString *)count {
    if (![count intValue]) {
        return @"";
    } else if ([count intValue] >= 1000) {
        return [NSString stringWithFormat:@"%.1fK", [count doubleValue] / 1000];
    } else if ([count intValue] >= 10000) {
        return [NSString stringWithFormat:@"%.1fW", [count doubleValue] / 10000];
    }
    return count;
}

#pragma mark 计算富文本的size
+ (CGSize)getSizeWithAtt:(NSAttributedString *)att
                 maxSize:(CGSize)maxSize {
    if (att.length == 0) {
        return CGSizeZero;
    }

    CGSize size = [att boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    if (att.length && !size.width && !size.height) {
        size = maxSize;
    }
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

#pragma mark 计算字符串的size
+ (CGSize)getSizeWithStr:(NSString *)str
                    font:(UIFont *)font
                 maxSize:(CGSize)maxSize {
    if (str.length == 0) {
        return CGSizeZero;
    }

    CGSize size = [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName: font } context:nil].size;
    if (str.length && !size.width && !size.height) {
        size = maxSize;
    }
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

#pragma mark 计算富媒体的高度
+ (void)getHtmlHeightWithHtml:(NSString *)html
                         maxW:(CGFloat)maxW
                    isInstant:(BOOL)isInstant
                        block:(toolBlock)block {
    SHTool *view = [[SHTool alloc] init];
    [view configWebWithMaxW:maxW
                  isInstant:isInstant
                      block:block];
    [view.webView loadHTMLString:html baseURL:nil];
}

#pragma mark 计算网页的高度
+ (void)getUrlHeightWithUrl:(NSURL *)url
                       maxW:(CGFloat)maxW
                  isInstant:(BOOL)isInstant
                      block:(toolBlock)block {
    SHTool *view = [[SHTool alloc] init];
    [view configWebWithMaxW:maxW
                  isInstant:isInstant
                      block:block];
    [view.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark 是否超过规定高度
+ (BOOL)isLineWithAtt:(NSAttributedString *)att
                lineH:(CGFloat)lineH
                 maxW:(CGFloat)maxW {
    CGFloat attH = [self getSizeWithAtt:att maxSize:CGSizeMake(maxW, CGFLOAT_MAX)].height;

    return (attH > ceil(lineH));
}

#pragma mark 获取行高
+ (CGFloat)getLineHeightWithLine:(CGFloat)line
                            font:(UIFont *)font {
    return line - (font.lineHeight - font.pointSize);
}

#pragma mark 获取行间距
+ (CGFloat)getLineSpacingWithAtt:(NSAttributedString *)att
                            line:(CGFloat)line
                            font:(UIFont *)font
                            maxW:(CGFloat)maxW {
    BOOL isLine = [self isLineWithAtt:att lineH:font.lineHeight maxW:maxW];
    CGFloat space = [self getLineHeightWithLine:line font:font];
    
    return isLine?space:0;
}

@end
