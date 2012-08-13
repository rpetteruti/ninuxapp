//
//  FirstViewController.h
//  ninuxapp
//
//  Created by Neo on 12/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleCell.h"
#import "UILabel+VerticalAlign.h"
#import "ArticleWebViewController.h"
#import "LoadingHUD.h"





@interface FeedReaderViewController : UIViewController <NSXMLParserDelegate>{
    
	
	IBOutlet UITableView * newsTable;
	
	UIActivityIndicatorView * activityIndicator;
	
	CGSize cellSize;
	
	NSXMLParser * rssParser;
	
	NSMutableArray * stories;
	
	IBOutlet ArticleCell *tmpCell;

	NSMutableDictionary * item;
	
	NSString * currentElement;
	NSMutableString * currentTitle, * currentDate, * currentSummary, * currentLink, * currentImageUrl, * currentLuogoOra;
	
	NSString *URLToOpenString;

	BOOL loading;
	BOOL loadingArticle;
	int currentPage;
	NSMutableString *maxPage;
    IBOutlet UITableView *articlesTable;
    //UINavigationController *navController;
	
	    
}

@property (nonatomic,retain) IBOutlet ArticleCell *tmpCell;
@property (nonatomic,retain) LoadingHUD *hud;
//@property (nonatomic, retain) IBOutlet UINavigationController *navController;


@property (nonatomic,retain) NSString *URLToOpenString;
@property (nonatomic,retain) NSString *indiceTab;

-(void) parseXMLFileAtURL:(NSString *)URL;
-(void) updateFeed;
- (int)findSpaceIndex:(NSString *)testo withIndex:(int) cutIndex;
- (BOOL)notConnected;








@end
