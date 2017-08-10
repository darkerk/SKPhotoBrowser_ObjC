//
//  SKButton.h
//  PhotoBrowser
//
//  Created by wgh on 2017/8/1.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKButton : UIButton

@property(nonatomic,assign)CGRect showFrame;
@property(nonatomic,assign)CGRect hideFrame;
@property(nonatomic,assign)UIEdgeInsets insets;

@property(nonatomic,assign)CGSize size;
@property(nonatomic,assign)CGFloat margin;
@property(nonatomic,assign)CGFloat buttonTopOffset;

- (void)setup: (NSString *)imageName;
- (void)setFrameSize: (CGSize)size;

@end

@interface SKCloseButton : SKButton

@end

@interface SKDeleteButton : SKButton

@end
