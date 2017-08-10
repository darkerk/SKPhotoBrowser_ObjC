//
//  SKButton.m
//  PhotoBrowser
//
//  Created by wgh on 2017/8/1.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKButton.h"
#import "SKPhotoBrowser.h"

@implementation SKButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.size = CGSizeMake(44, 44);
        self.margin = 5;
    }
    return self;
}

- (UIEdgeInsets)insets {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIEdgeInsetsMake(15.25, 15.25, 15.25, 15.25);
    }
    return UIEdgeInsetsMake(12, 12, 12, 12);
}

- (CGFloat)buttonTopOffset {
    return 5;
}

- (NSBundle *)bundle {
    return [NSBundle bundleForClass:[SKPhotoBrowser class]];
}

- (void)setup: (NSString *)imageName {
    self.backgroundColor = [UIColor clearColor];
    self.imageEdgeInsets = self.insets;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"SKPhotoBrowser.bundle/images/%@", imageName] inBundle:[self bundle] compatibleWithTraitCollection:nil];
    [self setImage:image forState:UIControlStateNormal];
}

- (void)setFrameSize: (CGSize)size {
    CGRect newRect = CGRectMake(self.margin, self.buttonTopOffset, size.width, size.height);
    self.frame = newRect;
    self.showFrame = newRect;
    self.hideFrame = CGRectMake(self.margin, -20, size.width, size.height);
}

@end

/////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SKCloseButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup:@"btn_common_close_wh"];
        self.showFrame = CGRectMake(self.margin, self.buttonTopOffset, self.size.width, self.size.height);
        self.hideFrame = CGRectMake(self.margin, -20, self.size.width, self.size.height);
    }
    return self;
}

@end

/////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SKDeleteButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup:@"btn_common_delete_wh"];
        self.showFrame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - self.size.width, self.buttonTopOffset, self.size.width, self.size.height);
        self.hideFrame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - self.size.width, -20, self.size.width, self.size.height);
    }
    return self;
}

- (void)setFrameSize:(CGSize)size {
    CGRect newRect = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - self.size.width, self.buttonTopOffset, size.width, size.height);
    self.frame = newRect;
    self.showFrame = newRect;
    self.hideFrame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - self.size.width, -20, size.width, size.height);
}

@end
