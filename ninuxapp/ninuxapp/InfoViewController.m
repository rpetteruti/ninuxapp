//
//  InfoViewController.m


#import "InfoViewController.h"


@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Info", @"info");
        self.tabBarItem.image = [UIImage imageNamed:@"e-mail"];
    }
    return self;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction) curlDownTapped{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {

}

-(IBAction) sendMail{
 
    NSString* mailString= @"mailto:?to=contatti@ninux.org&subject=NinuxApp:%20richesta%20supporto";
    NSURL *url = [NSURL URLWithString:mailString];
    [[UIApplication sharedApplication] openURL:url];
}




    


-(IBAction) goToWeb{
    NSLog(@"web!");
    NSString* mailString= @"http://wiki.ninux.org";
    NSURL *url = [NSURL URLWithString:mailString];
    [[UIApplication sharedApplication] openURL:url];
}

@end
