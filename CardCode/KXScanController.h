//
//  KXSecondViewController.h
//  CardCode
//
//  Created by Marco Bonifazi on 02/09/2014.
//  Copyright (c) 2014 Keexa. All rights reserved.
//

#import <ZXingObjC/ZXingObjC.h>
#import "KXCode.h"
#import "KXRectView.h"


@interface KXScanController : UIViewController <ZXCaptureDelegate,  UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UILabel *labelText;
@property (nonatomic, weak) IBOutlet KXRectView *scanRectView;
@property (nonatomic, weak) IBOutlet UILabel *decodedLabel;

@property (nonatomic, strong) ZXCapture *capture;

@end

