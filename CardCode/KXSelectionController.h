//
//  KXSelectionController.h
//  CardCode
//
//  Created by Marco Bonifazi on 02/09/2014.
//  Copyright (c) 2014 Keexa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXCode.h"
#import "KXScanController.h"

@interface KXSelectionController : UIViewController <UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIGestureRecognizerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) KXCode* currentCode;
- (IBAction)plusButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)deleteButtonPressed:(id)sender forEvent:(UIEvent *)event;

@end
