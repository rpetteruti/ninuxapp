//
//  customPin.h
//  ninuxapp
//
//  Created by Neo on 16/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapNode.h"

@interface customPin : MKPointAnnotation
{ 
    MapNode *associatedNode;
    
    
}
@property (nonatomic, retain) MapNode *associatedNode;



@end