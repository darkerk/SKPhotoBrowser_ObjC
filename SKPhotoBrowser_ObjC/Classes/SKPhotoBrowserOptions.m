//
//  SKPhotoBrowserOptions.m
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKPhotoBrowserOptions.h"

@implementation SKPhotoBrowserOptions

+ (instancetype)sharedInstance {
    static SKPhotoBrowserOptions *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SKPhotoBrowserOptions alloc] init];
    });
    
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.displayStatusbar = NO;
        self.displayAction = YES;
        
        self.displayToolbar = YES;
        self.displayCounterLabel = YES;
        self.displayBackAndForwardButton = YES;
        self.disableVerticalSwipe = NO;
        
        self.displayCloseButton = YES;
        self.displayDeleteButton = NO;
        
        self.enableZoomBlackArea = YES;
        self.enableSingleTapDismiss = NO;
        
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

@end

@implementation SKCaptionOptions

+ (instancetype)sharedInstance {
    static SKCaptionOptions *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SKCaptionOptions alloc] init];
    });
    
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.numberOfLine = 3;
        self.lineBreakMode = NSLineBreakByTruncatingTail;
        self.font = [UIFont systemFontOfSize:17];
    }
    return self;
}

@end

@implementation SKToolbarOptions

+ (instancetype)sharedInstance {
    static SKToolbarOptions *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SKToolbarOptions alloc] init];
    });
    
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:17];
    }
    return self;
}

@end
