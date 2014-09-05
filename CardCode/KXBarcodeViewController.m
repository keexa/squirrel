//
//  KXBarcodeViewController.m
//  CardCode
//
//  Created by Marco Bonifazi on 02/09/2014.
//  Copyright (c) 2014 Keexa. All rights reserved.
//

#import "KXBarcodeViewController.h"
#import "KXAppDelegate.h"
#import "KXBarcodeDisplayController.h"

@implementation KXBarcodeViewController
#define BARCODE_PICTURE 0
#define CARD1_PICTURE 1
#define CARD2_PICTURE 2

NSInteger _indexPhoto;
NSManagedObjectContext* _context;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.barcodeLabel setText:@""];
    _context = [KXAppDelegate managedObjectContext];
}


- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    if (self.barcode.barcodeData) {
        UIImage *thumbnail = [UIImage imageWithData:self.barcode.barcodeData scale:2.0];
        self.barcodeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.barcodeButton setImage:thumbnail forState:UIControlStateNormal];
        NSLog(@"%s - %f %f", __PRETTY_FUNCTION__, thumbnail.size.width, thumbnail.size.height);

    }
    
    if (self.barcode.picture1) {
        UIImage *thumbnail = [UIImage imageWithData:self.barcode.picture1 scale:5.0];
        self.card1Button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.card1Button setImage:thumbnail forState:UIControlStateNormal];
        NSLog(@"%s - %f %f", __PRETTY_FUNCTION__, thumbnail.size.width, thumbnail.size.height);

    }
    
    if (self.barcode.picture2) {
        UIImage *thumbnail = [UIImage imageWithData:self.barcode.picture2 scale:5.0];
        self.card2Button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.card2Button setImage:thumbnail forState:UIControlStateNormal];
        NSLog(@"%s - %f %f", __PRETTY_FUNCTION__, thumbnail.size.width, thumbnail.size.height);

    }
    NSString* barcode = [NSString stringWithFormat:@"Your barcode: %@", self.barcode.barcodeText];
    [self.barcodeLabel setText:barcode];
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (IBAction)barcodeTouched:(id)sender {
    _indexPhoto = BARCODE_PICTURE;
    [self performSegueWithIdentifier:@"displayImage" sender:self];
    
}

- (IBAction)card1Touched:(id)sender {
    _indexPhoto = CARD1_PICTURE;
    [self performSegueWithIdentifier:@"displayImage" sender:self];
    
}

- (IBAction)card2Touched:(id)sender {
    _indexPhoto = CARD2_PICTURE;
    [self performSegueWithIdentifier:@"displayImage" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    
    if ([segue.identifier isEqualToString:@"displayImage"]) {
        KXBarcodeDisplayController* barcodeBrowseViewController = [segue destinationViewController];
         [barcodeBrowseViewController setBarcodeText:self.barcode.barcodeText];
        [barcodeBrowseViewController setIndexPhoto:_indexPhoto];
        NSLog(@"%s - segue", __PRETTY_FUNCTION__);
    }
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}


@end
