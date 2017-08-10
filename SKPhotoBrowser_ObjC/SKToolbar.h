//
//  SKToolbar.h
//  PhotoBrowser
//
//  Created by wgh on 2017/8/1.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKPhotoBrowser;
@interface SKToolbar : UIToolbar

@property(nonatomic,strong)UIBarButtonItem *toolActionButton;

- (instancetype)initWithFrame:(CGRect)frame browser:(SKPhotoBrowser *)browser;
- (void)updateToolbar: (NSUInteger)currentPageIndex;

@end

///////////////////////////////////////////////////////
@interface SKToolbarButton : UIButton

- (void)setup: (NSString *)imageName;

@end

@interface SKPreviousButton : SKToolbarButton

@end

@interface SKNextButton : SKToolbarButton

@end
