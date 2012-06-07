//
//  SecondViewController.h
//  ninuxapp
//
//  Created by Neo on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define pathDB @"nodes.sqlite"

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SBJson.h"
#import <sqlite3.h>

static sqlite3 *database = nil;

@interface SecondViewController : UIViewController{
    
    IBOutlet MKMapView *map;
    NSString *writableDBPath;
    
}
-(void)populateMap;

@end
