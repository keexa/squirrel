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

@protocol SecondDelegate <NSObject>
-(void) secondViewControllerDismissed:(KXCode*)code;
@end


@interface KXScanController : UIViewController <ZXCaptureDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (nonatomic, strong) ZXCapture *capture;
@property (nonatomic, weak) IBOutlet KXRectView *scanRectView;
@property (nonatomic, weak) IBOutlet UILabel *decodedLabel;
@property (nonatomic, weak) id<SecondDelegate> myDelegate;

@end

