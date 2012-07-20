//
//  MapNode.h
//  ninuxapp
//
//  Created by Neo on 10/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapNode : NSObject{
    NSString *nodeName;
    NSString *type;
    CLLocationCoordinate2D coords;
    
    
}
@property (nonatomic, retain) NSString *nodeName;
@property (nonatomic, retain) NSString *type;
@property (nonatomic) CLLocationCoordinate2D coords;

@end