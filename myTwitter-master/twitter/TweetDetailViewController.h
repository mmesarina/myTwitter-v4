//  TweetDetailViewController.h
//  twitter
//
//  Created by malena mesarina on 2/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface TweetDetailViewController : UIViewController

@property (strong, nonatomic) NSString *retweetUserString;

@property (nonatomic, strong) NSString *profilePicURL;

@property (strong, nonatomic) NSString *userNameString;

@property (strong, nonatomic) NSString *userHandleString;

@property (nonatomic, strong) NSString *myText;

@property (strong, nonatomic) NSString *dateTime;


@property (strong, nonatomic) NSString *retweetsNumberString;

@property (strong, nonatomic) NSString *favoritesNumberString;

//Not used by need to keep track off
@property (strong, nonatomic) NSString *timePassed;

//reply_id is used to pass the id fo the tweet to reply to the NewTweetViewController (COmpose view)
// This is the same id as the curretn status_id of the tweet (the tweets id)
@property (strong, nonatomic) NSString *reply_id;

//track state of star button
@property (nonatomic) BOOL starButtonSelected;

//track state of the retweet button
@property (nonatomic) BOOL retweetButtonSelected;

//track index of calling cell
@property (nonatomic) NSString *cellIndexString;








@property (strong, nonatomic) IBOutlet UILabel *retweetUserLabel;//retweetUserString

@property (strong, nonatomic) IBOutlet UIImageView *userPhoto; //profilePicURL

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel; //userNameString

@property (strong, nonatomic) IBOutlet UILabel *userHandleLabel; //userHandleString

@property (strong, nonatomic) IBOutlet UITextView *tweetTextView; //myText

@property (strong, nonatomic) IBOutlet UILabel *dateLabel; //dateTime

@property (strong, nonatomic) IBOutlet UILabel *retweetsNumberLabel;


@property (strong, nonatomic) IBOutlet UILabel *favoritesNumberLabel;
@property (strong, nonatomic) IBOutlet UIButton *starButton;

@property (strong, nonatomic) IBOutlet UIButton *retweetButton;

@property (strong, nonatomic) IBOutlet UIButton *replyButton;

@property (strong, nonatomic) IBOutlet UIView *rulerView1;

@property (strong, nonatomic) IBOutlet UIView *rulerView2;

@property (strong, nonatomic) IBOutlet UIView *rulerView3;







@end
