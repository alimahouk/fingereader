//
//  RootViewController.h
//  Fingereader
//
//  Created by Ali Mahouk on 5/31/13.
//
//

#import "ASIFormDataRequest.h"
#import "AVCamCaptureManager.h"

@interface RootViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCamCaptureManagerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    __block ASIFormDataRequest *dataRequest;
    NSDictionary *responseData;
    UIImagePickerController *photoPicker;
    UIImageView *debugPreview;
    UIImageView *debugPreview_word;
    UIImageView *redDot;
    UIImageView *crosshairs;
    UIImageView *midLine;
    UIImageView *circle_outer;
    UIImageView *circle_inner;
    UITableView *definitionTable;
    UIView *debugView;
    UIView *videoOutputContainer;
    UIView *flashLayer;
    UIView *segmentLine;
    UIView *wordBox;
    UIImage *selectedImage;
    UIButton *statusBox;
    UIButton *defineButton;
    NSArray *definitions;
    CAGradientLayer *maskLayer_DefinitionTable;
    NSTimer *outerCircleTimer;
    NSTimer *innerCircleTimer;
    BOOL isShowingDefinitions;
}

@property (nonatomic, retain) AVCamCaptureManager *captureManager;
@property (nonatomic, retain) UIView *videoPreviewView;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

- (void)showCamera;
- (void)showImagePicker;
- (void)captureImage;
- (void)speedUpOuterCircle;
- (void)speedUpInnerCircle;
- (void)slowDownOuterCircle;
- (void)slowDownInnerCircle;
- (void)extractorForRetina;
- (void)extractorForNonRetina;
- (void)fetchDefinitionForTerm:(NSString *)term;
- (void)showDebugView;
- (void)hideDebugView;
- (void)textFieldDidChange:(id)sender;

@end