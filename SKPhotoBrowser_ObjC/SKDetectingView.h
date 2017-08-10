//
//  SKDetectingView.h
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SKDetectingViewDelegate <NSObject>

- (void)detectingView:(UIView *)view singleTap:(UITouch *)touch;
- (void)detectingView:(UIView *)view doubleTap:(UITouch *)touch;

@end

@interface SKDetectingView : UIView

@property(nonatomic,weak)id<SKDetectingViewDelegate> delegate;

@end
