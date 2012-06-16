//
//  FirstViewController.m
//  ninuxapp
//
//  Created by Neo on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()



@end



@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (void)viewDidLoad
{   
   [super viewDidLoad];
    
    
    
    NSLog(@"gesture recognized configured successfully");
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:pathDB];
    NSLog(@"Start populating map...");
    [map setCenterCoordinate:CLLocationCoordinate2DMake(41.8934, 12.4960)];
    //[map setCenterCoordinate:CLLocationCoordinate2DMake(41.8934, 12.4960) zoomLevel:13 animated:YES];
	[self performSelectorInBackground:@selector(populateMap) withObject:nil];
    NSArray *nibviews=[[NSBundle mainBundle] loadNibNamed:@"HUDView" owner:self options:nil];
    
    hudView =  (HUDView *) [nibviews objectAtIndex:0];
    [self.view addSubview:hudView];
    
    
    searchBar.alpha=0.0;
    hudView.alpha=0.0;



    
    
    
    
    
    
	// Do any additional setup after loading the view, typically from a nib.
    
    [self performSelector:@selector(configureGestures) withObject:nil afterDelay:1];
    
}

-(void) configureGestures{
    touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayBar:)];
    
    touchRecognizer.delegate=self;
    [self.view addGestureRecognizer:touchRecognizer]; 
    
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {   
    
    if (otherGestureRecognizer == touchRecognizer){
     
        NSLog(@"SECOND GR = CUSTOM GR");
        
        return NO;
    }
    
    return YES;
}




- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

# pragma mark - HUD Display and Handling Methods



- (IBAction) didPressOptionsButton{
    NSLog(@"Did press options button...");
    
    
    MapVisualizationViewController *options = [[MapVisualizationViewController alloc] init];
    [options setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentModalViewController:options animated:YES];
}




- (BOOL) gestureRecognizerShouldBegin: (UIGestureRecognizer *) gestureRecognizer
{
    NSLog(@"GRShouldBegin launched");
	CGRect area=CGRectMake(78,373,165,38);
	CGPoint location = [gestureRecognizer locationInView: self.view];
	if(CGRectContainsPoint(area, location)){// i just want to catch touches in this area
		
        
        
        if(controlsAreDisplayed){
            
            CGRect f=self.view.frame;
            
            if(CGRectContainsPoint(f, location)) return YES;
            else return NO;
            
        }
        
        [self willDisplayControls];
        
	}
	return NO;
}


-(void) displayBar:(BOOL) display{
    
    NSLog(@"Hud launched");
	if(display){
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		searchBar.alpha = 1.0;
        hudView.alpha=0.9;
		[UIView commitAnimations];
	}
	else{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		searchBar.alpha = 0.0;
        hudView.alpha=0.0;
		[UIView commitAnimations];
	}
	
}


- (void)showControls:(BOOL)show
{
    NSLog(@"showControls launched");
	// reset the timer
	[myTimer invalidate];
    
	myTimer = nil;
	
	// fade animate the view out of view by affecting its alpha
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.40];
	
	if (show)
	{
		// as we start the fade effect, start the timeout timer for automatically hiding HoverView
		[self displayBar:YES];
       
		searchBar.alpha = 1.0;
        hudView.alpha=0.9;
		controlsAreDisplayed=YES;
		myTimer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSDefaultRunLoopMode];
	}
	else
	{   
        
        [self displayBar:NO];
		searchBar.alpha = 0.0;
        hudView.alpha=0.0;
		controlsAreDisplayed=NO;
     
	}
	
	[UIView commitAnimations];
}

- (void)timerFired:(NSTimer *)timer
{
    
    NSLog(@"timerFired launched");
	// time has passed, hide the HoverView
	
	[self showControls: NO];
	controlsAreDisplayed=NO;
}

- (void) willDisplayControls
{
    NSLog(@"willDisplayControls launched");
	// start over - reset the timer
	[myTimer invalidate];
    
    
	
	[self showControls:(displayController.searchBar.alpha != 1.0)];
}


# pragma mark - Map and DB related functions

-(void) populateMap{
    [self createEditableCopyOfDatabaseIfNeeded];//check if i need to create a writable file of the sqlite database
    NSError* error = nil;
    NSString *rawJson = [NSString stringWithContentsOfURL:[NSURL URLWithString: @"http://map.ninux.org/nodes.json"] encoding:NSASCIIStringEncoding error:&error];
    
    NSDictionary *items = [rawJson JSONValue];
    NSArray *types = [items allKeys];//here i have all the types of the nodes
    
    int count = 0;
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
        if (TRUE) {//TODO we have to do the clean of the database only if there is a new version of the json
            sqlite3_stmt *statement;
            NSString *deleteSQL = @"DELETE FROM nodes";        
            const char *delete_stmt = [deleteSQL UTF8String];
            sqlite3_prepare_v2(database, delete_stmt, -1, &statement, NULL);
            if(sqlite3_step(statement) == SQLITE_DONE){
                NSLog(@"Delete successful nodes");
            }else{
                NSLog(@"Delete failed");
                NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));
            }
            sqlite3_finalize(statement); 
            
            //now we re-populate the database with new values from json file
            
            for (NSString *type in types) {
                NSLog(@"tipo: %@",type);
                if(![type isEqualToString:@"links"]){
                    NSDictionary *nodes = [items valueForKeyPath:type];
                    NSArray *keys = [nodes allKeys];
                    
                    for (NSString *key in keys) {
                        NSDictionary *node = [nodes objectForKey:key];
                        NSLog(@"Node name: %@\n",[node objectForKey:@"name"]);
                        NSLog(@"Node status: %@\n",[node objectForKey:@"status"]);
                        //if (![node objectForKey:@"dummy"])NSLog(@"dato non presente");
                        const char *sql_ins = "";
                        
                        sqlite3_stmt *insert_statement;
                        if (sqlite3_prepare_v2(database, sql_ins, -1, &insert_statement, NULL) != SQLITE_OK)
                        {
                            NSAssert1(0, @"Error: failed to prepare statement with message ‘%s’.", sqlite3_errmsg(database));
                        }else {
                            sqlite3_stmt *statement;
                            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO nodes (name,lat,lng,type) VALUES(\"%@\",\"%@\",\"%@\",\"%@\")",[node objectForKey:@"name"],[node objectForKey:@"lat"],[node objectForKey:@"lng"],type];
                            NSLog(@"insertSQL: %@",insertSQL);
                            const char *insert_stmt = [insertSQL UTF8String];
                            sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                            if(sqlite3_step(statement) == SQLITE_DONE){
                                NSLog(@"Insert successful node");
                            }else{
                                NSLog(@"Insert failed");
                            }
                            sqlite3_finalize(statement); 
                            
                            //NSLog(@"Node added");
                        }
                        count ++;
                    }
                }
                
            }
            
            
            
        }
        
        
        
        
        sqlite3_close(database);
        
    }else {
        sqlite3_close(database);
        NSLog(@"Error in databse connection");
    }    
    NSLog(@"Number of nodes: %i",count);
    [self populateMapFromDB];
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

-(void)populateMapFromDB{
    sqlite3_stmt *selectstmt;
	const char *sql = "select name,lat,lng,type from nodes";
    NSLog(@"writable path:%@",writableDBPath);
    if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK) {
        
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {   
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                
                CLLocationCoordinate2D annotationCoord;
                
                annotationCoord.latitude = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)]doubleValue];
                annotationCoord.longitude = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 2)]doubleValue];
                
                
                customPin *annotationPoint = [[customPin alloc] init];
                annotationPoint.type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 3)] ;
                
                annotationPoint.coordinate = annotationCoord;
                annotationPoint.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
                annotationPoint.subtitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)];
                
                [map addAnnotation:annotationPoint];
                NSLog(@"added");
                
            }
        }
    } 
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"SFAnnotationIdentifier"];
    if(!annotationView) {   
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"SFAnnotationIdentifier"];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        customPin *tappedPin = annotation;
        NSLog(@"Type: %@",tappedPin.type);
        UIImage *pinImage = [UIImage imageNamed:@"RedMapPin.png"];
        
        
        if ([tappedPin.type isEqualToString:@"active"]) {
            pinImage=[UIImage imageNamed:@"marker_active.png"];
        }else if ([tappedPin.type isEqualToString:@"potential"]) {
            pinImage=[UIImage imageNamed:@"marker_potential.png"];
        }else if ([tappedPin.type isEqualToString:@"hotspot"]) {
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

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"Click on disclosure button in the pin");
}

@end
