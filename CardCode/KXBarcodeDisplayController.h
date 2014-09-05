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

@property (nonatomic, weak) KXCode* currentCode;
@property (nonatomic, weak) NSString* barcodeText;
@property (nonatomic) NSInteger indexPhoto;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIImageView *overlayView;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)takePicturePressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end
