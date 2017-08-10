//
//  SKDetectingImageView.m
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKDetectingImageView.h"

@implementation SKDetectingImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.userInteractionEnabled = true;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
}

- (void)handleDoubleTap: (UITapGestureRecognizer *)recognizer {
    
    if ([self.delegate respondsToSelector:@selector(detectingImageView:doubleTapPoint:)])
        [self.delegate detectingImageView:self doubleTapPoint:[recognizer locationInView:self]];
}

- (void)handleSingleTap: (UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(detectingImageView:singleTapPoint:)])
        [self.delegate detectingImageView:self singleTapPoint:[recognizer locationInView:self]];
}

@end
