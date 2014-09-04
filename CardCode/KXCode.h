//
//  KXCode.h
//  CardCode
//
//  Created by Marco Bonifazi on 02/09/2014.
//  Copyright (c) 2014 Keexa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KXCode : NSManagedObject

@property (nonatomic, retain) NSData * barcodeData;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSData * picture1;
@property (nonatomic, retain) NSString * barcodeText;
@property (nonatomic, retain) NSData * picture2;
@property (nonatomic, retain) NSString * barcodeDescription;

@end
