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
#define pathDB @"nodes.sqlite"


@interface SecondViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate> {
    sqlite3 *database;
    IBOutlet MKMapView *map;
    NSString *writableDBPath;
    
    NSMutableDictionary *resultsDictionary;
    NSMutableArray *resultsArray;
    SearchResultsCell *tmpCell;
    MKPolyline *polyline;
    
}


@property (nonatomic, retain) NSMutableArray *resultsArray;
@property (nonatomic, retain) IBOutlet SearchResultsCell *tmpCell;
@property (nonatomic, retain) MKPolyline *polyline;


-(IBAction)reloadTable:(id)sender;
-(IBAction)findNode:(id) sender;
-(IBAction)drawLine:(id)sender;

@end
