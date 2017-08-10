//
//  SKDetectingImageView.h
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKDetectingImageView;
@protocol SKDetectingImageViewDelegate <NSObject>

- (void)detectingImageView: (SKDetectingImageView *)view singleTapPoint: (CGPoint)touchPoint;
- (void)detectingImageView: (SKDetectingImageView *)view doubleTapPoint: (CGPoint)touchPoint;

@end

@interface SKDetectingImageView : UIImageView

@property(nonatomic,weak)id<SKDetectingImageViewDelegate> delegate;

@end
