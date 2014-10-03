//
//  KXBarcodeBrowseViewController.h
//  CardCode
//
//  Created by Marco Bonifazi on 02/09/2014.
//  Copyright (c) 2014 Keexa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXCode.h"

@interface KXBarcodeDisplayController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

- (IBAction)okButtonPressed:(id)sender;
- (IBAction)cameraButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)takePicturePressed:(id)sender;

@property (nonatomic) NSInteger indexPhoto;
@property (nonatomic, strong) KXCode* currentCode;
@property (nonatomic, strong) NSString* barcodeText;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *overlayView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *titleToolbar;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end
