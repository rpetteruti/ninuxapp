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
#define pathDB @"nodes.sqlite"

@protocol MapOptionsDelegate <NSObject>
@required
- (void) setMapType:(int)type;
@end

@interface MapViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate> {
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
    
}


@property (nonatomic, retain) NSMutableArray *resultsArray;
@property (nonatomic, retain) NSMutableArray *linksArray;
@property (nonatomic, retain) IBOutlet SearchResultsCell *tmpCell;
@property (nonatomic, retain) MKPolyline *polyline;
@property (nonatomic, retain) MapNode *touchedNode;
@property (nonatomic, retain) IBOutlet UIButton *clearLinks;

@property (nonatomic, assign) id <MapOptionsDelegate> delegate;

-(IBAction)reloadTable:(id)sender;
-(IBAction)findNode:(id) sender;
-(IBAction)drawLine:(id)sender;
-(IBAction)doLookForLinks:(id)sender;
-(IBAction)doClearLinks:(id)sender;
-(void) displayLinkLines;

@end
