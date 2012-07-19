//
//  MapNode.h
//  ninuxapp
//
//  Created by Mara Sorella on 10/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapNode : NSObject{
NSString *nodeName;
NSString *type;


}
@property (nonatomic, retain) NSString *nodeName;
@property (nonatomic, retain) NSString *type;

@end
