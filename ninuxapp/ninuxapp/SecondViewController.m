//
//  SecondViewController.m
//  ninuxapp
//
//  Created by Neo on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"
#import "SBJson.h"
#import "customPin.h"






@implementation SecondViewController
@synthesize resultsArray,tmpCell,polyline;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Impostazioni", @"Impostazioni");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self zoomOnCoord:CLLocationCoordinate2DMake(41.8934, 12.4960) zoomLevel:0.2];
    resultsArray = [[NSMutableArray alloc] init];
    self.searchDisplayController.searchResultsTableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor clearColor];
    
    
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
    NSLog(@" numberofrows: %d",[resultsArray count]);
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
    [cell.goToNode addTarget:self action:@selector(gotoNode:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
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
    NSString *sqlSearch = [NSString stringWithFormat:@"SELECT name, type FROM nodes WHERE name LIKE '%%%@%%'",searchText];
    NSLog(@"Search query:%@",sqlSearch);
    const char *sql = [sqlSearch UTF8String];
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
        
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {   
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                
                NSString *nodeName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];     
                
                
                
                
                NSLog(@"Node found:%@",nodeName);
                MapNode *node = [[MapNode alloc] init];
                node.nodeName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt,0)];
                node.type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt,1)];
                
                [resultsArray addObject:node];       
                NSLog(@"RESULTSARRAY:\n %@",resultsArray);
                
                
            }
        }
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}

-(void)populateMapFromDB{
    sqlite3_stmt *selectstmt;
	const char *sql = "select name,lat,lng,type from nodes";
    NSLog(@"writable path:%@",writableDBPath);
    int nodeCount=0;
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
        
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {   
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                
                CLLocationCoordinate2D annotationCoord;
                
                annotationCoord.latitude = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)]doubleValue];
                annotationCoord.longitude = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 2)]doubleValue];
                
                
                customPin *annotationPoint = [[customPin alloc] init];
                
                
                
                MapNode *node = [[MapNode alloc] init];
                node.type=[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 3)];
                node.nodeName= annotationPoint.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
                
                
                annotationPoint.associatedNode=node;
                
                
                
                if ([annotationPoint.associatedNode.type isEqualToString:@"active"]) {
                    nodeCount++;
                }
                
                
                annotationPoint.coordinate = annotationCoord;
                annotationPoint.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
                annotationPoint.subtitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)];
                
                [map addAnnotation:annotationPoint];
                //NSLog(@"added");
                
            }
        }
    }
    NSLog(@"nodi totali %i",nodeCount);
    [self performSelectorOnMainThread:@selector(reloadMap) withObject:nil waitUntilDone:FALSE];
}






- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"SFAnnotationIdentifier"];
    if(!annotationView) {   
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"SFAnnotationIdentifier"];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        customPin *tappedPin = annotation;
        
        UIImage *pinImage = [UIImage imageNamed:@"RedMapPin.png"];
        NSLog(@"nodo di tipo %@",tappedPin.associatedNode.type);
        
        if ([tappedPin.associatedNode.type isEqualToString:@"active"]) {
            
            pinImage=[UIImage imageNamed:@"marker_active.png"];
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
}


-(IBAction)goToNode:(id) sender{
    
    UIButton *buttonPressed = (UIButton *) sender;
    int row = [buttonPressed superview].tag;
    
    MapNode *node =[resultsArray objectAtIndex:row];
    
    NSArray *arr = [map annotations];
    
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



- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id < MKOverlay >)overlay{
    
    
    
    MKPolylineView* lineView = [[MKPolylineView alloc] initWithPolyline:self.polyline] ;
    lineView.fillColor = [UIColor greenColor];
    lineView.strokeColor = [UIColor greenColor];
    lineView.lineWidth = 3;
    return lineView;
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
