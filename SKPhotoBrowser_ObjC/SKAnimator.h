//
//  SKAnimator.h
//  PhotoBrowser
//
//  Created by wgh on 2017/8/2.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKPhotoBrowser;
@protocol SKPhotoBrowserAnimatorDelegate <NSObject>

- (void)willPresentBrowser: (SKPhotoBrowser *_Nonnull)browser;
- (void)willDismissBrowser: (SKPhotoBrowser *_Nonnull)browser;

@end

@interface SKAnimator : NSObject<SKPhotoBrowserAnimatorDelegate>

@property(nullable,nonatomic,strong)UIImageView *resizableImageView;

@property(nullable,nonatomic,strong)UIImage *senderOriginImage;
@property(nonatomic,assign)CGRect senderViewOriginalFrame;
@property(nullable,nonatomic,strong)UIView *senderViewForAnimation;

@property(nonatomic,assign)CGRect finalImageViewFrame;

@property(nonatomic,assign)BOOL bounceAnimation;
@property(nonatomic,readonly,assign)NSTimeInterval animationDuration;
@property(nonatomic,readonly,assign)CGFloat animationDamping;

@end
