//
//  SecondViewController.m
//  ninuxapp
//
//  Created by Neo on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "SBJson.h"
#import "customPin.h"
#import <CoreLocation/CoreLocation.h>

#define MERCATOR_RADIUS 85445659.44705395
#define MAX_GOOGLE_LEVELS 20




@implementation MapViewController
@synthesize resultsArray,tmpCell,polyline,linksArray,touchedNode,clearLinks,hud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Ninux Map", @"Ninux Map");
        self.tabBarItem.image = [UIImage imageNamed:@"73-radar"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSettings];//
    [clearLinks setHidden:YES];
    [self zoomOnCoord:CLLocationCoordinate2DMake(41.8934, 12.4960) zoomLevel:0.2];
    
    [[NSBundle mainBundle] loadNibNamed:@"LoadingHUD" owner:self options:nil];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LoadingHUD" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    hud = [topLevelObjects objectAtIndex:0];
    
    [self.view addSubview:hud];
    
    
    resultsArray = [[NSMutableArray alloc] init];
    linksArray = [[NSMutableArray alloc] init];
    self.searchDisplayController.searchResultsTableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    
    
    
    NSLog(@"Start populating map...");
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:pathDB];
    NSLog(@"Start populating map...");
    [self zoomOnCoord:CLLocationCoordinate2DMake(41.8934, 12.4960) zoomLevel:0.2];
    //[map setCenterCoordinate:CLLocationCoordinate2DMake(41.8934, 12.4960) zoomLevel:13 animated:YES];
    
    
    CFTimeInterval now = CFAbsoluteTimeGetCurrent();
    if (( now - lastMapUpdate) <timeOutdatedMap) {
        NSLog(@"Load nodes from DB");
       // [self performSelectorInBackground:@selector(populateMapFromDB) withObject:nil];//load nodes from local db
        [self performSelectorOnMainThread:@selector(populateMapFromDB) withObject:nil waitUntilDone:NO];
        
    } else{
        NSLog(@"Load nodes from Server");
        [self performSelectorInBackground:@selector(populateMap) withObject:nil];//need to download nodes from server
        //[self performSelectorOnMainThread:@selector(populateMap) withObject:nil waitUntilDone:NO];
        lastMapUpdate = CFAbsoluteTimeGetCurrent();
        [self saveSettings];
    }
    
	
    
    
    
    
    
    //[map setCenterCoordinate:CLLocationCoordinate2DMake(41.8934, 12.4960) zoomLevel:13 animated:YES];
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) zoomOnCoord:(CLLocationCoordinate2D)annotationCoord zoomLevel:(float) zoomLevel{
    NSLog(@"Current zoomLevel: %f",[self getZoomLevel]);
    NSLog(@"ZoomLevel: %f",zoomLevel);
    if (zoomLevel<0.1)zoomLevel = zoomLevel+0.03;//evito di zoomare troppo
    //if([self getZoomLevel] > 10.0 ) return;
    
    MKCoordinateSpan span;
    span.latitudeDelta=zoomLevel;
    span.longitudeDelta=zoomLevel;
    
    MKCoordinateRegion region;
    region.span=span;
    region.center=annotationCoord;
    
    
    
    [map setRegion:region animated:TRUE];
    [map regionThatFits:region];
    NSLog(@"Final zoomLevel: %f",[self getZoomLevel]);
}



- (double)getZoomLevel
{
    CLLocationDegrees longitudeDelta = map.region.span.longitudeDelta;
    CGFloat mapWidthInPixels = self.view.bounds.size.width;
    double zoomScale = longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * mapWidthInPixels);
    double zoomer = MAX_GOOGLE_LEVELS - log2( zoomScale );
    if ( zoomer < 0 ) zoomer = 0;
    //  zoomer = round(zoomer);
    return zoomer;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


# pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@" numberofrows: %d",[resultsArray count]);
    return [resultsArray count];
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    
    SearchResultsCell *cell = (SearchResultsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        
        [[NSBundle mainBundle] loadNibNamed:@"SearchResultsCell" owner:self options:nil];
        cell=tmpCell;
        //NSLog(@"cell: %@",cell);
        tmpCell=nil;
    }
    
    MapNode *node =[resultsArray objectAtIndex:indexPath.row];
    
    
    [cell setTag:indexPath.row];
    
    
    NSLog(@"tag bottone: %d,riga, %d",cell.tag,indexPath.row);
    //[cell.goToNode addTarget:self action:@selector(findNode:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    if ([node.type isEqualToString:@"active"]) {
        [[cell nodeTypePlaceholder] setImage:[UIImage imageNamed:@"marker_active.png"]];
    }else if ([node.type isEqualToString:@"potential"]) {
        [[cell nodeTypePlaceholder] setImage:[UIImage imageNamed:@"marker_potential.png"]];
    }else if ([node.type isEqualToString:@"hotspot"]) {
        [[cell nodeTypePlaceholder] setImage:[UIImage imageNamed:@"marker_hotspot.png"]];
    }
    
    [cell nodename].text=node.nodeName;
    
    return cell;
    
}





-(void) searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    NSLog(@"Called searchBarTextDidEndEditing");
    // [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchNodes:) object:searchText];
    
  /*  NSString *toBeSearched= [searchBar text];
    if([toBeSearched length]>0){
        
        [self searchNodes:toBeSearched];
    }*/
    //[self performSelector:@selector(searchNodes:) withObject:[searchBar text] afterDelay:0.0];
    
    
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"called shouldreload: searchstring");
    // Return YES to cause the search result table view to be reloaded.
    
    return NO;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSLog(@"called shouldreload: scope");
    
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}


-(IBAction)reloadTable:(id)sender{
    [self.searchDisplayController.searchResultsTableView reloadData];
}


-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    //serve per non far cambiare la grafica della tableview quando l'utente clicca su cancel o su x
    tableView.separatorStyle= UITableViewCellSeparatorStyleNone;
	tableView.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];

    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchNodes:) object:searchText];
    [resultsArray removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
     
     
     NSLog(@"Search bar:%@",searchText);
     
     [self performSelector:@selector(searchNodes:) withObject:searchText afterDelay:0];
     
 
    
    
}

# pragma mark - NSSearchResults Methods



-(void)searchNodes:(NSString *)searchText{
    sqlite3_stmt *selectstmt;
	//const char *sql = "select name from nodes";
    NSString *sqlSearch = [NSString stringWithFormat:@"SELECT name, type,lat,lng FROM nodes WHERE name LIKE '%%%@%%'",searchText];
    
    
    NSLog(@"Search query:%@",sqlSearch);
    const char *sql = [sqlSearch UTF8String];
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
        
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                
                NSString *nodeName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
                
                
                
                
                MapNode *node = [[MapNode alloc] init];
                node.nodeName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt,0)];
                node.type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt,1)];
                CLLocationCoordinate2D coordinates;
                
                coordinates.latitude = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 2)]doubleValue];
                coordinates.longitude = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 3)]doubleValue];
                node.coords=coordinates;
                [resultsArray addObject:node];
                
                NSLog(@"Node found:%@, lat: %f, lon: %f",nodeName,node.coords.latitude,node.coords.longitude);
                
                
            }
        }
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}


-(void) isInvolvedInLinks: (MapNode*) node{
    int i=0;
    sqlite3_stmt *selectstmt;
    CLLocationCoordinate2D coords = node.coords;
    
    NSString *sqlSearch = [NSString stringWithFormat:@"SELECT from_lat,from_lng FROM links WHERE to_lat = '%f' AND to_lng = '%f'",coords.latitude,coords.longitude];
    //NSLog(@"-> Checking if node %@ is involved in links....",node.nodeName);
    const char *sql = [sqlSearch UTF8String];
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
        
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                
                
               
                
                i++;
            }
            
        }
    }
    if(i==0){
        sqlSearch = [NSString stringWithFormat:@"SELECT to_lat,to_lng FROM links WHERE from_lat = '%f' AND from_lng = '%f'",coords.latitude,coords.longitude];
        NSLog(@"Search query:%@",sqlSearch);
        sql = [sqlSearch UTF8String];
        if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
            
            if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
                
                while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                    
                 
                    
                    i++;
                }
                //NSLog(@"NUMERO RIGHE SECONDA QUERY: %d",i);
            }
        }
    }
    if (i==0) node.isInvolvedInLinks=NO;
    else node.isInvolvedInLinks=YES;
}



-(void)populateMapFromDB{
    
    //initializing hud
    
    [self.view addSubview:hud];
    
    
    int i=0;
    sqlite3_stmt *selectstmt;
	const char *sql = "select name,lat,lng,type from nodes";
    NSLog(@"writable path:%@",writableDBPath);
    int nodeCount=0;
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
        
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                
                //NSLog(@"latitudine come esce dal db: %@",[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)]);
                CLLocationCoordinate2D annotationCoord;
                
                annotationCoord.latitude = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)]floatValue];
                annotationCoord.longitude = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 2)]floatValue];
                
                
                customPin *annotationPoint = [[customPin alloc] init];
                
                
                
                MapNode *node = [[MapNode alloc] init];
                node.type=[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 3)];
                node.nodeName= annotationPoint.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
                node.coords=annotationCoord;
                
                //check involved in links
                if(![node.type isEqualToString:@"potential"]) 
                [self performSelectorInBackground:@selector(isInvolvedInLinks:) withObject:node];
               
                
                //NSLog(@"COORDINATE NODO: %f,%f",node.coords.latitude,node.coords.longitude);
                
                annotationPoint.associatedNode=node;
                
                
                
                if ([annotationPoint.associatedNode.type isEqualToString:@"active"]) {
                    
                }
                nodeCount++;
                i++;
                
                annotationPoint.coordinate = annotationCoord;
                annotationPoint.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
                
                NSString *tipo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 3)];
                
                if([tipo isEqualToString:@"active"]) annotationPoint.subtitle = @"attivo";
                else if([tipo isEqualToString:@"hotspot"]) annotationPoint.subtitle = @"hotspot";
                else annotationPoint.subtitle = @"potenziale";
                
                
                //[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)];
                
                [map addAnnotation:annotationPoint];
                //NSLog(@"added");
                
            }
        }
    }
    NSLog(@"nodi totali %i",nodeCount);
    NSLog(@"righe: %d",i);
    [self performSelectorOnMainThread:@selector(reloadMap) withObject:nil waitUntilDone:FALSE];
}



-(void) populateMap{
    [self.view addSubview:hud];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self createEditableCopyOfDatabaseIfNeeded];//check if i need to create a writable file of the sqlite database
    NSError* error = nil;
    NSString *rawJson = [NSString stringWithContentsOfURL:[NSURL URLWithString: @"http://map.ninux.org/nodes.json"] encoding:NSASCIIStringEncoding error:&error];
    
    NSDictionary *items = [rawJson JSONValue];
    NSArray *types = [items allKeys];//here i have all the types of the nodes
    
    
    int numVolte=0;
    
    
    int count = 0;
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        NSString *deleteSQL = @"DELETE FROM nodes";
        const char *delete_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, delete_stmt, -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"Delete successful nodes");
        }else{
            NSLog(@"Delete failed");
            //NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        
        deleteSQL = @"DELETE FROM links";
        delete_stmt = [deleteSQL UTF8String];
        
        sqlite3_prepare_v2(database, delete_stmt, -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"Delete successful links");
        }else{
            NSLog(@"Delete links failed");
            //NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        
        //now we re-populate the database with new values from json file
        
        for (NSString *type in types) {
            
            if(![type isEqualToString:@"links"]){
                NSDictionary *nodes = [items valueForKeyPath:type];
                NSArray *keys = [nodes allKeys];
                
                for (NSString *key in keys) {
                    NSDictionary *node = [nodes objectForKey:key];
                    //NSLog(@"Node name: %@\n",[node objectForKey:@"name"]);
                    // NSLog(@"Node status: %@\n",[node objectForKey:@"status"]);
                    //if (![node objectForKey:@"dummy"])NSLog(@"dato non presente");
                    const char *sql_ins = "";
                    
                    sqlite3_stmt *insert_statement;
                    if (sqlite3_prepare_v2(database, sql_ins, -1, &insert_statement, NULL) != SQLITE_OK)
                    {
                        NSAssert1(0, @"Error: failed to prepare statement with message ‘%s’.", sqlite3_errmsg(database));
                    }else {
                        sqlite3_stmt *statement;
                        
                        float latitudine = [[node objectForKey:@"lat"]floatValue];
                        float longitudine = [[node objectForKey:@"lng"]floatValue];
                        
                        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO nodes (name,lat,lng,type) VALUES(\"%@\",\"%f\",\"%f\",\"%@\")",[node objectForKey:@"name"],latitudine,longitudine,type];
                        //NSLog(@"insertSQL: %@",insertSQL);
                        const char *insert_stmt = [insertSQL UTF8String];
                        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                        if(sqlite3_step(statement) == SQLITE_DONE){
                            //NSLog(@"Insert successful node");
                        }else{
                            NSLog(@"Insert failed");
                        }
                        sqlite3_finalize(statement);
                        
                        //NSLog(@"Node added");
                    }
                    count ++;
                }
            }
            else if([type isEqualToString:@"links"]){
                
                NSArray *links = [items valueForKeyPath:type];
                NSLog(@"TEST: %@ %i",[links objectAtIndex:0],[links count]);
                // NSDictionary *link=[links objectAtIndex:0];
                // NSLog(@"TEST 2: %@",[[links objectAtIndex:0] objectForKey:@"etx"]);
                //NSArray *keys = [links allKeys];
                //NSLog(@"TEST 3: %@",[link objectForKey:@"etx"]);
                for (NSDictionary *link in links) {
                    // NSDictionary *link = [links objectForKey:key];
                    float f_latitudine = [[link objectForKey:@"from_lat"]floatValue];
                    float f_longitudine = [[link objectForKey:@"from_lng"]floatValue];
                    float t_latitudine = [[link objectForKey:@"to_lat"]floatValue];
                    float t_longitudine = [[link objectForKey:@"to_lng"]floatValue];
                    
                    
                    const char *sql_ins = "";
                    
                    sqlite3_stmt *insert_statement;
                    if (sqlite3_prepare_v2(database, sql_ins, -1, &insert_statement, NULL) != SQLITE_OK)
                    {
                        NSAssert1(0, @"Error: failed to prepare statement with message ‘%s’.", sqlite3_errmsg(database));
                    }else {
                        sqlite3_stmt *statement;
                        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO links (to_lat,from_lng,from_lat,to_lng,etx) VALUES(\"%f\",\"%f\",\"%f\",\"%f\",\"%@\")",t_latitudine,f_longitudine,f_latitudine,t_longitudine,[link objectForKey:@"etx"]];
                        NSLog(@"insertSQL: %@",insertSQL);
                        const char *insert_stmt = [insertSQL UTF8String];
                        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                        if(sqlite3_step(statement) == SQLITE_DONE){
                            NSLog(@"Insert successful link");
                            numVolte++;
                        }else{
                            NSLog(@"Insert link failed");
                        }
                        sqlite3_finalize(statement);
                        
                    }
                    count ++;
                }
            }
            
            
            
        }
        
        
        sqlite3_close(database);
        
    }else {
        sqlite3_close(database);
        NSLog(@"Error in databse connection");
    }
    NSLog(@"Number of nodes: %i",count);
    NSLog(@"VOLTE: %d",numVolte);
    [self performSelectorOnMainThread:@selector(populateMapFromDB) withObject:nil waitUntilDone:YES];
}

- (void)createEditableCopyOfDatabaseIfNeeded
{
	// First, test for existence.
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	success = [fileManager fileExistsAtPath:writableDBPath];
	if (success) return;
	// The writable database does not exist, so copy the default to the appropriate location.
	[fileManager removeItemAtPath:writableDBPath error:&error];
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:pathDB];
	success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	if (!success) {
		NSAssert1(0, @"Failed to create writable database file with message ‘%@’.", [error localizedDescription]);
		//NSLog(@"Failed to create writable database file with message ‘%@’.", [error localizedDescription]);
	}
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    customPin *tappedPin = annotation;
    NSString *nodeName = tappedPin.associatedNode.nodeName;
    //NSLog(@"Visualizzo annotazione: %@",nodeName);
    
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:nodeName];
    if(!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nodeName];
        //annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeCustom];
        //[(UIButton*) annotationView.rightCalloutAccessoryView setBackgroundImage:[UIImage imageNamed: @"pulsante_links_tondo.png"] forState:UIControlStateNormal];
        
        
        UIButton *sampleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sampleButton setFrame:CGRectMake(0, 0,70,42)];
        //[sampleButton setTitle:@"Button Title" forState:UIControlStateNormal];
        //[sampleButton setFont:[UIFont boldSystemFontOfSize:20]];
        
        [sampleButton setBackgroundImage:[[UIImage imageNamed:@"linksbutton.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] forState:UIControlStateNormal];
        
        
        
        
        
        customPin *tappedPin = annotation;
        
        
        
        UIImage *pinImage = [UIImage imageNamed:@"RedMapPin.png"];
        //NSLog(@"nodo di tipo ANNOTAZIONE %@",tappedPin.associatedNode.type);
        
        if ([tappedPin.associatedNode.type isEqualToString:@"active"]) {
            annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logoact.png"] ];
            pinImage=[UIImage imageNamed:@"marker_a.png"];
            if (tappedPin.associatedNode.isInvolvedInLinks)
            annotationView.rightCalloutAccessoryView = sampleButton;
            
        }else if ([tappedPin.associatedNode.type isEqualToString:@"potential"]) {
             annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logopot.png"] ];
            pinImage=[UIImage imageNamed:@"marker_p.png"];
        }else if ([tappedPin.associatedNode.type isEqualToString:@"hotspot"]) {
             annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logohot.png"] ];
            pinImage=[UIImage imageNamed:@"marker_h.png"];
            if (tappedPin.associatedNode.isInvolvedInLinks)
            annotationView.rightCalloutAccessoryView = sampleButton;
        }
        
        annotationView.image = pinImage;
    }else {
        annotationView.annotation = annotation;
    }
    
    
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    
    
    
    return annotationView;
}


-(void) reloadMap
{
    [map setRegion:map.region animated:TRUE];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [hud removeFromSuperview];
    [map setNeedsLayout];
    [map setNeedsDisplay];
    [map reloadInputViews];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"Click on disclosure button in the pin");
    customPin *tappedPin = view.annotation;
    
    touchedNode= tappedPin.associatedNode;
    NSLog(@" NODO DI TIPO: %@",tappedPin.associatedNode.type);
    [self doLookForLinks];
    
}


-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    customPin *tappedPin = view.annotation;
    NSLog(@" NODO DI TIPO: %@",tappedPin.associatedNode.type);
}

-(IBAction)findNode:(id) sender{
    
    UIButton *buttonPressed = (UIButton *) sender;
    int row = [buttonPressed superview].tag;
    
    MapNode *node =[resultsArray objectAtIndex:row];
    
    NSArray *arr = [map annotations];
    NSLog(@"NUMERO DI ANNOTAZIONI: %d",[arr count]);
    for(int i=0; i<[arr count]; i++)
    {
        MKPointAnnotation *ann = [arr objectAtIndex:i];
        if([ann.title isEqualToString:node.nodeName])
        {
            //dismiss searchviewcontroller
            [self.searchDisplayController setActive:NO];
            [self zoomOnCoord:ann.coordinate zoomLevel:0.0];
            [map selectAnnotation:ann animated:YES];
            
            return;
        }
    }
    
    
    
}


-(IBAction)doLookForLinks{
    //UIButton *buttonPressed = (UIButton *) sender;
    //int row = [buttonPressed superview].tag;
    
    //MapNode *node =[resultsArray objectAtIndex:row];
    //NSLog(@"node.name: %@ , latitanji:%f longitanji: %f",node.nodeName,node.coords.latitude,node.coords.longitude);
    
    
    [self findLinksFromCoordinate:touchedNode.coords];
    
}

-(void)findLinksFromCoordinate: (CLLocationCoordinate2D) coord {
    [linksArray removeAllObjects];
    //to_lat,from_lng,from_lat,to_lng,etx
    NSLog(@"latitanji:%f longitanji: %f",coord.latitude,coord.longitude);
    int i =0;
    float lati=coord.latitude;
    float longi=coord.longitude;
    sqlite3_stmt *selectstmt;
	//const char *sql = "select name from nodes";
    
    
    
    
    NSString *sqlSearch = [NSString stringWithFormat:@"SELECT from_lat,from_lng FROM links WHERE to_lat = '%f' AND to_lng = '%f'",lati,longi];//,coord.latitude]; //AND to_lng = '%%%f%%'",coord.latitude,coord.longitude];//AND from_lng LIKE '%%%@%%'",latitudine,longitudine];
    NSLog(@"Search query:%@",sqlSearch);
    const char *sql = [sqlSearch UTF8String];
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
        
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                
                
                CLLocationCoordinate2D* coords = malloc(2 * sizeof(CLLocationCoordinate2D));
                
                CLLocationDegrees latdeg = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)] floatValue];
                CLLocationDegrees londeg = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)] floatValue];
                
                
                coords[0]=CLLocationCoordinate2DMake(latdeg, londeg);
                coords[1]=coord;
                
                MKPolyline *linkLine = [MKPolyline polylineWithCoordinates:coords count:2];
                
                [linksArray addObject:linkLine];
                //NSLog(@"ARRAY DEI LINK:\n %@,%f,%f",linksArray,latdeg,londeg);
                NSLog(@"Disegno la linea: ( %f,%f : %f,%f )",lati,longi,latdeg,londeg);
                //[map setNeedsDisplay];
                
                
                i++;
            }
            //NSLog(@"NUMERO RIGHE: %d",i);
        }
    }
   
        sqlSearch = [NSString stringWithFormat:@"SELECT to_lat,to_lng FROM links WHERE from_lat = '%f' AND from_lng = '%f'",lati,longi];
        NSLog(@"Search query:%@",sqlSearch);
        sql = [sqlSearch UTF8String];
        if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
            
            if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
                
                while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                    
                    CLLocationCoordinate2D* coords = malloc(2 * sizeof(CLLocationCoordinate2D));
                    
                    CLLocationDegrees latdeg = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)] floatValue];
                    CLLocationDegrees londeg = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)] floatValue];
                    
                    
                    coords[0]=CLLocationCoordinate2DMake(latdeg, londeg);
                    coords[1]=coord;
                    
                    MKPolyline *linkLine = [MKPolyline polylineWithCoordinates:coords count:2];
                    
                    [linksArray addObject:linkLine];
                    NSLog(@"ARRAY DEI LINK:\n %@",linksArray);
                    
                    NSLog(@"Disegno la linea: ( %f,%f : %f,%f )",lati,longi,latdeg,londeg);
                    //[map setNeedsDisplay];
                    
                    
                    i++;
                }
                //NSLog(@"NUMERO RIGHE SECONDA QUERY: %d",i);
            }
        }
    
    
    
    [self zoomOnCoord:coord zoomLevel:0.0];
    [self displayLinkLines];
}


- (IBAction)doClearLinks:(id)sender  {
    [map removeOverlays:map.overlays];
    [linksArray removeAllObjects];
    [clearLinks setHidden:YES];
    [map deselectAnnotation:[map.selectedAnnotations objectAtIndex:0] animated:YES];
    [self zoomOnCoord:CLLocationCoordinate2DMake(41.8934, 12.4960) zoomLevel:0.1];
    
    
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id < MKOverlay >)overlay{
    NSLog(@"TITOLO LINEA: %@",overlay.title);
    int i = [overlay.title intValue];
    
    
    MKPolyline *poly = (MKPolyline*) [linksArray objectAtIndex:i];
    
    MKPolylineView* lineView = [[MKPolylineView alloc] initWithPolyline:poly];
    lineView.fillColor = [UIColor greenColor];
    lineView.strokeColor = [UIColor greenColor];
    lineView.lineWidth = 6;
    return lineView;
}


-(void) displayLinkLines{
    [self.searchDisplayController setActive:NO];
    
    
    
    int i=0;
    for(MKPolyline *poly in linksArray){
        poly.title=[NSString stringWithFormat:@"%d",i];
        [map addOverlay:poly];
        i++;
        
    }
    
    
    [map setNeedsDisplay];
    [clearLinks setHidden: NO];
    
    
}


-(IBAction)drawLine:(id)sender{
    
    
    UIButton *buttonPressed = (UIButton *) sender;
    int row = [buttonPressed superview].tag;
    
    MapNode *node =[resultsArray objectAtIndex:row];
    
    NSArray *arr = [map annotations];
    
    CLLocationCoordinate2D* coords = malloc(2 * sizeof(CLLocationCoordinate2D));
    
    
    for(int i=0; i<[arr count]; i++)
    {
        MKPointAnnotation *ann = [arr objectAtIndex:i];
        if([ann.title isEqualToString:node.nodeName])
        {
            //dismiss searchviewcontroller
            [self.searchDisplayController setActive:NO];
            //[self zoomOnCoord:ann.coordinate zoomLevel:0.0];
            //[map selectAnnotation:ann animated:YES];
            
            coords[0]=ann.coordinate;
            
            MKPointAnnotation *fixedAnn = [arr objectAtIndex:0];
            
            customPin *pin= (customPin*) fixedAnn;
            MapNode *node = pin.associatedNode;
            
            
            NSLog(@"COORDINATA FISSA: %@",node.nodeName);
            coords[1]=fixedAnn.coordinate;
            
            
            
            
            
            
            self.polyline = [MKPolyline polylineWithCoordinates:coords count:2];
            
            
            
            
            
            [map addOverlay:polyline];
            [map setNeedsDisplay];
            return;
        }
    }
    
    
    
    
    
    
    
}




-(IBAction)doCurl{
    MapOptionsViewController *opt = [[MapOptionsViewController alloc]initWithNibName:@"MapOptionsViewController" bundle:nil];
    opt.delegate = self;
    opt.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    opt.hidesBottomBarWhenPushed=YES;
    
   
    MKMapType type = [map mapType];
    
    if (type == MKMapTypeStandard) opt.state=0;
    else if (type == MKMapTypeSatellite) opt.state=1;
    else opt.state=2;
    
    [self presentModalViewController:opt animated:YES];
}


-(void)loadSettings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *lastMapUpdate_time = [prefs objectForKey:@"lastMapUpdate"];
	if (lastMapUpdate_time != nil){
		
		lastMapUpdate = (double)[prefs doubleForKey:@"lastMapUpdate"];//load when i did the last update of the map
		NSLog(@"load last update");
	}
	else {
		
		lastMapUpdate = timeOutdatedMap+1;//if is the first time that i check it this must be set to an outdated time.
        [self saveSettings];
        NSLog(@"never saved last update");
		
    }
}

-(void) setMapType:(NSUInteger)type{
    NSLog(@"Changing map type..");
    [map setMapType:type];
    [map setNeedsLayout];
}

-(void)saveSettings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setDouble:lastMapUpdate forKey:@"lastMapUpdate"];
	[prefs synchronize];
}






@end
