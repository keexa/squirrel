//
//  KXBarcodeViewController.h
//  CardCode
//
//  Created by Marco Bonifazi on 02/09/2014.
//  Copyright (c) 2014 Keexa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXCode.h"

@interface KXBarcodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *barcodeButton;
@property (weak, nonatomic) IBOutlet UIButton *card1Button;
@property (weak, nonatomic) IBOutlet UIButton *card2Button;
@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;
@property (nonatomic, weak) KXCode* barcode;

- (IBAction)barcodeTouched:(id)sender;
- (IBAction)card1Touched:(id)sender;
- (IBAction)card2Touched:(id)sender;


@end
