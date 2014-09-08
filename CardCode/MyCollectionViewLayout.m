//
//  MyCollectionViewLayout.m
//  sT.code
//
//  Created by Marco Bonifazi on 12/02/2014.
//

#import "MyCollectionViewLayout.h"

@implementation MyCollectionViewFlowLayout

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;

}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newAttributes = [NSMutableArray arrayWithCapacity:attributes.count];
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        
        if ((attribute.frame.origin.x + attribute.frame.size.width <= self.collectionViewContentSize.width && attribute.frame.origin.y + attribute.frame.size.height <= self.collectionViewContentSize.height))
        {
            [newAttributes addObject:attribute];
        }
    }
    return newAttributes;
}


@end
