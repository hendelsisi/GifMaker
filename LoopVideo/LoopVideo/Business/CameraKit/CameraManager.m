//
//  CameraManager.m
//  tryMakeMirror
//
//  Created by hend elsisi on 12/4/16.
//  Copyright © 2016 hend elsisi. All rights reserved.
//

#import "CameraManager.h"
#import <AVFoundation/AVFoundation.h>
#import "SettingBundle.h"
#import "GifManager.h"

static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size);
static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size)
{
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)pixel;
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    CVPixelBufferRelease( pixelBuffer );
}

static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut);
static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut)
{
    OSStatus err = noErr;
    OSType sourcePixelFormat;
    size_t width, height, sourceRowBytes;
    void *sourceBaseAddr = NULL;
    CGBitmapInfo bitmapInfo;
    CGColorSpaceRef colorspace = NULL;
    CGDataProviderRef provider = NULL;
    CGImageRef image = NULL;
    
    sourcePixelFormat = CVPixelBufferGetPixelFormatType( pixelBuffer );
    if ( kCVPixelFormatType_32ARGB == sourcePixelFormat )
        bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
    else if ( kCVPixelFormatType_32BGRA == sourcePixelFormat )
        bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    else
        return -95014; // only uncompressed pixel formats
    
    sourceRowBytes = CVPixelBufferGetBytesPerRow( pixelBuffer );
    width = CVPixelBufferGetWidth( pixelBuffer );
    height = CVPixelBufferGetHeight( pixelBuffer );
    
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    sourceBaseAddr = CVPixelBufferGetBaseAddress( pixelBuffer );
    
    colorspace = CGColorSpaceCreateDeviceRGB();
    
    CVPixelBufferRetain( pixelBuffer );
    provider = CGDataProviderCreateWithData( (void *)pixelBuffer, sourceBaseAddr, sourceRowBytes * height, ReleaseCVPixelBuffer);
    image = CGImageCreate(width, height, 8, 32, sourceRowBytes, colorspace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault);
    
bail:
    if ( err && image ) {
        CGImageRelease( image );
        image = NULL;
    }
    CVPixelBufferRelease(pixelBuffer);
    if ( provider ) CGDataProviderRelease( provider );
    if ( colorspace ) CGColorSpaceRelease( colorspace );
    *imageOut = image;
    
    return err;
}

@interface CameraManager ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    NSTimeInterval timeIndicator;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureVideoDataOutput *videoDataOutput;
    dispatch_queue_t videoDataOutputQueue;
    AVCaptureStillImageOutput *stillImageOutput;
    NSUInteger countOfPicTaked;
    BOOL isUsingFrontFacingCamera;
  //  CGFloat effectiveScale;
    BOOL isUsingTorchMood;
    id videoSender;
}

@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) SettingBundle *setBundle;
@property int count;
@property BOOL needInitialOrn;
@property AVCaptureSession *session;

@end

@implementation CameraManager


-(void)handleScreenRotation{
    NSLog(@"invoke");
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void) orientationChanged:(NSNotification *)note
{
    NSLog(@"notify");
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
            NSLog(@"same");
            if ( [[NSUserDefaults standardUserDefaults]
                  boolForKey:@"getR"] || _needInitialOrn == true)
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"else" forKey:@"Orn"];
                _needInitialOrn = false;
            }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            if ( [[NSUserDefaults standardUserDefaults]
                  boolForKey:@"getR"] || _needInitialOrn == true)
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"updown" forKey:@"Orn"];
                _needInitialOrn = false;
                
            }
            
            /* start special animation */
            break;
        case UIDeviceOrientationLandscapeLeft:
            // self.view.bounds = CGRectMake(0, 0, 450, 220);
            NSLog(@"oleft");
            if ( [[NSUserDefaults standardUserDefaults]
                  boolForKey:@"getR"] || _needInitialOrn == true)
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"left" forKey:@"Orn"];
                _needInitialOrn = false;
                
            }
            break;
        case UIDeviceOrientationFaceDown:
            break;
        case UIDeviceOrientationUnknown:
            break;
        case UIDeviceOrientationFaceUp:
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"oright");
            if ( [[NSUserDefaults standardUserDefaults]
                  boolForKey:@"getR"] || _needInitialOrn == true)
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"right" forKey:@"Orn"];
                _needInitialOrn = false;
                
            }
            //  self.view.bounds = CGRectMake(0, 0, 100, 100);
            break;
        default:
            break;
    };
}

-(void)record:(id)sender{
    _count =0;
    timeIndicator = [[NSDate date] timeIntervalSince1970];
    /////////////////////////
    //  _btnVideo.selected = ! _btnVideo.isSelected;
    [videoSender setSelected:![videoSender isSelected]];
    [sender setSelected:![sender isSelected]];
    ////////////////////////
    _needInitialOrn = false;
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"getR"];
    if (![sender isSelected]) {
        countOfPicTaked = 0;
        _needInitialOrn = true;
        [self btnDoneTap:nil];
    }
}

-(void)load:(UIView*)view{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
//    CGFloat width = view.bounds.size.width;
//    CGFloat height = view.bounds.size.height;
    //UIView* view = [[UIView alloc] in]
    ///////////////////////////////////////////
   // UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    UIView *pView = [[UIView alloc] initWithFrame: CGRectMake ( 0, 0, width, height)];
    //add code to customize, e.g. polygonView.backgroundColor = [UIColor blackColor];
    
    [view addSubview:pView];
    
   // [view bringSubviewToFront:pView];
    [self setupAVCapture:pView];
    countOfPicTaked = 0;
    if (!isUsingFrontFacingCamera) {
        [self switchCameras:nil];
    }
}

-(void)disAppear{
 [[previewLayer session] stopRunning];
     [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"getR"];
}

-(void)appear{
//     _needInitialOrn = true;
//    [self handleScreenRotation];
//     [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"getR"];
    [self updateScreenOrn];
    videoSender = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [videoSender setSelected:NO];
    [[previewLayer session] startRunning];
}

-(void)updateScreenOrn{
    _needInitialOrn = true;
    [self handleScreenRotation];
     [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"getR"];
}

-(void)getCurrentScreenOrn{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationPortrait)
        //Do something if the orientation is in Portrait
        NSLog(@"ma3dool");
    else if(orientation == UIInterfaceOrientationLandscapeLeft)
        NSLog(@"ma2loob");
    // Do something if Left
    else if(orientation == UIInterfaceOrientationLandscapeRight)
        NSLog(@"ya lahwy");
}

- (void)teardownAVCapture
{
    // [videoDataOutput release];
    if (videoDataOutputQueue)
        // dispatch_release(videoDataOutputQueue);
        [stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage"];
    // [stillImageOutput release];
    [previewLayer removeFromSuperlayer];
    //  [previewLayer release];
}


- (void)setupAVCapture:(UIView*)view
{
    NSError *error = nil;
    
    _session = [AVCaptureSession new];
    ///////////////////////////
    [_session setSessionPreset:AVCaptureSessionPreset352x288];
    
    ////////////////////////
    /*
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    [session setSessionPreset:AVCaptureSessionPresetMedium];
     else
	    [session setSessionPreset:AVCaptureSessionPresetPhoto];
     */
    
    // Select a video device, make an input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [_session beginConfiguration];
    [device lockForConfiguration:nil];
    /////////////////////////////
    [device setTorchMode:AVCaptureTorchModeOff];
    ////////////////////
    [device unlockForConfiguration];
    [_session commitConfiguration];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    //  require( error == nil, bail );
    
    isUsingFrontFacingCamera = NO;
    isUsingTorchMood = NO;
    if ( [_session canAddInput:deviceInput] )
        [_session addInput:deviceInput];
    [self setVideoDeviceInput:deviceInput];
    // Make a still image output
    stillImageOutput = [AVCaptureStillImageOutput new];
    [stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:@"AVCaptureStillImageIsCapturingStillImageContext"];
    if ( [_session canAddOutput:stillImageOutput] )
        [_session addOutput:stillImageOutput];
    
    // Make a video data output
    videoDataOutput = [AVCaptureVideoDataOutput new];
    
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
    NSDictionary *rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCMPixelFormat_32BGRA]};
    [videoDataOutput setVideoSettings:rgbOutputSettings];
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
    videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if ( [_session canAddOutput:videoDataOutput] )
        [_session addOutput:videoDataOutput];
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    
   // effectiveScale = 1.0;
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    [previewLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    ///////////////////////
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    ////////////////////////
    
    CALayer *rootLayer = [view layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:[rootLayer bounds]];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
bail:
    //  [session release];
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        // [alertView release];
        [self teardownAVCapture];
    }
}

- (BOOL)shouldTakePicAuto
{
    NSTimeInterval ttt = [[NSDate date] timeIntervalSince1970];
    if ((ttt - timeIndicator) > self.setBundle.timeInterval) {
        timeIndicator = ttt;
        return YES;
    }
    return NO;
}

+ (CameraManager *)sharedInstance{
    static dispatch_once_t once;
    static CameraManager *instance;
    dispatch_once(&once, ^{
        instance = [[CameraManager alloc] init];
    });
    return instance;
}

- (SettingBundle *)setBundle
{
    if (_setBundle == nil) {
        _setBundle = [SettingBundle globalSetting];
    }
    return _setBundle;
}

-(void)toggleFlash{
    AVCaptureTorchMode desiredPosition;
    if (_isUsingTorchMood)
        desiredPosition = AVCaptureTorchModeOff;
    else
        desiredPosition = AVCaptureTorchModeOn;
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        // if ([d torchMode] != desiredPosition)
        {
            [_session beginConfiguration];
            [d lockForConfiguration:nil];
            [d setTorchMode:desiredPosition];
            [d setActiveVideoMinFrameDuration:CMTimeMake(1, 10)];
            [d setActiveVideoMaxFrameDuration:CMTimeMake(1, 10)];
            [d unlockForConfiguration];
            [_session commitConfiguration];
            
            break;
        }
    }
    _isUsingTorchMood = !_isUsingTorchMood;
}

- (IBAction)switchCameras:(id)sender
{
    AVCaptureDevicePosition desiredPosition;
    if (isUsingFrontFacingCamera)
        desiredPosition = AVCaptureDevicePositionBack;
    else
        desiredPosition = AVCaptureDevicePositionFront;
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [[previewLayer session] beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in [[previewLayer session] inputs]) {
                [[previewLayer session] removeInput:oldInput];
            }
            [[previewLayer session] addInput:input];
            [self setVideoDeviceInput:input];
            [d lockForConfiguration:nil];
            [d setActiveVideoMinFrameDuration:CMTimeMake(1, 10)];
            [d setActiveVideoMaxFrameDuration:CMTimeMake(1, 10)];
            [d unlockForConfiguration];
            [[previewLayer session] commitConfiguration];
            break;
        }
    }
    isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
   // NSLog(@"connection");
    
    //////////////////////////////////
    if (
        [videoSender isSelected] && countOfPicTaked <= self.setBundle.countOfImage) {
       
        ///////////////////////////////////////
        if (countOfPicTaked == self.setBundle.countOfImage) {
           
            dispatch_async(dispatch_get_main_queue(), ^{
                ////////////////////////////
                [videoSender setSelected:NO];
                ////////////////////////////
                [self btnDoneTap:nil];
                countOfPicTaked = 0;
            });
        } else {
            if ([self shouldTakePicAuto]) {
                CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                CGImageRef srcImage = NULL;
                OSStatus status = CreateCGImageFromCVPixelBuffer(pixelBuffer, &srcImage);
                
                if([[[NSUserDefaults standardUserDefaults]
                     stringForKey:@"Orn"] isEqualToString:@"left"])
                {
                    UIImage *img = [UIImage imageWithCGImage:srcImage scale:1.0 orientation:UIImageOrientationDown];
                   [[GifManager shareInterface] saveTempImage:img];
                }
                
                else if ([[[NSUserDefaults standardUserDefaults]
                           stringForKey:@"Orn"] isEqualToString:@"right"])
                {
                    UIImage *img = [UIImage imageWithCGImage:srcImage scale:1.0 orientation:UIImageOrientationUp];
                    [[GifManager shareInterface] saveTempImage:img];
                    
                }
                else if ([[[NSUserDefaults standardUserDefaults]
                           stringForKey:@"Orn"] isEqualToString:@"updown"])
                {
                    UIImage *img = [UIImage imageWithCGImage:srcImage scale:1.0 orientation:UIImageOrientationLeft];
                    [[GifManager shareInterface] saveTempImage:img];
                }
                
                else
                {
                    UIImage *img = [UIImage imageWithCGImage:srcImage scale:1.0 orientation:UIImageOrientationRight];
                    [[GifManager shareInterface] saveTempImage:img];
                }
               
                countOfPicTaked ++;
                dispatch_async(dispatch_get_main_queue(), ^{
                     [[NSUserDefaults standardUserDefaults] setFloat:(float)countOfPicTaked forKey:@"countOfPicTaked"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateButton" object:_btnVideo];
                });
            }
        }
    }
}


- (IBAction)btnDoneTap:(id)sender
{
     [[NSUserDefaults standardUserDefaults] setFloat:(float)countOfPicTaked forKey:@"countOfPicTaked"];
    NSLog(@"done");
    if (_count == 0)
     [[NSNotificationCenter defaultCenter] postNotificationName:@"viewFrames" object:sender];
    _count = 1;
  
    //  [editor initImgNameArray:[[GifManager shareInterface] imageNameArrayInTemp]];
   // [self performSegueWithIdentifier:@"mySegue" sender:self];
}

@end
