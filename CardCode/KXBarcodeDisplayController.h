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

@property (nonatomic, strong) KXCode* currentCode;
@property (nonatomic) NSInteger indexPhoto;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
