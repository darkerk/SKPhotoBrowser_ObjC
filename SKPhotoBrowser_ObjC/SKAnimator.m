//
//  SKAnimator.m
//  PhotoBrowser
//
//  Created by wgh on 2017/8/2.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKAnimator.h"
#import "SKPhotoBrowser.h"
#import "SKPhotoBrowserOptions.h"
#import "UIImage+Rotation.h"
#import "UIView+Radius.h"
#import "SKPhoto.h"
#import "SKZoomingScrollView.h"
#import "SKDetectingImageView.h"

@interface SKAnimator ()

@end

@implementation SKAnimator

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.senderViewOriginalFrame = CGRectZero;
        self.finalImageViewFrame = CGRectZero;
    }
    return self;
}

- (NSTimeInterval)animationDuration {
    if ([[SKPhotoBrowserOptions sharedInstance] bounceAnimation]) {
        return 0.5;
    }
    return 0.35;
}

- (CGFloat)animationDamping {
    if ([[SKPhotoBrowserOptions sharedInstance] bounceAnimation]) {
        return 0.8;
    }
    return 1;
}

- (CGRect)calcOriginFrame: (UIView *)view {
    if (view.superview) {
        return [view.superview convertRect:view.frame toView:nil];
    }else if (view.layer.superlayer) {
        return [view.layer.superlayer convertRect:view.frame toLayer:nil];
    }else {
        return CGRectZero;
    }
}

- (CGRect)calcFinalFrame: (CGFloat)imageRatio {
    CGFloat screenRatio = CGRectGetWidth([UIScreen mainScreen].bounds) / CGRectGetHeight([UIScreen mainScreen].bounds);
    if (screenRatio < imageRatio) {
        CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat height = width / imageRatio;
        CGFloat yOffset = (CGRectGetHeight([UIScreen mainScreen].bounds) - height) / 2.0;
        return CGRectMake(0, yOffset, width, height);
    }else {
        CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds);
        CGFloat width = height * imageRatio;
        CGFloat xOffset = (CGRectGetWidth([UIScreen mainScreen].bounds) - width) / 2.0;
        return CGRectMake(xOffset, 0, width, height);
    }
}

- (void)presentAnimation: (SKPhotoBrowser *)browser {
    browser.view.hidden = YES;
    browser.view.alpha = 0;
    
    [UIView animateWithDuration:self.animationDuration
                          delay:0
         usingSpringWithDamping:self.animationDamping
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [browser showButtons];
                         browser.backgroundView.alpha = 1;
                         if (self.resizableImageView) {
                             self.resizableImageView.frame = self.finalImageViewFrame;
                         }
                     } completion:^(BOOL finished) {
                         browser.view.hidden = NO;
                         browser.view.alpha = 1;
                         browser.backgroundView.hidden = YES;
                         if (self.resizableImageView) {
                             self.resizableImageView.alpha = 0;
                         }
                     }];
 
}

- (void)dismissAnimation: (SKPhotoBrowser *)browser{
    [UIView animateWithDuration:self.animationDuration
                          delay:0
         usingSpringWithDamping:self.animationDamping
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         browser.backgroundView.alpha = 0;
                         if (self.resizableImageView) {
                             self.resizableImageView.layer.frame = self.senderViewOriginalFrame;
                         }
                     } completion:^(BOOL finished) {
                         [browser dismissViewControllerAnimated:YES completion:^{
                             if (self.resizableImageView) {
                                 [self.resizableImageView removeFromSuperview];
                             }
                         }];
                     }];
}

////////////////////////////////////////////////////////////////////////
- (void)willPresentBrowser: (SKPhotoBrowser *)browser {
    UIWindow *appWindow = [[UIApplication sharedApplication] delegate].window;
    if (!appWindow) {
        return;
    }
    UIView *sender = nil;
    if ([browser.delegate respondsToSelector:@selector(photoBrowser:viewForPhotoAtIndex:)]) {
        sender = [browser.delegate photoBrowser:browser viewForPhotoAtIndex:browser.initialPageIndex];
    }
    if (!sender && self.senderViewForAnimation) {
        sender = self.senderViewForAnimation;
    }else {
        [self presentAnimation:browser];
        return;
    }
    
    id<SKPhotoProtocol> photo = [browser photoAtIndex:browser.currentPageIndex];
    UIImage *imageFromView = self.senderOriginImage ? self.senderOriginImage : [[browser getImageFromView:sender] rotateImageByOrientation];
    CGFloat imageRatio = imageFromView.size.width / imageFromView.size.height;
    
    self.senderViewOriginalFrame = [self calcOriginFrame:sender];
    self.finalImageViewFrame = [self calcFinalFrame:imageRatio];
    
    self.resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    self.resizableImageView.frame = self.senderViewOriginalFrame;
    self.resizableImageView.clipsToBounds = YES;
    self.resizableImageView.contentMode = photo.contentMode;
    if (sender.layer.cornerRadius != 0) {
        NSTimeInterval duration = self.animationDuration * self.animationDamping;
        self.resizableImageView.layer.masksToBounds = YES;
        [self.resizableImageView addCornerRadiusAnimation:sender.layer.cornerRadius to:0 duration:duration];
    }
    
    [appWindow addSubview:self.resizableImageView];
    
    [self presentAnimation:browser];
    
}

- (void)willDismissBrowser: (SKPhotoBrowser *)browser {
    UIView *sender = nil;
    if ([browser.delegate respondsToSelector:@selector(photoBrowser:viewForPhotoAtIndex:)]) {
        sender = [browser.delegate photoBrowser:browser viewForPhotoAtIndex:browser.initialPageIndex];
    }
    UIImage *image = [browser photoAtIndex:browser.currentPageIndex].underlyingImage;
    SKZoomingScrollView *scrollView = [browser pageDisplayedAtIndex:browser.currentPageIndex];
    
    if (sender && image && scrollView) {
        self.senderViewForAnimation = sender;
        browser.view.hidden = YES;
        browser.backgroundView.hidden = NO;
        browser.backgroundView.alpha = 1;
        
        self.senderViewOriginalFrame = [self calcOriginFrame:sender];
        
        id<SKPhotoProtocol> photo = [browser photoAtIndex:browser.currentPageIndex];
        CGPoint contentOffset = scrollView.contentOffset;
        CGRect scrollFrame = scrollView.photoImageView.frame;
        CGFloat offsetY = scrollView.center.y - (CGRectGetHeight(scrollView.bounds) / 2.0);
        CGRect rect = CGRectMake(scrollFrame.origin.x - contentOffset.x, scrollFrame.origin.y + contentOffset.y + offsetY, CGRectGetWidth(scrollFrame), CGRectGetHeight(scrollFrame));
        
        self.resizableImageView.image = [image rotateImageByOrientation];
        self.resizableImageView.frame = rect;
        self.resizableImageView.alpha = 1;
        self.resizableImageView.clipsToBounds = YES;
        self.resizableImageView.contentMode = photo.contentMode;
        if (self.senderViewForAnimation && self.senderViewForAnimation.layer.cornerRadius != 0) {
            NSTimeInterval duration = self.animationDuration * self.animationDamping;
            self.resizableImageView.layer.masksToBounds = YES;
            [self.resizableImageView addCornerRadiusAnimation:0 to:self.senderViewForAnimation.layer.cornerRadius duration:duration];
        }
        
        [self dismissAnimation:browser];
        
    }else {
        self.senderViewForAnimation.hidden = NO;
        [browser dismissPhotoBrowserAnimated:NO completion:nil];
    }
}

@end
