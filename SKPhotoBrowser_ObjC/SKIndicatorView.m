//
//  SKIndicatorView.m
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKIndicatorView.h"

@implementation SKIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    return self;
}

@end
