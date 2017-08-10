//
//  SKPhotoBrowserOptions.h
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKPhotoBrowserOptions : NSObject

@property(nonatomic,assign)BOOL displayStatusbar;

@property(nonatomic,assign)BOOL displayAction;
@property(nullable,nonatomic,assign)NSString *shareExtraCaption;
@property(nullable,nonatomic,assign)NSArray<NSString *> *actionButtonTitles;

@property(nonatomic,assign)BOOL displayToolbar;
@property(nonatomic,assign)BOOL displayCounterLabel;
@property(nonatomic,assign)BOOL displayBackAndForwardButton;
@property(nonatomic,assign)BOOL disableVerticalSwipe;

@property(nonatomic,assign)BOOL displayCloseButton;
@property(nonatomic,assign)BOOL displayDeleteButton;

@property(nonatomic,assign)BOOL displayHorizontalScrollIndicator;
@property(nonatomic,assign)BOOL displayVerticalScrollIndicator;

@property(nonatomic,assign)BOOL bounceAnimation;
@property(nonatomic,assign)BOOL enableZoomBlackArea;
@property(nonatomic,assign)BOOL enableSingleTapDismiss;

@property(nonnull,nonatomic,strong)UIColor *backgroundColor;

+ (instancetype _Nonnull )sharedInstance;

@end

@interface SKCaptionOptions : NSObject

@property(nonnull,nonatomic,strong)UIColor *textColor;
@property(nonatomic,assign)NSTextAlignment textAlignment;
@property(nonatomic,assign)NSUInteger numberOfLine;
@property(nonatomic,assign)NSLineBreakMode lineBreakMode;
@property(nonnull,nonatomic,strong)UIFont *font;

+ (instancetype _Nonnull )sharedInstance;

@end

@interface SKToolbarOptions : NSObject

@property(nonnull,nonatomic,strong)UIColor *textColor;
@property(nonnull,nonatomic,strong)UIFont *font;

+ (instancetype _Nonnull )sharedInstance;

@end

