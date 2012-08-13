    //
//  ArticleWebViewController.m
//  AGVVelinoiPad
//
//  Created by Mara Sorella on 18/02/11.
//  Copyright 2011 Università di Roma La Sapienza. All rights reserved.
//

#import "ArticleWebViewController.h"


@implementation ArticleWebViewController
@synthesize webView;
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.webView setDelegate:self];
	webView.scalesPageToFit = YES;  
	
	
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:articleURL]]];
	
    // Add HUD to screen
    
	
	
}




	

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}






- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) setDetailItem:(NSString *)newArticleURL{
	
	articleURL = newArticleURL;
		
}

-(IBAction) doneButton{
	
	[self dismissModalViewControllerAnimated:YES];
	
}
@end
