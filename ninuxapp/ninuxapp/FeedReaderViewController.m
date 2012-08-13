//
//  FirstViewController.m
//  ninuxapp
//
//  Created by Neo on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedReaderViewController.h"

@interface FeedReaderViewController ()



@end



@implementation FeedReaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Notizie", @"Notizie");
        self.tabBarItem.image = [UIImage imageNamed:@"news"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    URLToOpenString =@"http://blog.ninux.org/feed/";
    currentPage = 0;
	//NSLog(@"Sei nel tab: %@",indiceTab);
	loading=NO;
	loadingArticle=NO;
    
	UIButton* modalViewButton = [UIButton buttonWithType: UIButtonTypeCustom];
	modalViewButton.bounds = CGRectMake(0, 0, 65.0, 30.0);
	[modalViewButton setImage:[UIImage imageNamed:@"refreshLittle.png"] forState:UIControlStateNormal];
	[modalViewButton addTarget:self action:@selector(updateFeed) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithCustomView:modalViewButton];
	
	articlesTable.hidden=YES;
	
    
	
	[[self navigationItem] setRightBarButtonItem: updateButton];
	
	stories = [[NSMutableArray alloc] init];
    
	articlesTable.separatorStyle=UITableViewCellSeparatorStyleNone;
	self.navigationItem.titleView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ultimora.png"]];
	
	
	
	
	
	
    // Add HUD to screen
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	
	if ([stories count] == 0) {
		
		NSLog(@"URLToOpenString: %@",URLToOpenString);
		[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:URLToOpenString];
		
	}
    
}

- (void)updateFeed{
	// Add HUD to screen
	if ([self notConnected]) {
		return;
	}
	if(loading || loadingArticle) return;
	loading=YES;
	
	[articlesTable setUserInteractionEnabled:NO];
	[stories removeAllObjects];
	currentPage = 0;
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSLog(@"Aggiorno il feed corrente");
	[self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:URLToOpenString];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [stories count];
	
    
}

-(void)tableViewWillSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
	loadingArticle=YES;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	//if(indexPath.row==[stories count] ) return 40.0;//readmore notiziario
	 return 95.0;
	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (stories == nil || [stories count]==0) {
		UITableViewCell *cell = [[UITableViewCell alloc] init];
		return cell;
	}
    
    static NSString *CellIdentifier = @"MyIdentifier";
	int storyIndex = indexPath.row;//[indexPath indexAtPosition: [indexPath length] - 1];
	
    ArticleCell *cell = (ArticleCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		
		[[NSBundle mainBundle] loadNibNamed:@"ArticleCell" owner:self options:nil];
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ArticleCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
		//cell=tmpCell;
		//self.tmpCell=nil;
		
        
        cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
        NSString *text=@" ";
        
        NSString *data = [[stories objectAtIndex: storyIndex] objectForKey: @"data"];
        /*NSLog(@"data: %@",data);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //[formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"]; 
        NSDate *date = [formatter dateFromString:data];
        NSLog(@"data: %@",date);
        data = [formatter stringFromDate:date];
        */
        cell.titleLabel.text=[NSString stringWithFormat:@"%@",[[stories objectAtIndex: storyIndex] objectForKey: @"titolo"]];
		text=[NSString stringWithFormat:@"Autore: %@\n%@",[[stories objectAtIndex: storyIndex] objectForKey: @"testo"],data];
        cell.textPreview.text=text;
		[cell.textPreview alignTop];
    }
    [cell setLabelFullSize];
    
    if(indexPath.row %2!=0 ) {
		
		
		UIView* backgroundView = [ [ UIView alloc ] initWithFrame:CGRectZero ] ;
		//backgroundView.backgroundColor = [UIColor lightGrayColor];
        backgroundView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:0.9];
		cell.backgroundView = backgroundView;
		
	}
	
	
	if(cell == nil)NSLog(@"The cell is nil!");
	
	return cell;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{
	NSLog(@"found file and started parsing");
	
}

- (void)parseXMLFileAtURL:(NSString *)URL
{
	
	
    loading=YES;
	
    //you must then convert the path to a proper NSURL or it won't work
    NSURL *xmlURL = [NSURL URLWithString:URL];
	
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [rssParser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
	
    [rssParser parse];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[articlesTable reloadData];
	[articlesTable setHidden:NO];
	[articlesTable setUserInteractionEnabled:YES];
	loading=FALSE;
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	NSString * errorString = [NSString stringWithFormat:@"Impossibile ottenere le notizie. Riprovare piu tardi. (Codice errore %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Errore di caricamento" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
	currentElement = [elementName copy];
	currentImageUrl = [[NSMutableString alloc] init];
	if ([elementName isEqualToString:@"item"]) {
		// clear out our story item caches...
		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
		currentSummary = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
		currentImageUrl = [[NSMutableString alloc] init];
		currentLuogoOra = [[NSMutableString alloc] init];
	}else if ([elementName isEqualToString:@"notiziario"]) {
		maxPage = [[NSMutableString alloc] init];
        
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	
	if ([elementName isEqualToString:@"item"]) {
		// save values to an item, then store that item into the array...
		[item setObject:currentTitle forKey:@"titolo"];
		[item setObject:currentLink forKey:@"link"];
		[item setObject:currentSummary forKey:@"testo"];
		[item setObject:currentDate forKey:@"data"];
		
		//[item setObject:currentImageUrl forKey:@"foto"];
		
		//[item setObject:currentLuogoOra forKey:@"luogoOra"];
		
		
		
		//NSLog(@"Oggetto Url immagine: %@",currentImageUrl);
		NSLog(@"Title: %@",currentTitle);
		
		
		//IMAGE CACHING
		
		
		
		[stories addObject:[item copy]];
		
		//NSLog(@"adding story: %@", [item valueForKey:@"foto"]);
	}
	
	
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"link"]) {
		[currentLink appendString:string];
	} else if ([currentElement isEqualToString:@"dc:creator"]) {
		[currentSummary appendString:string];
	} else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];
	} else if ([currentElement isEqualToString:@"foto"]){
		
		[currentImageUrl appendString:string];
		currentImageUrl=(NSMutableString*)[currentImageUrl stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		
		
		
	}else if ([currentElement isEqualToString:@"pageMax"]){
		[maxPage appendString:string];
		
	}else if ([currentElement isEqualToString:@"luogoOra"]){
		[currentLuogoOra appendString:string];
		
	}
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
	
	NSLog(@"all done!");
	NSLog(@"stories array has %d items", [stories count]);
	
	loading = NO;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic
    NSLog(@"loading article");
    
    loadingArticle = YES;
    
    
    
    
    NSString * storyLink = [[stories objectAtIndex: indexPath.row] objectForKey: @"link"];
    
    // clean up the link - get rid of spaces, returns, and tabs...
    storyLink = [storyLink stringByReplacingOccurrencesOfString:@" " withString:@""];
    storyLink = [storyLink stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    storyLink = [storyLink stringByReplacingOccurrencesOfString:@"	" withString:@""];
    
    ArticleWebViewController *artvc = (ArticleWebViewController *)[[ArticleWebViewController alloc] initWithNibName:@"ArticleWebViewController" bundle:nil];

    
    
    [artvc setDetailItem:storyLink];
    //[artvc setArticleCategory:[indiceTab copy]];
    [self.navigationController pushViewController:artvc animated:YES];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Indietro" style: UIBarButtonItemStyleBordered target: nil action: nil];
    
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    
    
    
        
    
    
	artvc.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    
	[self presentModalViewController:artvc animated:YES];
    
    

    loadingArticle = NO;
    
    
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




@end
