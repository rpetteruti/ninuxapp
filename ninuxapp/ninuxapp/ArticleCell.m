//
//  MyShelfCell.m
//  ProGloType2
//
//  Created by Mara Sorella on 10/08/10.
//  Copyright 2010 Università di Roma La Sapienza. All rights reserved.
//

#import "ArticleCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ArticleCell
@synthesize thumbnail, titleLabel, textPreview;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


- (void)setImage:(UIImage *)newIcon
{

	//ROUNDED CORNER
	thumbnail.layer.cornerRadius = 2.0;
	thumbnail.layer.masksToBounds = YES;
    thumbnail.image = newIcon;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




-(void) setLabelFullSize{
	
	CGRect r = CGRectMake(12, 42, 287, 60);
	CGRect s = CGRectMake(12, 3, 287, 38);
	
	
	textPreview.frame=r;
	titleLabel.frame=s;
	

}
@end
