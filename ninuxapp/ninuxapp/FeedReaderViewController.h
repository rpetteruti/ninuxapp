//
//  FirstViewController.h
//  ninuxapp
//
//  Created by Neo on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUDView.h"
#import "MapVisualizationViewController.h"
#import <MapKit/MapKit.h>
#import <sqlite3.h>
#import "SBJson.h"
#import "customPin.h"
#import "MapNode.h"

#define pathDB @"nodes.sqlite"


static sqlite3 *database = nil;

@interface FeedReaderViewController : UIViewController <UIGestureRecognizerDelegate,HUDViewDelegate>{
    
    NSTimer *myTimer;
    
    UISearchDisplayController *displayController;
    UITapGestureRecognizer *touchRecognizer;
    IBOutlet UISearchBar *searchBar;
    IBOutlet UIView * view;
    BOOL  controlsAreDisplayed;
    HUDView *hudView;
    
    double lastMapUpdate;
    
    
    //map related stuff
    IBOutlet MKMapView *map;
    NSString *writableDBPath;
    
    
    
}
-(void)populateMap;

-(void)saveSettings;




@end
