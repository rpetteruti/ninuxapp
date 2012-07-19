//
//  SearchResultsCell.h
//  ninuxapp
//
//  Created by Mara Sorella on 10/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideSwipeTableViewCell.h"

@interface SearchResultsCell :UITableViewCell{
 UILabel *nodename;   
 UIImageView *nodeTypePlaceholder;
 UIButton *goToNode;

}






@property (nonatomic, retain) IBOutlet UILabel *nodename;

@property (nonatomic, retain) IBOutlet UIImageView *nodeTypePlaceholder;

@property (nonatomic, retain) IBOutlet UIButton *goToNode;


@end