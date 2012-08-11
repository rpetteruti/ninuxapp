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






@implementation MapViewController
@synthesize resultsArray,tmpCell,polyline,linksArray,touchedNode,clearLinks;

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
    [clearLinks setHidden:YES];
    [self zoomOnCoord:CLLocationCoordinate2DMake(41.8934, 12.4960) zoomLevel:0.2];
    
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
	[self performSelectorInBackground:@selector(populateMapFromDB) withObject:nil];//TODO ora carica da db, dopo bisognerà chiamare populateMap
    
    
    
    
    
    
    //[map setCenterCoordinate:CLLocationCoordinate2DMake(41.8934, 12.4960) zoomLevel:13 animated:YES];
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) zoomOnCoord:(CLLocationCoordinate2D)annotationCoord zoomLevel:(float) zoomLevel{
    
    NSLog(@"ZoomLevel: %f",zoomLevel);
    if (zoomLevel<0.1)zoomLevel = zoomLevel+0.03;//evito di zoomare troppo
    
    
    MKCoordinateSpan span;
    span.latitudeDelta=zoomLevel;
    span.longitudeDelta=zoomLevel;
    
    MKCoordinateRegion region;
    region.span=span;
    region.center=annotationCoord;
    
    
    
    [map setRegion:region animated:TRUE];
    [map regionThatFits:region];
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
    
    NSString *toBeSearched= [searchBar text];
    if([toBeSearched length]>0){
        
        [self searchNodes:toBeSearched];
    }
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
	tableView.backgroundColor=[UIColor clearColor];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    /* [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchNodes:) object:searchText];
     
     NSLog(@"Search bar:%@",searchText);
     
     [self performSelector:@selector(searchNodes:) withObject:searchText afterDelay:1.5];
     */
    [resultsArray removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    
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






-(void)populateMapFromDB{
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
                
                //NSLog(@"COORDINATE NODO: %f,%f",node.coords.latitude,node.coords.longitude);
                
                annotationPoint.associatedNode=node;
                
                
                
                if ([annotationPoint.associatedNode.type isEqualToString:@"active"]) {
                   
                }
                nodeCount++;
                i++;
                
                annotationPoint.coordinate = annotationCoord;
                annotationPoint.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
                annotationPoint.subtitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)];
                
                [map addAnnotation:annotationPoint];
                //NSLog(@"added");
                
            }
        }
    }
    NSLog(@"nodi totali %i",nodeCount);
    NSLog(@"righe: %d",i);
    [self performSelectorOnMainThread:@selector(reloadMap) withObject:nil waitUntilDone:FALSE];
}






- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"SFAnnotationIdentifier"];
    if(!annotationView) {   
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"SFAnnotationIdentifier"];
        //annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeCustom];
        //[(UIButton*) annotationView.rightCalloutAccessoryView setBackgroundImage:[UIImage imageNamed: @"pulsante_links_tondo.png"] forState:UIControlStateNormal];
        
        
        UIButton *sampleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sampleButton setFrame:CGRectMake(0, 0,100,36)];
        //[sampleButton setTitle:@"Button Title" forState:UIControlStateNormal];
        //[sampleButton setFont:[UIFont boldSystemFontOfSize:20]];
       
        [sampleButton setBackgroundImage:[[UIImage imageNamed:@"links_pic.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] forState:UIControlStateNormal];
       
      
        
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_ninux_pic.png"] ];
        
        customPin *tappedPin = annotation;
        
     
                
        UIImage *pinImage = [UIImage imageNamed:@"RedMapPin.png"];
        //NSLog(@"nodo di tipo ANNOTAZIONE %@",tappedPin.associatedNode.type);
        
        if ([tappedPin.associatedNode.type isEqualToString:@"active"]) {
            
            pinImage=[UIImage imageNamed:@"marker_active.png"];
              annotationView.rightCalloutAccessoryView = sampleButton; 
        }else if ([tappedPin.associatedNode.type isEqualToString:@"potential"]) {
            pinImage=[UIImage imageNamed:@"marker_potential.png"];
        }else if ([tappedPin.associatedNode.type isEqualToString:@"hotspot"]) {
            pinImage=[UIImage imageNamed:@"marker_hotspot.png"];
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
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"Click on disclosure button in the pin");
    customPin *tappedPin = view.annotation;
    
    touchedNode= tappedPin.associatedNode;
    
    [self doLookForLinks];

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
            NSLog(@"NUMERO RIGHE: %d",i);
        }
    }
   else{
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
               
                        
            }
        }
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
    lineView.lineWidth = 3;
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











@end
