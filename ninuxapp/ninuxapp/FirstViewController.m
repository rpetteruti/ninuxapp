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
    NSArray *nibviews=[[NSBundle mainBundle] loadNibNamed:@"HUDView" owner:self options:nil];
    
    hudView =  (HUDView *) [nibviews objectAtIndex:0];
    [self.view addSubview:hudView];
    
    
    searchBar.alpha=0.0;
    hudView.alpha=0.0;
    NSLog(@"gesture recognized configured successfully");
    UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayBar:)];
    
    touchRecognizer.delegate=self;
    [self.view addGestureRecognizer:touchRecognizer];
    
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    
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
    
    
    MapVisualizationOptionsViewController *options = [[MapVisualizationOptionsViewController alloc] init];
    [options setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentModalViewController:options animated:YES];
}




- (BOOL) gestureRecognizerShouldBegin: (UIGestureRecognizer *) gestureRecognizer
{
    NSLog(@"GRShouldBegin launched");
	CGRect area= UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? CGRectMake(78, 0, 610, 955): CGRectMake(114,0,796,699);
	CGPoint location = [gestureRecognizer locationInView: self.view];
	if(CGRectContainsPoint(area, location)){// i just want to catch touches in this area
		
        
        
        if(controlsAreDisplayed){
            
            CGRect f=hudView.frame;
            
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
	{   [self displayBar:NO];
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


@end
