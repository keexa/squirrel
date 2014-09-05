//
//  KXSecondViewController.m
//  CardCode
//
//  Created by Marco Bonifazi on 02/09/2014.
//  Copyright (c) 2014 Keexa. All rights reserved.
//
#import "KXScanController.h"
#import "KXCode.h"
#import "KXAppDelegate.h"
#import "KXBarcodeViewController.h"
#import "KXSelectionController.h"

@implementation KXScanController
NSManagedObjectContext* _context;
KXCode* _currentCode;
BOOL _hasFinished;

- (BOOL) deleteItemsInArray: (NSArray *) arrayItems {
    
    for (NSManagedObject *entry in arrayItems) {
        [_context deleteObject:entry];
    }
    return [KXAppDelegate saveWithContext:_context];
}


-(int)getCorrectHeightWith:(int)width
                 andFormat:(ZXBarcodeFormat)format {
    switch (format) {
        case kBarcodeFormatAztec:
        case kBarcodeFormatDataMatrix:
        case kBarcodeFormatMaxiCode:
        case kBarcodeFormatQRCode:
            return width;
            break;
            
        default:
            return width / 2;
            
            break;
    }
    
}


-(BOOL) insertCode:(NSString*) text
        withFormat:(ZXBarcodeFormat) format {
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    
    _currentCode = [NSEntityDescription insertNewObjectForEntityForName:@"KXCode"
                                                 inManagedObjectContext: _context];
    [_currentCode setBarcodeText:text];
    
    NSError *error = nil;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    int width = 600;
    int height = [self getCorrectHeightWith:width andFormat:format];
    ZXBitMatrix* result;
    @try {
        result = [writer encode:text
                                      format:format
                                       width:width
                                      height:height
                                       error:&error];
    }
    
    @catch ( NSException *e ) {
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"%s - error encoder%@", __PRETTY_FUNCTION__, errorMessage);
        return FALSE;
    }

    if (result) {
        CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage];
        UIImage* myImage = [[UIImage alloc] initWithCGImage:image];
        NSData *imageData = UIImagePNGRepresentation(myImage);
        [_currentCode setBarcodeData:imageData];
        [KXAppDelegate saveWithContext:_context];
        NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
        return TRUE;
    } else {
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"%s - error %@", __PRETTY_FUNCTION__, errorMessage);
        return FALSE;
    }
}

+(NSString*) encodeToPercentEscapeString:(NSString *) unencodedString {
    
    NSString * encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                            NULL,
                                                                                            (CFStringRef)unencodedString,
                                                                                            NULL,
                                                                                            (CFStringRef)@"!*'();`:@&=+$,/?%#[]",
                                                                                            kCFStringEncodingUTF8 );
    return encodedString;
}

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    NSLog(@"%s - START, %@", __PRETTY_FUNCTION__, result);
    
    if (!result) {
        return;
        
    }
    [self.scanRectView setColorRectangleRed:0.0 Green:1.0 Blue:0.0];
    
    BOOL isPresent = [KXAppDelegate checkItem:@"KXCode"
                                WithAttribute:@"barcodeText"
                                   AndContext:_context
                                      equalTo:result.text];
    BOOL inserted = NO;
    
    if (!isPresent) {
        inserted = [self insertCode:result.text
                         withFormat:result.barcodeFormat];
    }
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.capture stop];
            self.capture.delegate = nil;

            if (!isPresent && inserted) {
                
                [self.navigationController popViewControllerAnimated:YES];
                _hasFinished = TRUE;
            } else {
                [self.scanRectView setColorRectangleRed:0.0 Green:1.0 Blue:0.0];
                [self.scanRectView setNeedsDisplay];
                UIActionSheet *actionSheet;
                
                if (!isPresent && !inserted) {
                    [self.decodedLabel setText:@"Error in decoding barcode!"];
                    actionSheet= [[UIActionSheet alloc] initWithTitle:@"There was an issue in decoding your barcode"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Try again!",nil];
                    
                } else {
                    [self.decodedLabel setText:@"Barcode already present!"];
                    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Your barcode is already in the phone"
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"Try again!",nil];
                    
                }
                [actionSheet showInView:self.view];
            }
            //[self.navigationController popViewControllerAnimated:YES];
            
            
        });
    });
    
    
    
    // Vibrate
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    
    [self initCapture];
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        
    }
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (_hasFinished) {
        if([self.myDelegate respondsToSelector:@selector(secondViewControllerDismissed:)])
        {
            [self.myDelegate secondViewControllerDismissed:_currentCode];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.capture.delegate = nil;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    
    if ([segue.identifier isEqualToString:@"startBarcodeController"]) {
        KXBarcodeViewController* barcodeViewController = [segue destinationViewController];
        [barcodeViewController setBarcode:_currentCode];
        NSLog(@"%s - segue", __PRETTY_FUNCTION__);
    }
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    _context = [KXAppDelegate managedObjectContext];
    
    self.capture = [[ZXCapture alloc] init];
    self.capture.camera = self.capture.back;
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    self.capture.rotation = 180.0f;
    
    [self.view.layer addSublayer:self.capture.layer];
    
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

-(void) initCapture {
    self.capture.delegate = self;
    self.capture.layer.frame = self.view.bounds;
    [self.scanRectView setColorRectangleRed:1.0 Green:0.0 Blue:0.0];
    [self.view.layer addSublayer:self.capture.layer];
    [self.view bringSubviewToFront:self.scanRectView];
    [self.view bringSubviewToFront:self.decodedLabel];
    [self.scanRectView setNeedsDisplay];
    
   // self.capture.scanRect =  self.scanRectView.bounds;// CGRectMake(0,0, 300, 200);
    
    if (![self.capture running]) {
        [self.capture start];
    }
    
    
    [self.labelText setText:@"Scan your barcode here!"];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    _hasFinished = FALSE;
    [self initCapture];
    //CGAffineTransform captureSizeTransform = CGAffineTransformMakeScale(320 / self.view.frame.size.width, 480 / self.view.frame.size.height);
    //self.capture.scanRect = self.view.frame;//CGRectApplyAffineTransform(self.scanRectView.frame, captureSizeTransform);
    NSLog(@"%f %f", self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"%f %f", self.capture.scanRect.size.width, self.capture.scanRect.size.height);
    
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

#pragma mark - Private Methods

- (NSString *)barcodeFormatToString:(ZXBarcodeFormat)format {
    switch (format) {
        case kBarcodeFormatAztec:
            return @"Aztec";
            
        case kBarcodeFormatCodabar:
            return @"CODABAR";
            
        case kBarcodeFormatCode39:
            return @"Code 39";
            
        case kBarcodeFormatCode93:
            return @"Code 93";
            
        case kBarcodeFormatCode128:
            return @"Code 128";
            
        case kBarcodeFormatDataMatrix:
            return @"Data Matrix";
            
        case kBarcodeFormatEan8:
            return @"EAN-8";
            
        case kBarcodeFormatEan13:
            return @"EAN-13";
            
        case kBarcodeFormatITF:
            return @"ITF";
            
        case kBarcodeFormatPDF417:
            return @"PDF417";
            
        case kBarcodeFormatQRCode:
            return @"QR Code";
            
        case kBarcodeFormatRSS14:
            return @"RSS 14";
            
        case kBarcodeFormatRSSExpanded:
            return @"RSS Expanded";
            
        case kBarcodeFormatUPCA:
            return @"UPCA";
            
        case kBarcodeFormatUPCE:
            return @"UPCE";
            
        case kBarcodeFormatUPCEANExtension:
            return @"UPC/EAN extension";
            
        default:
            return @"Unknown";
    }
}





@end
