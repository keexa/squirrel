//
//  ProductCell.h
//  sT.code
//
//  Created by Marco Bonifazi on 11/07/2013.
//  Copyright (c) 2013 Anteleon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CodeCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView *image;
@property (nonatomic, strong) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (void)setTextLabel:(NSString*)text;
- (void)setCodeImage:(UIImage*)image;

@end
