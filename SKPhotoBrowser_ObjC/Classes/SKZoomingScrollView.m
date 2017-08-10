//
//  SKZoomingScrollView.m
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKZoomingScrollView.h"
#import "SKPhoto.h"
#import "SKCaptionView.h"
#import "SKDetectingImageView.h"
#import "SKIndicatorView.h"
#import "SKDetectingView.h"
#import "SKPhotoBrowser.h"
#import "SKPhotoBrowserOptions.h"

@interface SKZoomingScrollView ()<UIScrollViewDelegate, SKDetectingViewDelegate, SKDetectingImageViewDelegate>

@property(nonatomic,strong)SKDetectingView *tapView;
@property(nonatomic,strong)SKIndicatorView *indicatorView;
@property(nonatomic,weak)SKPhotoBrowser *photoBrowser;

@end

@implementation SKZoomingScrollView

- (instancetype)initWithFrame:(CGRect)frame browser: (SKPhotoBrowser *)browser
{
    self = [super initWithFrame:frame];
    if (self) {
        self.photoBrowser = browser;
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    self.tapView = [[SKDetectingView alloc] initWithFrame:self.bounds];
    _tapView.backgroundColor = [UIColor clearColor];
    _tapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tapView.delegate = self;
    [self addSubview:_tapView];
    
    self.photoImageView = [[SKDetectingImageView alloc] initWithFrame:self.frame];
    _photoImageView.backgroundColor = [UIColor clearColor];
    _photoImageView.contentMode = UIViewContentModeBottom;
    _photoImageView.delegate = self;
    [self addSubview:_photoImageView];
    
    self.indicatorView = [[SKIndicatorView alloc] initWithFrame:self.frame];
    [self addSubview:_indicatorView];
}

- (void)setPhoto:(id<SKPhotoProtocol>)photo {
    _photo = photo;
    
    self.photoImageView.image = nil;
    if (_photo && _photo.underlyingImage) {
        [self displayImage:YES];
    }
    if (_photo) {
        [self displayImage:NO];
    }
}

- (void)layoutSubviews {
    self.tapView.frame = self.bounds;
    self.indicatorView.frame = self.bounds;
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.photoImageView.frame;
    
    // horizon
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    // vertical
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    if (!CGRectEqualToRect(frameToCenter, self.photoImageView.frame)) {
        self.photoImageView.frame = frameToCenter;
    }
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    if (self.photoImageView) {
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = self.photoImageView.frame.size;
        
        CGFloat xScale = boundsSize.width / imageSize.width;
        CGFloat yScale = boundsSize.height / imageSize.height;
        CGFloat minScale = MIN(xScale, yScale);
        CGFloat maxScale = 1.0;
        
        CGFloat scale = MAX([UIScreen mainScreen].scale, 2.0);
        CGFloat deviceScreenWidth = CGRectGetWidth([UIScreen mainScreen].bounds) * scale;
        CGFloat deviceScreenHeight = CGRectGetHeight([UIScreen mainScreen].bounds) * scale;
        if (CGRectGetWidth(self.photoImageView.frame) < deviceScreenWidth) {
            if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
                maxScale = deviceScreenHeight / CGRectGetWidth(self.photoImageView.frame);
            }else {
                maxScale = deviceScreenWidth / CGRectGetWidth(self.photoImageView.frame);
            }
            
        }else if (CGRectGetWidth(self.photoImageView.frame) > deviceScreenWidth) {
            maxScale = 1.0;
        }else {
            maxScale = 2.5;
        }
        
        self.maximumZoomScale = maxScale;
        self.minimumZoomScale = minScale;
        self.zoomScale = minScale;
        
        self.photoImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.photoImageView.frame), CGRectGetHeight(self.photoImageView.frame));
        [self setNeedsLayout];
    }
}

- (void)prepareForReuse {
    self.photo = nil;
    if (self.captionView) {
        [self.captionView removeFromSuperview];
        self.captionView = nil;
    }
}

- (void)displayImage: (BOOL)complete {
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    self.contentSize = CGSizeZero;
    
    if (!complete) {
        if (self.photo.underlyingImage == nil) {
            [self.indicatorView stopAnimating];
        }
        [self.photo loadUnderlyingImageAndNotify];
    }else {
        [self.indicatorView stopAnimating];
    }
    
    UIImage *image = self.photo.underlyingImage;
    if (image) {
        self.photoImageView.image = image;
        self.photoImageView.contentMode = self.photo.contentMode;
        self.photoImageView.backgroundColor = [SKPhotoBrowserOptions sharedInstance].backgroundColor;
        
        CGRect photoImageViewFrame = CGRectZero;
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size = image.size;
        
        self.photoImageView.frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;
        
        [self setMaxMinZoomScalesForCurrentBounds];
    }
    
    [self setNeedsLayout];
}

- (void)displayImageFailure {
    [self.indicatorView stopAnimating];
}

- (void)handleDoubleTap: (CGPoint)point {
    if (self.photoBrowser) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self.photoBrowser];
    }
    
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }else {
        CGRect zoomRect = [self zoomRectForScrollViewWithScale:self.maximumZoomScale touchPoint:point];
        [self zoomToRect:zoomRect animated:YES];
    }
    if (self.photoBrowser) {
        [self.photoBrowser hideControlsAfterDelay];
    }
}

- (CGPoint)getViewFramePercent: (UIView *)view touch: (UITouch *)touch {
    CGFloat oneWidthViewPercent = CGRectGetWidth(self.bounds) / 100.0;
    CGPoint viewTouchPoint = [touch locationInView:view];
    CGFloat viewWidthTouch = viewTouchPoint.x;
    CGFloat viewPercentTouch = viewWidthTouch / oneWidthViewPercent;
    
    CGFloat photoWidth = CGRectGetWidth(self.photoImageView.bounds);
    CGFloat onePhotoPercent = photoWidth / 100.0;
    CGFloat needPoint = viewPercentTouch * onePhotoPercent;
    
    CGFloat Y = 0.0f;
    if (viewTouchPoint.y < CGRectGetHeight(view.bounds) / 2.0) {
        Y = 0.0f;
    }else {
        Y = CGRectGetHeight(self.photoImageView.bounds);
    }
    
    return CGPointMake(needPoint, Y);
}

- (CGRect)zoomRectForScrollViewWithScale: (CGFloat)scale touchPoint: (CGPoint)touchPoint {
    CGFloat w = CGRectGetWidth(self.frame) / scale;
    CGFloat h = CGRectGetHeight(self.frame) / scale;
    CGFloat x = touchPoint.x - (h / MAX([UIScreen mainScreen].scale, 2.0));
    CGFloat y = touchPoint.x - (w / MAX([UIScreen mainScreen].scale, 2.0));
    return CGRectMake(x, y, w, h);
}

#pragma mark - SKDetectingViewDelegate
- (void)detectingView:(UIView *)view singleTap:(UITouch *)touch {
    
    if (!self.photoBrowser) {
        return;
    }
    
    if (![SKPhotoBrowserOptions sharedInstance].enableZoomBlackArea) {
        return;
    }
    
    if (![self.photoBrowser areControlsHidden] && [SKPhotoBrowserOptions sharedInstance].enableSingleTapDismiss) {
        [self.photoBrowser determineAndClose];
    }else {
        [self.photoBrowser toggleControls];
    }
}

- (void)detectingView:(UIView *)view doubleTap:(UITouch *)touch {
    if ([SKPhotoBrowserOptions sharedInstance].enableZoomBlackArea) {
        CGPoint needPoint = [self getViewFramePercent:view touch:touch];
        [self handleDoubleTap:needPoint];
    }
}

#pragma mark - SKDetectingImageViewDelegate
- (void)detectingImageView: (SKDetectingImageView *)view singleTapPoint: (CGPoint)touchPoint {
    if (self.photoBrowser) {
        if ([SKPhotoBrowserOptions sharedInstance].enableSingleTapDismiss) {
            [self.photoBrowser determineAndClose];
        }else {
            [self.photoBrowser toggleControls];
        }
    }
}

- (void)detectingImageView: (SKDetectingImageView *)view doubleTapPoint: (CGPoint)touchPoint {
    [self handleDoubleTap:touchPoint];
}

#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    if (self.photoBrowser) {
        [self.photoBrowser cancelControlHiding];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
