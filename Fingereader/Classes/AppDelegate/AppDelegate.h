//
//  AppDelegate.h
//  Fingereader
//
//  Created by Ali Mahouk on 31/5/13.
//  Copyright (c) 2013 Ali Mahouk. All rights reserved.
//

#import "SHStrobeLight.h"
#import "RootViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    RootViewController *rootView;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SHStrobeLight *strobeLight;
@property (nonatomic) BOOL isRetina;

+ (AppDelegate *)sharedDelegate;
- (cv::Mat)cvMatFromUIImage:(UIImage *)image;
- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
- (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;

@end
