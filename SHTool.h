//
//  SHTool.h
//  SHExtensionExample
//
//  Created by CSH on 2019/5/24.
//  Copyright © 2019 CSH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *sh_fomat_1 = @"yyyy-MM-dd HH:mm:ss";
static NSString *sh_fomat_2 = @"yyyy.MM.dd";
static NSString *sh_fomat_3 = @"yyyy.MM.dd HH:mm";
static NSString *sh_fomat_4 = @"MM.dd HH:mm";
static NSString *sh_fomat_5 = @"HH:mm";
static NSString *sh_fomat_6 = @"yyyy";
static NSString *sh_fomat_7 = @"mm:ss";
static NSString *sh_fomat_8 = @"yyyy年MM月dd日 HH:mm";
static NSString *sh_fomat_9 = @"yyyy.MM.dd HH:mm:ss";

typedef void (^toolBlock)(id obj);

/**
 工具类
 */
@interface SHTool : UIView

#pragma mark 获取毫秒值
+ (NSString *)getTimeMs;

#pragma mark 获取时间（毫秒）
+ (NSString *)getTimeMsWithMs:(NSString *)ms
                       format:(NSString *)format;

#pragma mark 获取时间
+ (NSString *)getTimeWithTime:(NSString *)time
                       format:(NSString *)format
                 targetFormat:(NSString *)targetFormat;

#pragma mark 获取两个时间间隔
+ (NSTimeInterval)getTimeIntervalWithTimeOne:(NSString *)timeOne
                                     timeTwo:(NSString *)timeTwo
                                      format:(NSString *)format;

#pragma mark 处理个数
+ (NSString *)dealCount:(NSString *)count;

#pragma mark 计算富文本的size
+ (CGSize)getSizeWithAtt:(NSAttributedString *)att
                 maxSize:(CGSize)maxSize;

#pragma mark 计算字符串的size
+ (CGSize)getSizeWithStr:(NSString *)str
                    font:(UIFont *)font
                 maxSize:(CGSize)maxSize;

#pragma mark 计算富媒体的高度
+ (void)getHtmlHeightWithHtml:(NSString *)html
                         maxW:(CGFloat)maxW
                    isInstant:(BOOL)isInstant
                        block:(toolBlock)block;

#pragma mark 计算网页的高度
+ (void)getUrlHeightWithUrl:(NSURL *)url
                       maxW:(CGFloat)maxW
                  isInstant:(BOOL)isInstant
                      block:(toolBlock)block;

#pragma mark 是否超过是否超过规定高度
+ (BOOL)isLineWithAtt:(NSAttributedString *)att
                lineH:(CGFloat)lineH
                 maxW:(CGFloat)maxW;

#pragma mark 获取行高
+ (CGFloat)getLineHeightWithLine:(CGFloat)line
                            font:(UIFont *)font;

#pragma mark 获取行间距
+ (CGFloat)getLineSpacingWithAtt:(NSAttributedString *)att
                            line:(CGFloat)line
                            font:(UIFont *)font
                            maxW:(CGFloat)maxW;

@end

NS_ASSUME_NONNULL_END
