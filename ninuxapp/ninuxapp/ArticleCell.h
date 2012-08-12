//
//  MyShelfCell.h
//  ProGloType2
//
//  Created by Mara Sorella on 10/08/10.
//  Copyright 2010 Università di Roma La Sapienza. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ArticleCell : UITableViewCell {

	
	IBOutlet UIImageView *thumbnail;
    IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *textPreview;
	
	
	
	
	
}

@property (nonatomic,retain) UIImageView *thumbnail;
@property (nonatomic,retain) IBOutlet UILabel *titleLabel;
@property (nonatomic,retain) IBOutlet UILabel *textPreview;


- (void)setImage:(UIImage *)newIcon;
- (void) setLabelFullSize;


  @end
