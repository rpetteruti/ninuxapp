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
#import "MapNode.h"
#import "SearchResultsCell.h"
#import "MapOptionsViewController.h"
#import "LoadingHUD.h"
#define pathDB @"nodes.sqlite"
#define timeOutdatedMap 86400.0



@interface MapViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,MapOptionsDelegate> {
    sqlite3 *database;
    IBOutlet MKMapView *map;
    NSString *writableDBPath;
    
    NSMutableDictionary *resultsDictionary;
    NSMutableArray *resultsArray;
    SearchResultsCell *tmpCell;
    MKPolyline *polyline;
    //CLLocationCoordinate2D *linksArray;
    MapNode *touchedNode;
    IBOutlet UIButton *clearLinks;
    
    NSTimer *myTimer;
    double lastMapUpdate;
    LoadingHUD *hud;
    
    NSString *jsonURL;
    
}


@property (nonatomic, retain) NSMutableArray *resultsArray;
@property (nonatomic, retain) NSMutableArray *linksArray;
@property (nonatomic, retain) IBOutlet SearchResultsCell *tmpCell;
@property (nonatomic, retain) MKPolyline *polyline;
@property (nonatomic, retain) MapNode *touchedNode;
@property (nonatomic, retain) IBOutlet UIButton *clearLinks;
@property (nonatomic, retain) LoadingHUD *hud;


/*!
 @function reloadTable
 Reload the table with the found nodes
 */
-(IBAction)reloadTable:(id)sender;
/*!
 @function findNode
 Search a node in the local database
 */
-(IBAction)findNode:(id) sender;
/*!
 @function drawLine
 It is used to draw a line that is a wireless link between two nodes
 */
-(IBAction)drawLine:(id)sender;
/*!
 @function doLookForLinks
 Is used to find all wireless link between two nodes
 */
-(IBAction)doLookForLinks:(id)sender;
/*!
 @function doClearLinks
 Is used to remove all links on the map
 */
-(IBAction)doClearLinks:(id)sender;
-(void) displayLinkLines;
/*!
 @function setMapType
 Change the type of the map (standard, hybrid and satellite)
 */
-(void) setMapType:(NSUInteger)type;

@end
