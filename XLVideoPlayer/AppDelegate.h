//
//  AppDelegate.h
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/23.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin
//  博客：http://www.jianshu.com/users/edad244257e2/latest_articles

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "GPUImageView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (instancetype) sharedApp;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) GPUImageVideoCamera* videoCamera;
@property (strong, nonatomic) GPUImageOutput<GPUImageInput>* filter;

@end

