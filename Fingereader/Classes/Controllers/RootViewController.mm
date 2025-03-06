//
//  RootViewController.m
//  Fingereader
//
//  Created by Ali Mahouk on 5/31/13.
//
//

#import <AVFoundation/AVFoundation.h>
#import "RootViewController.h"
#import "AppDelegate.h"
#import "AVCamRecorder.h"
#import "Tesseract.h"
#import "Sound.h"

@implementation RootViewController

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        definitions = [NSArray array];
        
        isShowingDefinitions = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.view.backgroundColor = [UIColor blackColor];
    
    debugView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, screenBounds.size.height - 64)];
    
    videoOutputContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 340)];
    
    photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    
    UIView *photoPickerView = photoPicker.view;
    photoPickerView.frame = CGRectMake(0, 0, 320, 320);
    
    UIView *videoPreviewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    videoPreviewContainer.clipsToBounds = YES;
    videoPreviewContainer.opaque = YES;
    
    _videoPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    
    debugPreview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    debugPreview.contentMode = UIViewContentModeScaleAspectFit;
    debugPreview.backgroundColor = [UIColor blackColor];
    debugPreview.opaque = YES;
    
    debugPreview_word = [[UIImageView alloc] init];
    debugPreview_word.opaque = YES;
    
    redDot = [[UIImageView alloc] initWithFrame:CGRectMake(156, 156, 8, 8)];
    redDot.image = [UIImage imageNamed:@"red_dot"];
    redDot.opaque = YES;
    
    crosshairs = [[UIImageView alloc] initWithFrame:CGRectMake(144, 144, 32, 32)];
    crosshairs.image = [UIImage imageNamed:@"crosshairs"];
    crosshairs.opaque = YES;
    
    midLine = [[UIImageView alloc] initWithFrame:CGRectMake(152.5, 180, 15, 116)];
    midLine.image = [UIImage imageNamed:@"center_line"];
    midLine.opaque = YES;
    
    circle_outer = [[UIImageView alloc] initWithFrame:CGRectMake(19, 19, 280, 280)];
    circle_outer.image = [UIImage imageNamed:@"circle_outer"];
    circle_outer.opaque = YES;
    
    circle_inner = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 220, 220)];
    circle_inner.image = [UIImage imageNamed:@"circle_inner"];
    circle_inner.opaque = YES;
    
    definitionTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, screenBounds.size.width, screenBounds.size.height - 142)];
    definitionTable.backgroundColor = [UIColor clearColor];
    definitionTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    definitionTable.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    definitionTable.contentInset = UIEdgeInsetsMake(20, 0, 20, 0);
    definitionTable.delegate = self;
    definitionTable.dataSource = self;
    definitionTable.opaque = YES;
    definitionTable.alpha = 0.0;
    
    UIButton *debugCameraButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    debugCameraButton.frame = CGRectMake(20, screenBounds.size.height - 133, 130, 44);
    [debugCameraButton setTitle:@"Camera" forState:UIControlStateNormal];
    [debugCameraButton addTarget:self action:@selector(showCamera) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *debugLibraryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    debugLibraryButton.frame = CGRectMake(170, screenBounds.size.height - 133, 130, 44);
    [debugLibraryButton setTitle:@"Library" forState:UIControlStateNormal];
    [debugLibraryButton addTarget:self action:@selector(showImagePicker) forControlEvents:UIControlEventTouchUpInside];
    
    // This isn't really a button. UIButton's properties are suitable & faster for what we need.
    statusBox = [UIButton buttonWithType:UIButtonTypeCustom];
    statusBox.backgroundColor = [UIColor clearColor];
    [statusBox setBackgroundImage:[[UIImage imageNamed:@"square"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateDisabled];
    statusBox.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:MIN_MAIN_FONT_SIZE];
    statusBox.titleLabel.numberOfLines = 1;
    statusBox.titleLabel.clipsToBounds = NO;
    statusBox.titleLabel.layer.masksToBounds = NO;
    statusBox.titleLabel.layer.shadowRadius = 4.0f;
    statusBox.titleLabel.layer.shadowOpacity = 0.9;
    statusBox.titleLabel.layer.shadowOffset = CGSizeZero;
    statusBox.opaque = YES;
    statusBox.frame = CGRectMake(60, 330, 200, 50);
    statusBox.enabled = NO;
    statusBox.hidden = YES;
    
    defineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    defineButton.backgroundColor = [UIColor clearColor];
    [defineButton setBackgroundImage:[UIImage imageNamed:@"action_main"] forState:UIControlStateNormal];
    [defineButton addTarget:self action:@selector(captureImage) forControlEvents:UIControlEventTouchUpInside];
    defineButton.showsTouchWhenHighlighted = YES;
    defineButton.opaque = YES;
    defineButton.frame = CGRectMake(119, screenBounds.size.height - 95, 82, 82);
    
    CALayer *bottomShadow = [CALayer layer];
    bottomShadow.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shadow_bottom"]].CGColor;
    bottomShadow.frame = CGRectMake(0, 312, 320, 8);
    bottomShadow.opaque = YES;
    [bottomShadow setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
    
    flashLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    flashLayer.backgroundColor = [UIColor whiteColor];
    flashLayer.opaque = YES;
    flashLayer.alpha = 0.0;
    flashLayer.hidden = YES;
    
    segmentLine = [[UIView alloc] initWithFrame:CGRectMake(-10, 304, 340, 25)];
    segmentLine.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"segment_pattern"]];
    segmentLine.opaque = YES;
    
    wordBox = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 40)];
    wordBox.opaque = YES;
    wordBox.alpha = 0.0;
    
    UIColor *outerColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    UIColor *innerColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    
    // Adding transparency to the top & bottom of the definition list.
    maskLayer_DefinitionTable = [CAGradientLayer layer];
    maskLayer_DefinitionTable.colors = [NSArray arrayWithObjects:(__bridge id)innerColor.CGColor, (__bridge id)innerColor.CGColor, (__bridge id)outerColor.CGColor, (__bridge id)outerColor.CGColor, (__bridge id)innerColor.CGColor, nil];
    maskLayer_DefinitionTable.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                                           [NSNumber numberWithFloat:0.06],
                                           [NSNumber numberWithFloat:0.2],
                                           [NSNumber numberWithFloat:0.8],
                                           [NSNumber numberWithFloat:1.0], nil];
    
    maskLayer_DefinitionTable.bounds = CGRectMake(0, 0, definitionTable.frame.size.width, definitionTable.frame.size.height);
    maskLayer_DefinitionTable.position = CGPointMake(0, definitionTable.contentOffset.y);
    maskLayer_DefinitionTable.anchorPoint = CGPointZero;
    definitionTable.layer.mask = maskLayer_DefinitionTable;
    
    [debugView addSubview:debugCameraButton];
    [debugView addSubview:debugLibraryButton];
    [debugView addSubview:debugPreview];
    [debugView addSubview:debugPreview_word];
    [debugView addSubview:redDot];
    [videoPreviewContainer addSubview:_videoPreviewView];
    [videoOutputContainer addSubview:videoPreviewContainer];
    [videoOutputContainer addSubview:flashLayer];
    [videoOutputContainer.layer addSublayer:bottomShadow];
    [videoOutputContainer addSubview:segmentLine];
    [videoOutputContainer addSubview:statusBox];
    [videoOutputContainer addSubview:crosshairs];
    [videoOutputContainer addSubview:midLine];
    [videoOutputContainer addSubview:circle_outer];
    [videoOutputContainer addSubview:circle_inner];
    [self.view addSubview:debugView];
    [self.view addSubview:videoOutputContainer];
    [self.view addSubview:definitionTable];
    [self.view addSubview:wordBox];
    [self.view addSubview:defineButton];
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )
    {
        [self showCamera];
    }
    else
    {
        [self showImagePicker];
    }
    
    [self slowDownOuterCircle];
    [self slowDownInnerCircle];
    
    outerCircleTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(slowDownOuterCircle) userInfo:nil repeats:YES];
    innerCircleTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(slowDownInnerCircle) userInfo:nil repeats:YES];
    
    [self hideDebugView];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
}

- (void)showCamera
{
    AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
    [self setCaptureManager:manager];
    
    [[self captureManager] setDelegate:self];
    
    if ( [[self captureManager] setupSession] )
    {
        // Create video preview layer and add it to the UI
        AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
        UIView *view = [self videoPreviewView];
        CALayer *viewLayer = [view layer];
        [viewLayer setMasksToBounds:YES];
        
        CGRect bounds = [view bounds];
        [newCaptureVideoPreviewLayer setFrame:bounds];
        
        if ( [newCaptureVideoPreviewLayer isOrientationSupported] )
        {
            [newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
        }
        
        [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        
        [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
        
        // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[[self captureManager] session] startRunning];
        });
    }
}

- (void)showImagePicker
{
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoPicker.allowsEditing = YES;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)captureImage
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( isShowingDefinitions )
    {
        isShowingDefinitions = NO;
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            videoOutputContainer.frame = CGRectMake(0, 0, videoOutputContainer.frame.size.width, videoOutputContainer.frame.size.height);
            wordBox.alpha = 0.0;
            definitionTable.alpha = 0.0;
        } completion:^(BOOL finished){
            
        }];
    }
    else
    {
        [appDelegate.strobeLight activateStrobeLight];
        
        defineButton.enabled = NO;
        statusBox.hidden = NO;
        statusBox.titleLabel.layer.shadowColor = [UIColor colorWithRed:153/255.0 green:207/255.0 blue:216/255.0 alpha:1.0].CGColor;
        [statusBox setTitleColor:[UIColor colorWithRed:183/255.0 green:245/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateDisabled];
        [statusBox setTitle:@"Reading..." forState:UIControlStateDisabled];
        [statusBox setBackgroundImage:[[UIImage imageNamed:@"square"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateDisabled];
        
        flashLayer.hidden = NO;
        flashLayer.alpha = 1.0;
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            flashLayer.alpha = 0.0;
            circle_inner.frame = CGRectMake(circle_inner.center.x, circle_inner.center.x, 0, 0);
        } completion:^(BOOL finished){
            _videoPreviewView.transform = CGAffineTransformMakeScale(2.0, 2.0);
            flashLayer.alpha = 1.0;
            
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                flashLayer.alpha = 0.0;
                circle_inner.frame = CGRectMake(50, 50, 220, 220);
            } completion:^(BOOL finished){
                _videoPreviewView.transform = CGAffineTransformIdentity;
                flashLayer.hidden = YES;
                
                [[self captureManager] captureStillImage];
            }];
        }];
        
        [outerCircleTimer invalidate];
        [innerCircleTimer invalidate];
        outerCircleTimer = nil;
        innerCircleTimer = nil;
        
        [self speedUpOuterCircle];
        [self speedUpInnerCircle];
        
        outerCircleTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(speedUpOuterCircle) userInfo:nil repeats:YES];
        innerCircleTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(speedUpInnerCircle) userInfo:nil repeats:YES];
    }
}

- (void)speedUpOuterCircle
{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        circle_outer.layer.transform = CATransform3DMakeRotation(M_PI * 2.0, 0.0f, 0.0f, 1.0f);
    } completion:^(BOOL finished){
        circle_outer.layer.transform = CATransform3DMakeRotation(3.15904595, 0.0f, 0.0f, 1.0f); // 181 degrees
        
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            circle_outer.layer.transform = CATransform3DMakeRotation(0, 0.0f, 0.0f, 1.0f);
        } completion:^(BOOL finished){
            
        }];
    }];
}

- (void)speedUpInnerCircle
{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        circle_inner.layer.transform = CATransform3DMakeRotation(-M_PI, 0.0f, 0.0f, 1.0f);
    } completion:^(BOOL finished){
        circle_inner.layer.transform = CATransform3DMakeRotation(-3.15904595, 0.0f, 0.0f, 1.0f); // -181 degrees
        
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            circle_inner.layer.transform = CATransform3DMakeRotation(0, 0.0f, 0.0f, 1.0f);
        } completion:^(BOOL finished){
            
        }];
    }];
}

- (void)slowDownOuterCircle
{
    [UIView animateWithDuration:15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        circle_outer.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            circle_outer.layer.transform = CATransform3DMakeRotation(0, 0.0f, 0.0f, 1.0f);
        } completion:^(BOOL finished){
            
        }];
    }];
}

- (void)slowDownInnerCircle
{
    [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        circle_inner.layer.transform = CATransform3DMakeRotation(-M_PI, 0.0f, 0.0f, 1.0f);
    } completion:^(BOOL finished){
        circle_inner.layer.transform = CATransform3DMakeRotation(-3.15904595, 0.0f, 0.0f, 1.0f); // -181 degrees
        
        [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            circle_inner.layer.transform = CATransform3DMakeRotation(0, 0.0f, 0.0f, 1.0f);
        } completion:^(BOOL finished){
            
        }];
    }];
}

#pragma mark -
#pragma mark AVCamCaptureManagerDelegate methods

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        statusBox.titleLabel.layer.shadowColor = [UIColor colorWithRed:216/255.0 green:151/255.0 blue:151/255.0 alpha:1.0].CGColor;
        [statusBox setTitleColor:[UIColor colorWithRed:255/255.0 green:193/255.0 blue:183/255.0 alpha:1.0] forState:UIControlStateDisabled];
        [statusBox setTitle:@"Try again!" forState:UIControlStateDisabled];
        [statusBox setBackgroundImage:[[UIImage imageNamed:@"square_red"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateDisabled];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
        
        [outerCircleTimer invalidate];
        [innerCircleTimer invalidate];
        outerCircleTimer = nil;
        innerCircleTimer = nil;
        
        [self slowDownOuterCircle];
        [self slowDownInnerCircle];
        
        outerCircleTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(slowDownOuterCircle) userInfo:nil repeats:YES];
        innerCircleTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(slowDownInnerCircle) userInfo:nil repeats:YES];
    });
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        defineButton.enabled = YES;
        
        [outerCircleTimer invalidate];
        [innerCircleTimer invalidate];
        outerCircleTimer = nil;
        innerCircleTimer = nil;
        
        [self slowDownOuterCircle];
        [self slowDownInnerCircle];
        
        outerCircleTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(slowDownOuterCircle) userInfo:nil repeats:YES];
        innerCircleTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(slowDownInnerCircle) userInfo:nil repeats:YES];
        
        // We need to do our own custom cropping.
        UIImage *original = captureManager.returnedImage;
        CGRect cropRect;
        
        float originalWidth  = original.size.width;
        float originalHeight = original.size.height;
        
        float edge = fminf(originalWidth, originalHeight);
        
        float posX = (originalWidth - edge) / 2.0f;
        float posY = (originalHeight - edge) / 2.0f;
        
        
        if ( original.imageOrientation == UIImageOrientationLeft || original.imageOrientation == UIImageOrientationRight )
        {
            cropRect = CGRectMake(posY, posX, edge, edge);
        }
        else
        {
            cropRect = CGRectMake(posX, posY, edge, edge);
        }
        
        // This performs the image cropping.
        CGImageRef imageRef = CGImageCreateWithImageInRect([original CGImage], cropRect);
        
        selectedImage = [UIImage imageWithCGImage:imageRef
                                            scale:original.scale
                                      orientation:original.imageOrientation];
        
        CGImageRelease(imageRef);
        
        selectedImage = [appDelegate imageWithImage:selectedImage scaledToSizeWithSameAspectRatio:CGSizeMake(640, 640)];
        
        if ( appDelegate.isRetina )
        {
            [self extractorForRetina];
        }
        else
        {
            [self extractorForNonRetina];
        }
    });
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if ( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )
    {
        selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    
    if ( appDelegate.isRetina )
    {
        [self extractorForRetina];
    }
    else
    {
        [self extractorForNonRetina];
    }
}

- (void)extractorForRetina
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    cv::Mat inputImage = [appDelegate cvMatFromUIImage:selectedImage];
    cv::Mat kernel = getStructuringElement( cv::MORPH_ELLIPSE, cv::Size(5, 5) );
    cv::Mat temp;
    cv::Mat inputImage_gray;
    cv::Mat outputImage;
    
    // Convert image to gray and blur it.
    cvtColor( inputImage, inputImage_gray, CV_BGR2GRAY );
    
    resize(inputImage_gray, temp, cv::Size(inputImage_gray.rows / 4, inputImage_gray.cols / 4));
    morphologyEx(temp, temp, cv::MORPH_CLOSE, kernel);
    resize(temp, temp, cv::Size(inputImage_gray.rows, inputImage_gray.cols));
    
    divide(inputImage_gray, temp, temp, 1, CV_32F); // temp will now have type CV_32F.
    normalize(temp, inputImage_gray, 0, 255, cv::NORM_MINMAX, CV_8U);
    
    cvtColor( inputImage, outputImage, CV_BGR2GRAY );
    
    resize(outputImage, temp, cv::Size(inputImage.rows / 4, inputImage.cols / 4));
    morphologyEx(temp, temp, cv::MORPH_CLOSE, kernel);
    resize(temp, temp, cv::Size(inputImage.rows, inputImage.cols));
    
    divide(outputImage, temp, temp, 1, CV_32F); // temp will now have type CV_32F.
    normalize(temp, outputImage, 0, 255, cv::NORM_MINMAX, CV_8U);
    
    blur( outputImage, outputImage, cv::Size(7, 7) );
    
    cv::Mat threshold_output;
    std::vector<std::vector<cv::Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    
    cv::RNG rng(12345);
    double thresh = -1;
    double color = 255;
    //bitwise_not(outputImage, outputImage);
    // Detect edges using thresholding.
    threshold( outputImage, threshold_output, thresh, color, CV_THRESH_BINARY_INV + CV_THRESH_OTSU );
    
    // Find contours.
    findContours( threshold_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    // Approximate contours to polygons + get bounding rects.
    std::vector<std::vector<cv::Point> > contours_poly( contours.size() );
    std::vector<cv::Rect> boundRect( contours.size() );
    std::vector<cv::Point2f>center( contours.size() );
    
    std::vector<std::vector<cv::Point> > interestingContours;
    int closestContourIndex = 0;
    double closestContourMinDistance = 640.0;
    int closestContourCorner_left_x = 640;
    int closestContourCorner_right_x = 0;
    int closestContourCorner_left_y = 0;
    int closestContourCorner_right_y = 0;
    int finalBoxCornerLeft_x = 640;
    int finalBoxCornerLeft_y = 640;
    int finalBoxCornerRight_x = 0;
    int finalBoxCornerRight_y = 0;
    int imageMidpoint = 320; // Image is a square 320x320. DON'T use screenBounds because we need half of the actual retina value!
    
    // Remove small contours & detect the finger.
    for ( int i = 0; i < contours.size(); i++ )
    {
        if ( contourArea(contours[i], false) < 50 )
        {
            contours.erase(contours.begin() + i);
        }
    }
    
    redDot.frame = CGRectMake((imageMidpoint / 2) - 4, (imageMidpoint / 2) - 4, redDot.frame.size.width, redDot.frame.size.height);
    
    // Start searching for the closest contour group above the finger.
    for ( int i = 0; i < contours.size(); i++ )
    {
        double distance = pointPolygonTest(contours[i], cv::Point(imageMidpoint, imageMidpoint), true);
        
        if ( distance < 0 ) // Make the distance positive for our purposes.
        {
            distance *= (-1);
        }
        
        if ( distance < closestContourMinDistance ) // Find the closest contour.
        {
            closestContourIndex = i;
            closestContourMinDistance = distance;
            interestingContours.clear(); // Flush.
            interestingContours.push_back(contours[i]); // Store this contour as the 1st element here.
        }
    }
    
    // We need to measure the width of the contour.
    std::vector<cv::Point> closestContour = contours[closestContourIndex];
    
    for ( int i = 0; i < closestContour.size(); i++ )
    {
        CvPoint pt = closestContour[i];
        //std::cout << "x:" << pt.x << " y:" << pt.y << std::endl;
        
        if ( pt.x < closestContourCorner_left_x )
        {
            closestContourCorner_left_x = pt.x;
            closestContourCorner_left_y = pt.y;
        }
        else if ( pt.x > closestContourCorner_right_x )
        {
            closestContourCorner_right_x = pt.x;
            closestContourCorner_right_y = pt.y;
        }
    }
    
    // Now find the neighboring contours.
    for ( int i = 0; i < contours.size(); i++ )
    {
        if ( i != closestContourIndex )
        {
            double distanceFromLeft = pointPolygonTest(contours[i], cv::Point(closestContourCorner_left_x, closestContourCorner_left_y), true);
            double distanceFromRight = pointPolygonTest(contours[i], cv::Point(closestContourCorner_right_x, closestContourCorner_right_y), true);
            
            if ( distanceFromLeft < 0 )
            {
                distanceFromLeft *= (-1);
            }
            
            if ( distanceFromLeft <= 5 )
            {
                interestingContours.push_back(contours[i]);
            }
            
            if ( distanceFromRight < 0 )
            {
                distanceFromRight *= (-1);
            }
            
            if ( distanceFromRight <= 5 )
            {
                interestingContours.push_back(contours[i]);
            }
        }
    }
    
    // Find the corners of a box that can contain all the interesting contours.
    for ( int i = 0; i < interestingContours.size(); i++ )
    {
        for ( int j = 0; j < interestingContours[i].size(); j++ )
        {
            CvPoint pt = interestingContours[i][j];
            
            //std::cout << "x: " << pt.x << " y: " << pt.y << std::endl;
            
            if ( pt.x < finalBoxCornerLeft_x )
            {
                finalBoxCornerLeft_x = pt.x;
            }
            else if ( pt.x > finalBoxCornerRight_x )
            {
                finalBoxCornerRight_x = pt.x;
            }
            
            if ( pt.y < finalBoxCornerLeft_y )
            {
                finalBoxCornerLeft_y = pt.y;
            }
            else if ( pt.y > finalBoxCornerRight_y )
            {
                finalBoxCornerRight_y = pt.y;
            }
        }
    }
    
    for ( int i = 0; i < contours.size(); i++ )
    {
        approxPolyDP( cv::Mat(contours[i]), contours_poly[i], 3, true );
        boundRect[i] = boundingRect( cv::Mat(contours_poly[i]) );
    }
    
    // Draw polygonal contour + bonding rects.
    cv::Mat drawing = cv::Mat::zeros( threshold_output.size(), CV_8UC3 );
    
    for ( int i = 0; i < contours.size(); i++ )
    {
        cv::Scalar color = cv::Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( drawing, contours_poly, i, color, 1, 8, std::vector<cv::Vec4i>(), 0, cv::Point() );
        //rectangle( drawing, boundRect[i].tl(), boundRect[i].br(), color, 2, 8, 0 );
    }
    
    std::cout << "x: " << finalBoxCornerLeft_x << " y: " << finalBoxCornerLeft_y << std::endl;
    std::cout << "x: " << finalBoxCornerRight_x << " y: " << finalBoxCornerRight_y << std::endl << std::endl;
    
    // Ahhhhh! We should now have the word we want in a box.
    cv::Rect ROI(finalBoxCornerLeft_x, finalBoxCornerLeft_y, (finalBoxCornerRight_x - finalBoxCornerLeft_x), (finalBoxCornerRight_y - finalBoxCornerLeft_y));
    //std::cout << "x: " << finalBoxCornerLeft_x << " y: " << finalBoxCornerLeft_y << " width: " << finalBoxCornerRight_x - finalBoxCornerLeft_x << " height: " << finalBoxCornerRight_y - finalBoxCornerLeft_y << std::endl;
    
    cv::Mat croppedImage;
    cv::Mat(inputImage_gray, ROI).copyTo(croppedImage);
    
    debugPreview_word.image = [appDelegate UIImageFromCVMat:croppedImage];
    debugPreview_word.frame = CGRectMake(finalBoxCornerLeft_x / 2, finalBoxCornerLeft_y / 2, (finalBoxCornerRight_x - finalBoxCornerLeft_x) / 2, (finalBoxCornerRight_y - finalBoxCornerLeft_y) / 2);
    
    debugPreview.image = [appDelegate UIImageFromCVMat:drawing];
    //debugPreview.image = selectedImage;
    
    Tesseract *tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setImage:[appDelegate UIImageFromCVMat:croppedImage]];
    [tesseract recognize];
    
    NSString *term = [tesseract recognizedText];
    
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ&-"] invertedSet];
    term = [[term componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@" "];
    term = [term stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSLog(@"%@", term);
    
    [self fetchDefinitionForTerm:term];
}

- (void)extractorForNonRetina
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    cv::Mat inputImage = [appDelegate cvMatFromUIImage:selectedImage];
    cv::Mat kernel = getStructuringElement( cv::MORPH_ELLIPSE, cv::Size(5, 5) );
    cv::Mat temp;
    cv::Mat inputImage_gray;
    cv::Mat outputImage;
    
    //std::vector<std::vector<cv::Point>> squares = findSquaresInImage(inputImage);
    //cv::Mat outputImage = debugSquares(squares, inputImage);
    
    // Convert image to gray and blur it.
    cvtColor( inputImage, inputImage_gray, CV_BGR2GRAY );
    
    resize(inputImage_gray, temp, cv::Size(inputImage_gray.rows / 4, inputImage_gray.cols / 4));
    morphologyEx(temp, temp, cv::MORPH_CLOSE, kernel);
    resize(temp, temp, cv::Size(inputImage_gray.rows, inputImage_gray.cols));
    
    divide(inputImage_gray, temp, temp, 1, CV_32F); // temp will now have type CV_32F.
    normalize(temp, inputImage_gray, 0, 255, cv::NORM_MINMAX, CV_8U);
    
    cvtColor( inputImage, outputImage, CV_BGR2GRAY );
    blur( outputImage, outputImage, cv::Size(3, 3) );
    
    cv::Mat threshold_output;
    std::vector<std::vector<cv::Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    
    cv::RNG rng(12345);
    double thresh = 100;
    double color = 255;
    bitwise_not(outputImage, outputImage);
    // Detect edges using Threshold.
    threshold( outputImage, threshold_output, thresh, color, CV_THRESH_BINARY );
    
    // Morphological filter.
    cv::Mat element5(5, 5, CV_8U, cv::Scalar(1));
    cv::morphologyEx(threshold_output, threshold_output, cv::MORPH_CLOSE, element5);
    
    // Find contours.
    findContours( threshold_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    // Approximate contours to polygons + get bounding rects.
    std::vector<std::vector<cv::Point> > contours_poly( contours.size() );
    std::vector<cv::Rect> boundRect( contours.size() );
    std::vector<cv::Point2f>center( contours.size() );
    
    std::vector<std::vector<cv::Point> > interestingContours;
    std::vector<cv::Point> finger;
    int fingerTip_x = 0;
    int fingerTip_y = 320;
    int fingerContourIndex = 0;
    int closestContourIndex = 0;
    double closestContourMinDistance = 320.0;
    int closestContourCorner_left_x = 320;
    int closestContourCorner_right_x = 0;
    int closestContourCorner_left_y = 0;
    int closestContourCorner_right_y = 0;
    int finalBoxCornerLeft_x = 320;
    int finalBoxCornerLeft_y = 320;
    int finalBoxCornerRight_x = 0;
    int finalBoxCornerRight_y = 0;
    int imageMidpoint = screenBounds.size.width / 2; // Image is a square 320x320.
    
    // Remove small contours & detect the finger.
    for ( int i = 0; i < contours.size(); i++ )
    {
        if ( contourArea(contours[i], false) < 50 )
        {
            contours.erase(contours.begin() + i);
        }
        
        if ( finger.size() == 0 || contourArea(contours[i], false) > contourArea(finger, false) )
        {
            finger = contours[i];
            fingerContourIndex = i;
        }
    }
    
    // Locate the position top of the finger.
    for ( int i = 0; i < finger.size(); i++ )
    {
        CvPoint pt = finger[i];
        //std::cout << "x:" << pt.x << " y:" << pt.y << std::endl;
        
        if ( pt.x > imageMidpoint - 10 && pt.x < imageMidpoint + 10 )
        {
            if ( pt.y < fingerTip_y && pt.y >= imageMidpoint - 10 )
            {
                fingerTip_y = pt.y;
                fingerTip_x = pt.x;
            }
        }
    }
    
    std::cout << "Coordinates of top of finger - x:" << fingerTip_x << " y:" << fingerTip_y << std::endl;
    redDot.frame = CGRectMake(fingerTip_x - 4, fingerTip_y - 4, redDot.frame.size.width, redDot.frame.size.height);
    
    // Start searching for the closest contour group above the finger.
    for ( int i = 0; i < contours.size(); i++ )
    {
        if ( i != fingerContourIndex ) // Don't want it measuring the distance of the finger to itself.
        {
            double distance = pointPolygonTest(contours[i], cv::Point(fingerTip_x, fingerTip_y), true);
            
            if ( distance < 0 ) // Point should be outside the finger polygon.
            {
                distance *= (-1);
                
                if ( distance < closestContourMinDistance ) // Find the closest contour.
                {
                    closestContourIndex = i;
                    closestContourMinDistance = distance;
                    interestingContours.clear(); // Flush.
                    interestingContours.push_back(contours[i]); // Store this contour as the 1st element here.
                }
            }
        }
    }
    
    // We need to measure the width of the contour.
    std::vector<cv::Point> closestContour = contours[closestContourIndex];
    
    for ( int i = 0; i < closestContour.size(); i++ )
    {
        CvPoint pt = closestContour[i];
        //std::cout << "x:" << pt.x << " y:" << pt.y << std::endl;
        
        if ( pt.x < closestContourCorner_left_x )
        {
            closestContourCorner_left_x = pt.x;
            closestContourCorner_left_y = pt.y;
        }
        else if ( pt.x > closestContourCorner_right_x )
        {
            closestContourCorner_right_x = pt.x;
            closestContourCorner_right_y = pt.y;
        }
    }
    std::cout << "x: " << closestContourCorner_left_x << " y: " << closestContourCorner_left_y << std::endl;
    std::cout << "x: " << closestContourCorner_right_x << " y: " << closestContourCorner_right_y << std::endl << std::endl;
    // Now find the neighboring contours.
    for ( int i = 0; i < contours.size(); i++ )
    {
        if ( i != fingerContourIndex && i != closestContourIndex )
        {
            double distanceFromLeft = pointPolygonTest(contours[i], cv::Point(closestContourCorner_left_x, closestContourCorner_left_y), true);
            double distanceFromRight = pointPolygonTest(contours[i], cv::Point(closestContourCorner_right_x, closestContourCorner_right_y), true);
            
            if ( distanceFromLeft < 0 ) // Point should be outside the polygon.
            {
                distanceFromLeft *= (-1);
                
                if ( distanceFromLeft <= 5 )
                {
                    interestingContours.push_back(contours[i]);
                }
            }
            
            if ( distanceFromRight < 0 )
            {
                distanceFromRight *= (-1);
                
                if ( distanceFromRight <= 5 )
                {
                    interestingContours.push_back(contours[i]);
                }
            }
        }
    }
    
    // Find the corners of a box that can contain all the interesting contours.
    for ( int i = 0; i < interestingContours.size(); i++ )
    {
        for ( int j = 0; j < interestingContours[i].size(); j++ )
        {
            CvPoint pt = interestingContours[i][j];
            
            //std::cout << "x: " << pt.x << " y: " << pt.y << std::endl;
            
            if ( pt.x < finalBoxCornerLeft_x )
            {
                finalBoxCornerLeft_x = pt.x;
            }
            else if ( pt.x > finalBoxCornerRight_x )
            {
                finalBoxCornerRight_x = pt.x;
            }
            
            if ( pt.y < finalBoxCornerLeft_y )
            {
                finalBoxCornerLeft_y = pt.y;
            }
            else if ( pt.y > finalBoxCornerRight_y )
            {
                finalBoxCornerRight_y = pt.y;
            }
        }
    }
    
    for ( int i = 0; i < contours.size(); i++ )
    {
        approxPolyDP( cv::Mat(contours[i]), contours_poly[i], 3, true );
        boundRect[i] = boundingRect( cv::Mat(contours_poly[i]) );
    }
    
    // Draw polygonal contour + bonding rects.
    cv::Mat drawing = cv::Mat::zeros( threshold_output.size(), CV_8UC3 );
    
    for ( int i = 0; i < contours.size(); i++ )
    {
        cv::Scalar color = cv::Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( drawing, contours_poly, i, color, 1, 8, std::vector<cv::Vec4i>(), 0, cv::Point() );
        //rectangle( drawing, boundRect[i].tl(), boundRect[i].br(), color, 2, 8, 0 );
    }
    
    // Ahhhhh! We should now have the word we want in a box.
    cv::Rect ROI(finalBoxCornerLeft_x, finalBoxCornerLeft_y, finalBoxCornerRight_x - finalBoxCornerLeft_x, finalBoxCornerRight_y - finalBoxCornerLeft_y);
    //std::cout << "x: " << finalBoxCornerLeft_x << " y: " << finalBoxCornerLeft_y << " width: " << finalBoxCornerRight_x - finalBoxCornerLeft_x << " height: " << finalBoxCornerRight_y - finalBoxCornerLeft_y << std::endl;
    
    cv::Mat croppedImage;
    cv::Mat(inputImage_gray, ROI).copyTo(croppedImage);
    
    debugPreview_word.image = [appDelegate UIImageFromCVMat:croppedImage];
    debugPreview_word.frame = CGRectMake(finalBoxCornerLeft_x, finalBoxCornerLeft_y, finalBoxCornerRight_x - finalBoxCornerLeft_x, finalBoxCornerRight_y - finalBoxCornerLeft_y);
    
    debugPreview.image = [appDelegate UIImageFromCVMat:inputImage_gray];
    //debugPreview.image = selectedImage;
    
    Tesseract *tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setImage:[appDelegate UIImageFromCVMat:croppedImage]];
    [tesseract recognize];
    
    NSString *term = [tesseract recognizedText];
    
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ&-"] invertedSet];
    term = [[term componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@" "];
    term = [term stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [self fetchDefinitionForTerm:term];
}

- (void)fetchDefinitionForTerm:(NSString *)term
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    // This next part must be done on the main thread.
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( term.length <= 1 || ![UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:term] )
        {
            [Sound soundEffect:0]; // Play error sound.
            circle_outer.image = [UIImage imageNamed:@"circle_outer_red"];
            circle_inner.image = [UIImage imageNamed:@"circle_inner_red"];
            statusBox.hidden = NO;
            statusBox.titleLabel.layer.shadowColor = [UIColor colorWithRed:216/255.0 green:151/255.0 blue:151/255.0 alpha:1.0].CGColor;
            [statusBox setTitleColor:[UIColor colorWithRed:255/255.0 green:193/255.0 blue:183/255.0 alpha:1.0] forState:UIControlStateDisabled];
            [statusBox setTitle:@"Try again!" forState:UIControlStateDisabled];
            [statusBox setBackgroundImage:[[UIImage imageNamed:@"square_red"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateDisabled];
            
            long double delayInSeconds = 2.0;
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                circle_outer.image = [UIImage imageNamed:@"circle_outer"];
                circle_inner.image = [UIImage imageNamed:@"circle_inner"];
                statusBox.hidden = YES;
            });
            
            [appDelegate.strobeLight negativeStrobeLight];
        }
        else
        {
            statusBox.hidden = YES;
            
            //UIReferenceLibraryViewController *reference = [[UIReferenceLibraryViewController alloc] initWithTerm:term];
            //[self presentModalViewController:reference animated:YES];
            
            // Remove the old boxes.
            [[wordBox subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            for( int i = 0; i < term.length; i++ )
            {
                char current = [term characterAtIndex:i];
                
                UIImageView *textFieldBG = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"square"] stretchableImageWithLeftCapWidth:16 topCapHeight:16]];
                textFieldBG.frame = CGRectMake(40 * i, 0, 40, 40);
                textFieldBG.opaque = YES;
                textFieldBG.userInteractionEnabled = YES;
                
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 9, 40, 22)];
                textField.delegate = self;
                textField.borderStyle = UITextBorderStyleNone;
                textField.autocorrectionType = UITextAutocorrectionTypeNo;
                textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                textField.returnKeyType = UIReturnKeyDone;
                textField.textColor = [UIColor colorWithRed:183/255.0 green:245/255.0 blue:255/255.0 alpha:1.0];
                textField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:MAIN_FONT_SIZE];
                textField.textAlignment = NSTextAlignmentCenter;
                textField.text = [NSString stringWithFormat:@"%c", current];
                textField.tag = i;
                
                if ( i == 0 ) // For the first character only.
                {
                    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                }
                
                [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                
                [textFieldBG addSubview:textField];
                [wordBox addSubview:textFieldBG];
            }
            
            NSString *urlString = @"http://api.wordnik.com/v4/word.json/";
            
            // Put it together.
            urlString = [urlString stringByAppendingFormat:@"%@", term];
            urlString = [urlString stringByAppendingFormat:@"/definitions?limit=20&includeRelated=false&useCanonical=true&includeTags=false"];
            urlString = [urlString stringByAppendingFormat:@"&api_key=%@", WORDNIK_API_KEY];
            
            urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            dataRequest = [ASIFormDataRequest requestWithURL:url];
            __weak ASIFormDataRequest *wrequest = dataRequest;
            
            [wrequest setRequestMethod:@"GET"];
            [wrequest setCompletionBlock:^{
                NSError *jsonError;
                definitions = [NSJSONSerialization JSONObjectWithData:[wrequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
                NSLog(@"%@", definitions);
                
                isShowingDefinitions = YES;
                [definitionTable reloadData];
                
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    videoOutputContainer.frame = CGRectMake(0, -320, videoOutputContainer.frame.size.width, videoOutputContainer.frame.size.height);
                    wordBox.alpha = 1.0;
                    definitionTable.alpha = 1.0;
                } completion:^(BOOL finished){
                    
                }];
                
                [appDelegate.strobeLight deactivateStrobeLight];
            }];
            [wrequest setFailedBlock:^{
                NSError *error = [dataRequest error];
                NSLog(@"%@", error);
                
                [appDelegate.strobeLight negativeStrobeLight];
            }];
            [wrequest startAsynchronous];
        }
    });
}

- (void)showDebugView
{
    debugView.hidden = NO;
}

- (void)hideDebugView
{
    debugView.hidden = YES;
}

- (void)textFieldDidChange:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    NSString *text = textField.text;
    
    if (text.length > 1)
    {
        textField.text = [text stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        circle_outer.alpha = 0.0;
        circle_inner.alpha = 0.0;
        crosshairs.alpha = 0.0;
        midLine.alpha = 0.0;
        _videoPreviewView.alpha = 0.1;
        wordBox.frame = CGRectMake(wordBox.frame.origin.x, wordBox.frame.origin.y, 320, 40);
    } completion:^(BOOL finished){
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        circle_outer.alpha = 1.0;
        circle_inner.alpha = 1.0;
        crosshairs.alpha = 1.0;
        midLine.alpha = 1.0;
        _videoPreviewView.alpha = 1.0;
        wordBox.frame = CGRectMake(wordBox.frame.origin.x, wordBox.frame.origin.y, 320, 40);
    } completion:^(BOOL finished){
        NSString *term = @"";
        
        for ( UIView *subview in wordBox.subviews )
        {
            if ( [subview.subviews[0] isKindOfClass:[UITextField class]] )
            {
                UITextField *textField = (UITextField *)subview.subviews[0];
                
                term = [term stringByAppendingString:textField.text];
            }
        }
        
        [self fetchDefinitionForTerm:term];
    }];
    
    return NO;
}

/* ======================================================================================================
 cv::Mat inputImage = [appDelegate cvMatFromUIImage:selectedImage];
 cv::Mat kernel = getStructuringElement( cv::MORPH_ELLIPSE, cv::Size(5, 5) );
 cv::Mat temp;
 cv::Mat inputImage_gray;
 cv::Mat outputImage;
 
 //std::vector<std::vector<cv::Point>> squares = findSquaresInImage(inputImage);
 //cv::Mat outputImage = debugSquares(squares, inputImage);
 
 // Convert image to gray and blur it.
 cvtColor( inputImage, inputImage_gray, CV_BGR2GRAY );
 
 resize(inputImage_gray, temp, cv::Size(inputImage_gray.rows / 4, inputImage_gray.cols / 4));
 morphologyEx(temp, temp, cv::MORPH_CLOSE, kernel);
 resize(temp, temp, cv::Size(inputImage_gray.rows, inputImage_gray.cols));
 
 divide(inputImage_gray, temp, temp, 1, CV_32F); // temp will now have type CV_32F.
 normalize(temp, inputImage_gray, 0, 255, cv::NORM_MINMAX, CV_8U);
 normalize(temp, outputImage, 0, 255, cv::NORM_MINMAX, CV_8U);
 blur( outputImage, outputImage, cv::Size(10, 10) );
 
 cv::Mat threshold_output;
 std::vector<std::vector<cv::Point> > contours;
 std::vector<cv::Vec4i> hierarchy;
 
 cv::RNG rng(12345);
 double thresh = -1;
 double color = 255;
 //bitwise_not(outputImage, outputImage);
 // Detect edges using thresholding.
 threshold( outputImage, threshold_output, thresh, color, CV_THRESH_BINARY + CV_THRESH_OTSU );
 
 // Morphological filter.
 //cv::Mat element5(5, 5, CV_8U, cv::Scalar(1));
 //morphologyEx(threshold_output, threshold_output, cv::MORPH_CLOSE, element5);
 
 // Find contours.
 findContours( threshold_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
====================================================================================================== */

#pragma mark -
#pragma mark UITableViewDataSource methods.

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return definitions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
	if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.opaque = YES;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.numberOfLines = 0;
	}
    
    NSDictionary *entry = [definitions objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@.\n%@", [entry objectForKey:@"partOfSpeech"], [entry objectForKey:@"text"]];
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *entry = [definitions objectAtIndex:indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@\n%@", [entry objectForKey:@"partOfSpeech"], [entry objectForKey:@"text"]];
    
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(280, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    return textSize.height + 41;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods.

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    maskLayer_DefinitionTable.position = CGPointMake(0, scrollView.contentOffset.y);
    
    [CATransaction commit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
