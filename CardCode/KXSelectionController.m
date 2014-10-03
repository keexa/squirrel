//
//  KXSelectionController.m
//  CardCode
//
//  Created by Marco Bonifazi on 02/09/2014.
//  Copyright (c) 2014 Keexa. All rights reserved.
//

#import "KXSelectionController.h"
#import <CoreData/CoreData.h>
#import "KXCode.h"
#import "CodeCell.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "KXAppDelegate.h"
#import "KXBarcodeViewController.h"

@implementation KXSelectionController
NSArray* _pictures;
NSArray* _codes;
NSManagedObjectContext* _context;
NSInteger _numberOfColumns;
CodeCell* _currentCell;

- (void)viewDidLoad
{
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    _context = [KXAppDelegate managedObjectContext];
    
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delegate = self;
    [self.collectionView addGestureRecognizer:lpgr];
    
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
    
}

-(void) initGUI {
    _codes = [self fetchAllItems:@"KXCode" sortingBy:@"barcodeText"];
    
    if ([_codes count] == 0) {
        [self.plusButton setHidden:NO];
        [self.collectionView setHidden:YES];
    } else {
        [self.plusButton setHidden:YES];
        [self.collectionView setHidden:NO];
        _pictures = [self preparePictures];
        [self.collectionView reloadData];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s - START", __PRETTY_FUNCTION__);

    if (!self.currentCode) {
        _numberOfColumns = 2;
        [self initGUI];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
        
        CGAffineTransform leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-3.0));
        CGAffineTransform rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(3.0));
        // get the cell at indexPath (the one you long pressed)
        CodeCell* cell = (CodeCell*)
        [self.collectionView  cellForItemAtIndexPath:indexPath];
        
        
        // do stuff with the cell
        
        cell.transform = leftWobble;  // starting point
        
        [UIView animateWithDuration:0.125 delay:0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction) animations:^{
            cell.transform = rightWobble;
        }completion:^(BOOL finished){
            cell.transform = CGAffineTransformIdentity;
            
        }];
        [cell.deleteButton setHidden:NO];
    }
}

- (IBAction)deleteButtonPressed:(id)sender forEvent:(UIEvent *)event {
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    
    NSSet *touches = [event allTouches];
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint: currentTouchPosition];

   
    CodeCell* cell = (CodeCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        [cell.layer removeAllAnimations];
    }
    self.currentCode = [_codes objectAtIndex:indexPath.row];
    _currentCell = cell;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"No, let's keep it"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Yes, delete my barcode!",nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        
        [KXAppDelegate deleteItemsInArray:[NSArray arrayWithObject:self.currentCode]
                              withContext:_context];
        [KXAppDelegate saveWithContext:_context];
        [self initGUI];
        [self.collectionView reloadData];
    } else {
        [_currentCell.deleteButton setHidden:YES];
    }
}

- (NSArray*) fetchAllItems: (NSString *) entityName
                 sortingBy: (NSString *) sortAttribute {
    NSEntityDescription *entityDescription =
    [NSEntityDescription entityForName:entityName
                inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    // Apply an ascending sort for the items
    NSString *sortKey = sortAttribute;
    NSSortDescriptor *sortDescriptor =
    [[NSSortDescriptor alloc] initWithKey:sortKey
                                ascending:YES
                                 selector:nil];
    NSArray *descriptors = @[sortDescriptor];
    [request setSortDescriptors:descriptors];
    
    NSError *error = nil;
    NSArray *fetchResults = [_context executeFetchRequest:request
                                                    error:&error];
    
    if (fetchResults != nil) {
        NSUInteger count = [fetchResults count]; // May be 0 if the object has been deleted.
        NSLog(@"Count fetchArrayOfItems: %lu", count);
        
    } else {
        NSLog(@"Error fetchArrayOfItems: %@", [error description]);
    }
    
    return fetchResults;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    
    self.currentCode = [_codes objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"startBarcodeController" sender:self];
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell.layer removeAllAnimations]; 
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    NSLog(@"%s - START", __PRETTY_FUNCTION__);
    
    if ([segue.identifier isEqualToString:@"startBarcodeController"]) {
        NSLog(@"%s - segue", __PRETTY_FUNCTION__);
        
        KXBarcodeViewController * barcodeViewController = [segue destinationViewController];
        [barcodeViewController setBarcode:self.currentCode];
        self.currentCode = nil;
        
    } else if ([segue.identifier isEqualToString:@"startBarcodeScan"]) {
     //   KXScanController* secondViewController =  [segue destinationViewController];
    }
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
}

- (void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

- (void)collectionView:(UICollectionView *)collectionView
didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell.layer setBorderColor: UIColorFromRGB(0xd04def).CGColor];
    [cell.layer setBorderWidth:3.0f];
    
}

- (void)collectionView:(UICollectionView *)collectionView
didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell.layer setBorderColor:nil];//UIColorFromRGB(0xd04def).CGColor];
    [cell.layer setBorderWidth:0.0f];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    //NSLog(@"numberOfItemsInSection - %d", [_codes count]);
    
    return _codes.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CodeCell* cell =
    [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell"
                                              forIndexPath:indexPath];
    [cell.layer setCornerRadius:15];
    [cell.layer removeAllAnimations];
    [cell.deleteButton setHidden:YES];
    cell.image.bounds = CGRectMake(5, 5, cell.bounds.size.width - 10, cell.bounds.size.height - 10);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            KXCode* code = [_codes objectAtIndex:indexPath.row];
            UIImage* image = [_pictures objectAtIndex:indexPath.row];
            [cell setCodeImage:image];
            [cell setTextLabel:code.barcodeText];
            [cell.deleteButton setHidden:YES];
            
            //[cell.layer setCornerRadius:7.5f];
            // cell.layer.masksToBounds = YES;
        });
    });
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger spacing = 6;
    NSInteger borderWidth = 5;
    NSInteger widthRemove = (_numberOfColumns - 1) * spacing;
    
    NSInteger width = (collectionView.bounds.size.width - widthRemove - borderWidth * 2) / _numberOfColumns;
    ;
    NSInteger height = width * 0.8;

    CGSize retval = CGSizeMake(width, height);
    return retval;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


-(NSArray*)preparePictures {
    NSMutableArray* pictures = [NSMutableArray arrayWithCapacity:[_codes count]];
    
    for (KXCode* code in _codes) {
        NSData* codeData;
        
        if (code.picture1) {
            codeData = code.picture1;
        } else if (code.picture2) {
            codeData = code.picture2;
        } else {
            codeData = code.barcodeData;
        }
        
        UIImage* origImg = [UIImage imageWithData:codeData scale:4.0];
        
        [pictures addObject:origImg];
    }
    return pictures;
}

- (IBAction)plusButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"startBarcodeScan" sender:self];
}


@end
