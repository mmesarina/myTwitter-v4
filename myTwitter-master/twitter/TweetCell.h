//
//  TweetCell.h
//  twitter
//
//  Created by Timothy Lee on 8/6/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userPhoto;
@property (strong, nonatomic) IBOutlet UITextView *tweetTextView;
//@property (strong, nonatomic) IBOutlet UITextField *retweetUserTextField;
@property (strong, nonatomic) IBOutlet UILabel *retweetUserLabel;

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *userHandleLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIButton *topIcon;

@property (strong, nonatomic) IBOutlet UIButton *firstIcon;
@property (strong, nonatomic) IBOutlet UIButton *midIcon;
@property (strong, nonatomic) IBOutlet UIButton *lastIcon;

@property (strong, nonatomic) IBOutlet UIButton *retweetButton;

@property (strong, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) IBOutlet UIButton *retweetButton2;
@property (strong, nonatomic) IBOutlet UIButton *starButton;

@end
