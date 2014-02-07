//
//  NewTweetViewController.h
//  twitter
//
//  Created by malena mesarina on 2/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>


//Declare the protocol that the TimeLineVC.h needs to adopt in order to
// to dismiss the NewTweetViewController
//DIDN"T NEED TO DECLARE A PROTOCOL TO DISMISS THE MODALVIEWCONTROLLER
//IOS DOCUMENTATION IS MISLEADING

/*
@class NewTweetViewController;
@protocol NewTweetDelegate <NSObject>
@optional
-(void)  dismissMe:(BOOL) flag;

@end

*/

@interface NewTweetViewController : UIViewController <UITextViewDelegate, UIScrollViewDelegate>

//@property(nonatomic, assign) id <NewTweetDelegate> delegate;
@property(nonatomic, assign) id  delegate;

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *userHandleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userPhoto;
@property (strong, nonatomic) IBOutlet UITextView *tweetTextView;


// Use to pass reply_id which is the tweet id that I am replying to from TinelineVC
@property (strong, nonatomic) NSString *reply_id;
// The screen name of user we are replying to
@property (strong, nonatomic) NSString *replyUserScreenName;


@end
