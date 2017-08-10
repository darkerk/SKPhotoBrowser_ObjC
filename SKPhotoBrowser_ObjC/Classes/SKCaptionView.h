//
//  SKCaptionView.h
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SKPhotoProtocol;
@interface SKCaptionView : UIView

- (instancetype)initWithPhoto:(id<SKPhotoProtocol>)photo;

@end
