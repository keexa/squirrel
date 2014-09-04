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
        // Custom initialization
    }
    return self;
}
-(void) prepareImage {
    UIImage* image;
    switch (_indexPhoto) {
        case BARCODE_PICTURE:
            _imgData = self.currentCode.barcodeData;
            [self.bottomView setHidden:YES];
            [self.descriptionLabel setText:@"Your barcode"];
            break;
        case CARD1_PICTURE:
            _imgData = self.currentCode.picture1;
            [self.bottomView setHidden:NO];
            [self.descriptionLabel setText:@"Front picture"];
            break;
        case CARD2_PICTURE:
            _imgData = self.currentCode.picture2;
            [self.bottomView setHidden:NO];
            [self.descriptionLabel setText:@"Back picture"];
            break;
            
        default:
            break;
    }
    image = [UIImage imageWithData:_imgData];
    if (image.size.width > image.size.height) {
        UIImage * rotImage = [[UIImage alloc] initWithCGImage: image.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationRight];
        [self.imageView setImage:rotImage];
        
    } else {
        [self.imageView setImage:image];
    }
    // self.imageView.transform = CGAffineTransformMakeRotation(M_PI/2);
    
}

-(void) prepareCamera {
    UIToolbar* toolBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-54, self.view.frame.size.width, 55)];
    
    toolBar.barStyle =  UIBarStyleBlackOpaque;
    NSArray *items=[NSArray arrayWithObjects:
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel  target:self action:@selector(cancelPicture)],
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera  target:self action:@selector(shootPicture)],
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                    nil];
    [toolBar setItems:items];
    
    // create the overlay view
    OverlayView* overlayView = [[OverlayView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
    
    // important - it needs to be transparent so the camera preview shows through!
    overlayView.opaque=NO;
    overlayView.backgroundColor=[UIColor clearColor];
    
    // parent view for our overlay
    UIView *cameraView=[[UIView alloc] initWithFrame:self.view.bounds];
    [cameraView addSubview:overlayView];
    [cameraView addSubview:toolBar];
    
    imagePickerController = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
        NSLog(@"Camera not available");
        return;
    }
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    
    // hide the camera controls
    imagePickerController.showsCameraControls=NO;
    imagePickerController.wantsFullScreenLayout = YES;
    [imagePickerController setCameraOverlayView:cameraView];
    
    [self presentViewController:imagePickerController animated:YES completion:nil];


}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _picker = [[UIImagePickerController alloc] init];
    _context = [KXAppDelegate managedObjectContext];
    
    if (_indexPhoto == BARCODE_PICTURE) {
        [self.view addSubview: [[KXToast alloc] initWithText: @"Double tap to go back!"]];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:tapGesture];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated  {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    [self prepareImage];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    if (_imgData == nil) {
        [self cameraButtonPressed:self];
    } else {
        
        // Do any additional setup after loading the view.
    }
    
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
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
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"%s - %f %f", __PRETTY_FUNCTION__, image.size.width, image.size.height);
    
    UIImage* scaledImage = [self scaleAndRotateImage:image];
    [self.imageView setImage:scaledImage];
    NSData *imageData = UIImageJPEGRepresentation(scaledImage, 0.8f);
    
    
    switch (_indexPhoto) {
        case BARCODE_PICTURE:
            //  [self.barcode setBarcodeData:imageData];
            // [self.barcodeButton setBackgroundImage:scaledImage forState:UIControlStateNormal];
            break;
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
    [self prepareImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
    
}

- (IBAction)cameraButtonPressed:(id)sender {
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    
    _picker.delegate = self;
    _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    
    _picker.showsCameraControls = YES;
    [self presentViewController:_picker animated:YES
                     completion:^ {
                         [_picker takePicture];
                     }];
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

- (IBAction)okButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // return which subview we want to zoom
    return self.imageView;
}


@end
