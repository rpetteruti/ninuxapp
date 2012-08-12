//
//  ArticleWebViewController.h
//  AGVVelinoiPad
//
//  Created by Mara Sorella on 18/02/11.
//  Copyright 2011 Università di Roma La Sapienza. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MBProgressHUD.h"
//#import "Reachability.h"

#define TMP NSTemporaryDirectory()

@interface ArticleWebViewController : UIViewController <UIWebViewDelegate>{

	UIWebView *webView;

	//MBProgressHUD *HUD;

		
	NSString *articleURL;


	
	//UIImageView *defaultBG;
}
@property (nonatomic,retain) IBOutlet UIWebView* webView;

//@property (nonatomic,retain) IBOutlet UIImageView *defaultBG;

-(void) setDetailItem:(NSString *)newArticleURL;
-(IBAction) doneButton;

@end
