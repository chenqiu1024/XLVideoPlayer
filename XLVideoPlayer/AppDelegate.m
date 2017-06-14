//
//  AppDelegate.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/23.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin
//  博客：http://www.jianshu.com/users/edad244257e2/latest_articles

#import "AppDelegate.h"
#import "ExampleViewController.h"

@interface AppDelegate ()
{
    
}

- (void) startRecordingVideoSegment;

@end

static AppDelegate* g_instance = nil;

@implementation AppDelegate

+ (instancetype) sharedApp {
    return g_instance;
}

+ (NSString*) ensureDirectory:(NSString*)directoryPathUnderDocument {
    NSString* docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString* directoryPath = [docPath stringByAppendingPathComponent:directoryPathUnderDocument];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* error = nil;
    BOOL isDirectory = NO;
    if (![fm fileExistsAtPath:directoryPath isDirectory:&isDirectory] || !isDirectory)
    {
        [fm createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return directoryPath;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    g_instance = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[ExampleViewController alloc] init]];
    self.window.rootViewController = nav;
    
    self.filter = [[GPUImageSepiaFilter alloc] init];
    [(GPUImageSepiaFilter*)self.filter setIntensity:0.f];
    
    //    filter = [[GPUImageTiltShiftFilter alloc] init];
    //    [(GPUImageTiltShiftFilter *)filter setTopFocusLevel:0.65];
    //    [(GPUImageTiltShiftFilter *)filter setBottomFocusLevel:0.85];
    //    [(GPUImageTiltShiftFilter *)filter setBlurSize:1.5];
    //    [(GPUImageTiltShiftFilter *)filter setFocusFallOffRate:0.2];
    
    //    filter = [[GPUImageSketchFilter alloc] init];
    //    filter = [[GPUImageColorInvertFilter alloc] init];
    //    filter = [[GPUImageSmoothToonFilter alloc] init];
    //    GPUImageRotationFilter *rotationFilter = [[GPUImageRotationFilter alloc] initWithRotation:kGPUImageRotateRightFlipVertical];
    
    //    GPUImageView *filterView = (GPUImageView *)self.gpuImageView;
    //    GPUImageView* filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    //    filterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //    [self.view addSubview:filterView];
    //    filterView.fillMode = kGPUImageFillModeStretch;
    //    filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    //    [filter addTarget:filterView];
    
    // Record a movie for 10 s and store it in /Documents, visible via iTunes file sharing
    [self startRecordingVideoSegment];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) startRecordingVideoSegment {
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    //    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    //    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    //    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    self.videoCamera.horizontallyMirrorRearFacingCamera = NO;
    [self.videoCamera addTarget:self.filter];
    
    NSString* recordPath = [self.class ensureDirectory:@"rec"];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd_hhmmss";
    NSString* fileName = [NSString stringWithFormat:@"MOV_%@.mp4", [formatter stringFromDate:[NSDate date]]];
    NSString* pathToMovie = [recordPath stringByAppendingPathComponent:fileName];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    GPUImageMovieWriter* movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    movieWriter.encodingLiveVideo = YES;
    //    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    //    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
    //    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1080.0, 1920.0)];
    [self.filter addTarget:movieWriter];
    
    double delayToStartRecording = 0.5;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
    dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Start recording");
        
        self.videoCamera.audioEncodingTarget = movieWriter;
        [self.videoCamera startCameraCapture];
        [movieWriter startRecording];
        
        //        NSError *error = nil;
        //        if (![self.videoCamera.inputCamera lockForConfiguration:&error])
        //        {
        //            NSLog(@"Error locking for configuration: %@", error);
        //        }
        //        [self.videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
        //        [self.videoCamera.inputCamera unlockForConfiguration];
        
        double delayInSeconds = 15.0;
        dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
            
            [self.filter removeTarget:movieWriter];
            self.videoCamera.audioEncodingTarget = nil;
            [self.videoCamera stopCameraCapture];
            [movieWriter finishRecording];
            NSLog(@"Movie completed");
            [self.filter removeAllTargets];
            /*
             ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
             if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:movieURL])
             {
             [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error)
             {
             dispatch_async(dispatch_get_main_queue(), ^{
             
             if (error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
             delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             } else {
             //                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
             //                                                                            delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             //                             [alert show];
             }
             remove(pathToMovie.UTF8String);
             });
             [self startRecordingVideoSegment];
             }];
             }
             /*/
            [self startRecordingVideoSegment];
            //*/
            
            //            [self.videoCamera.inputCamera lockForConfiguration:nil];
            //            [self.videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
            //            [self.videoCamera.inputCamera unlockForConfiguration];
        });
    });
}

@end
