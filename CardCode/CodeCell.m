//
//  ProductCell.m
//  sT.code
//
//  Created by Marco Bonifazi on 11/07/2013.
//  Copyright (c) 2013 Anteleon. All rights reserved.
//

#import "CodeCell.h"
#import <QuartzCore/QuartzCore.h>
@implementation CodeCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (IBAction)deleteButtonPressed:(id)sender {
    
    
    
    
}

- (void)setTextLabel:(NSString*)text {
    [self.text setText:text];
}

- (void)setCodeImage:(UIImage*)image {
    [self.image setImage:image];
}



@end
