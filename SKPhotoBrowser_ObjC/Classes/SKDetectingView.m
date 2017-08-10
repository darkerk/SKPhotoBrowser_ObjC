//
//  SKDetectingView.m
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKDetectingView.h"

@implementation SKDetectingView

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    switch (tapCount) {
        case 1:
            [self handleSingleTap:touch];
            break;
        case 2:
            [self handleDoubleTap:touch];
            break;
        default:
            break;
    }
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)handleSingleTap:(UITouch *)touch {
    if ([self.delegate respondsToSelector:@selector(detectingView:singleTap:)])
        [self.delegate detectingView:self singleTap:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
    if ([self.delegate respondsToSelector:@selector(detectingView:doubleTap:)])
        [self.delegate detectingView:self doubleTap:touch];
}

@end
