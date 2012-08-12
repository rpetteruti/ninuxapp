//
//  FirstViewController.h
//  ninuxapp
//
//  Created by Neo on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleCell.h"
//#import "MBProgressHUD.h"
//#import "ReadMoreCell.h"
//#import "FeaturedCell.h"
//#import "Reachability.h"
#import "UILabel+VerticalAlign.h"
#import "ArticleWebViewController.h"





@interface FeedReaderViewController : UIViewController <NSXMLParserDelegate>{
    
	
	IBOutlet UITableView * newsTable;
	
	UIActivityIndicatorView * activityIndicator;
	
	CGSize cellSize;
	
	NSXMLParser * rssParser;
	
	NSMutableArray * stories;
	
	IBOutlet ArticleCell *tmpCell;
	//IBOutlet ReadMoreCell *tmpReadMoreCell;
	//IBOutlet FeaturedCell *tmpFeaturedCell;
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	NSMutableDictionary * item;
	
	NSString * currentElement;
	NSMutableString * currentTitle, * currentDate, * currentSummary, * currentLink, * currentImageUrl, * currentLuogoOra;
	
	NSString *URLToOpenString;
	//MBProgressHUD *HUD;
	BOOL loading;
	BOOL loadingArticle;
	int currentPage;
	NSMutableString *maxPage;
    IBOutlet UITableView *articlesTable;
	
	    
}

@property (nonatomic,retain) IBOutlet ArticleCell *tmpCell;


@property (nonatomic,retain) NSString *URLToOpenString;
@property (nonatomic,retain) NSString *indiceTab;

-(void) parseXMLFileAtURL:(NSString *)URL;
-(void) updateFeed;
- (int)findSpaceIndex:(NSString *)testo withIndex:(int) cutIndex;
- (BOOL)notConnected;








@end
