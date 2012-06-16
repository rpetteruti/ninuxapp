//
//  customPin.h
//  ninuxapp
//
//  Created by Neo on 16/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface customPin : MKPointAnnotation
{ 
    NSString *nodeName;
    NSString *type;
    
    
}
@property (nonatomic, retain) NSString *nodeName;
@property (nonatomic, retain) NSString *type;

@end