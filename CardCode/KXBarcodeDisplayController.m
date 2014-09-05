//
//  KXBarcodeBrowseViewController.m
//  CardCode
//
//  Created by Marco Bonifazi on 02/09/2014.
//  Copyright (c) 2014 Keexa. All rights reserved.
//

#import "KXBarcodeDisplayController.h"
#import "KXAppDelegate.h"
#import "KXToast.h"
#import "SVProgressHUD.h"

@interface KXBarcodeDisplayController ()

@end
#define BARCODE_PICTURE 0
#define CARD1_PICTURE 1
#define CARD2_PICTURE 2

@implementation KXBarcodeDisplayController
UIImagePickerController *_picker;
NSManagedObjectContext* _context;
NSData* _imgData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
    }
    return self;
}
-(BOOL)prefersStatusBarHidden { return YES; }

-(void) prepareImage {
    NSLog(@"%s - START - indexPhoto %d", __PRETTY_FUNCTION__, _indexPhoto);

    switch (_indexPhoto) {
        case BARCODE_PICTURE:
            _imgData = self.currentCode.barcodeData;
            [self.toolbar setHidden:YES];
            [self.titleToolbar setTitle:@"Your barcode"];
            break;
        case CARD1_PICTURE:
            _imgData = self.currentCode.picture1;
            [self.toolbar setHidden:NO];
            [self.titleToolbar setTitle:@"Front picture"];
            break;
        case CARD2_PICTURE:
            _imgData = self.currentCode.picture2;
            [self.toolbar setHidden:NO];
            [self.titleToolbar setTitle:@"Back picture"];
            break;
            
        default:
            break;
    }
    UIImage* image = [UIImage imageWithData:_imgData];
    
    if (image.size.width > image.size.height) {
        image = [[UIImage alloc] initWithCGImage:image.CGImage
                                           scale:1.0
                                     orientation:UIImageOrientationRight];
    }
    [self.imageView setImage:image];
    
    NSLog(@"%s - STOP - imageData length %d %f %f", __PRETTY_FUNCTION__, [_imgData length], image.size.width, image.size.height);
}

- (void)viewDidLoad
{
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    _picker = [[UIImagePickerController alloc] init];
    _context = [KXAppDelegate managedObjectContext];
    
    NSArray* array = [KXAppDelegate fetchItem:@"KXCode"
                                WithAttribute:@"barcodeText"
                                   AndContext:_context
                                      equalTo:self.barcodeText];
    self.currentCode = [array firstObject];
    
    if (_indexPhoto == BARCODE_PICTURE) {
        [self.view addSubview: [[KXToast alloc] initWithText: @"Double tap to go back!"]];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:tapGesture];
    }
    
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (void)viewWillDisappear:(BOOL)animated  {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self prepareImage];
    
    
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    
    
    
    if (_imgData == nil) {
        [self cameraButtonPressed:self];
    }
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)normalizedImage:(UIImage*)image {
    if (image.imageOrientation == UIImageOrientationLeft) {
        return image;
    }
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image {
    int kMaxResolution = 2000; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width-1, height-1), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    UIView* view = [picker.view snapshotViewAfterScreenUpdates:YES];
    [picker.view addSubview:view];
    [picker.view bringSubviewToFront:view];
    
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage* scaledImage = [self scaleAndRotateImage:image];
        NSData *imageData = UIImageJPEGRepresentation(scaledImage, 0.8f);
        
        switch (_indexPhoto) {
            case CARD1_PICTURE:
                [self.currentCode setPicture1:imageData];
                break;
            case CARD2_PICTURE:
                [self.currentCode setPicture2:imageData];
                break;
            default:
                break;
        }
        
        [KXAppDelegate saveWithContext:_context];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self dismissViewControllerAnimated:YES completion:nil];
            [view removeFromSuperview];
        });
    });
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

- (IBAction)cameraButtonPressed:(id)sender {
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    _picker.delegate = self;
    _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    _picker.showsCameraControls = NO;
    
    _picker.cameraOverlayView = self.overlayView;
    
    [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
    self.overlayView.frame = _picker.cameraOverlayView.frame;
    _picker.cameraOverlayView = self.overlayView;
    //self.overlayView = nil;
    
    [self presentViewController:_picker animated:YES
                     completion:nil];
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)takePicturePressed:(id)sender {
    [_picker takePicture];
}

- (IBAction)okButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
