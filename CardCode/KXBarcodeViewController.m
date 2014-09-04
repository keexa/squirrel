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

- (void) prepareButton:(UIButton*)button
           withData:(NSData*)data {
    UIImage *image = [UIImage imageWithData:data];
    NSLog(@"%s - %f %f", __PRETTY_FUNCTION__, image.size.width, image.size.height);
    
    [button setImage:image forState:UIControlStateNormal];
    
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%s - START", __PRETTY_FUNCTION__);

    [super viewWillAppear:animated];
    if (self.barcode.barcodeData) {
        [self prepareButton:self.barcodeButton withData:self.barcode.barcodeData];
    }
    
    if (self.barcode.picture1) {
        [self prepareButton:self.card1Button withData:self.barcode.picture1];
    }
    
    if (self.barcode.picture2) {
        [self prepareButton:self.card2Button withData:self.barcode.picture2];
    }
    
    [self.barcodeLabel setText:@"Your barcode"];
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
        NSData* imageData;
        
        switch (_indexPhoto) {
            case BARCODE_PICTURE:
                imageData = self.barcode.barcodeData;
                break;
            case CARD1_PICTURE:
                imageData = self.barcode.picture1;
                break;
            case CARD2_PICTURE:
                imageData = self.barcode.picture2;
                break;
            default:
                break;
        }
        UIImage* image = [UIImage imageWithData:imageData];
        [barcodeBrowseViewController setCurrentCode:self.barcode];
        [barcodeBrowseViewController setIndexPhoto:_indexPhoto];
        NSLog(@"%s - segue", __PRETTY_FUNCTION__);
    }
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}


@end
