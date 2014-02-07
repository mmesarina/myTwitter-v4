//
//  TweetDetailViewController.m
//  twitter
//
//  Created by malena mesarina on 2/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "NewTweetViewController.h"

@interface TweetDetailViewController ()

@property (nonatomic, strong) NSMutableDictionary *buttonsDictionary;

-(void) initControls;
- (void)buttonPressed: (UIButton*) sender;
- (void)replyButtonPressed: (UIButton*) sender;


@end

@implementation TweetDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(replyButtonPressed:)];
	self.buttonsDictionary = [[NSMutableDictionary alloc] init];
	[self initControls];
	
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initControls {
	
	
	//Setup the buttons
	[self.starButton setImage:[UIImage imageNamed:@"twitter_icons_star_off.png"] forState:UIControlStateNormal];
	[self.starButton setImage:[UIImage imageNamed:@"twitter_icons_star_on.png"] forState:UIControlStateSelected];
	[self.starButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.retweetButton setImage:[UIImage imageNamed:@"twitter_icons_retweet_off.png"] forState:UIControlStateNormal];
	[self.retweetButton setImage:[UIImage imageNamed:@"twitter_icons_retweet_on.png"] forState:UIControlStateSelected];
	[self.retweetButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.replyButton setImage:[UIImage imageNamed:@"twitter_icons_reply_off.png"] forState:UIControlStateNormal];
	[self.replyButton addTarget:self action:@selector(replyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	
	
	self.retweetUserLabel.text = self.retweetUserString;
	
	self.profilePicURL = self.profilePicURL;
	
	self.userNameLabel.text = self.userNameString;
	
	self.userHandleLabel.text = self.userHandleString;
	
	self.tweetTextView.text = self.myText;
	
	self.dateLabel.text = self.dateTime;
	
	self.retweetsNumberLabel.text = self.retweetsNumberString;
	
	self.favoritesNumberLabel.text = self.favoritesNumberString;
	
	// START BUTTON
	// Save the index of the Cell where this button is so that TimeLineVC could
	// update the state of the button when returning.
	
	[self.starButton setSelected:self.starButtonSelected];
	self.starButton.titleLabel.text = @"starButton";
	self.starButton.tag = [self.cellIndexString intValue];
	
	// RETWEET BUTTON
	[self.retweetButton setSelected:self.retweetButtonSelected];
	self.retweetButton.titleLabel.text = @"retweetButton";
	self.retweetButton.tag = [self.cellIndexString intValue];
	
	// REPLY BUTTON
	self.replyButton.tag = [self.cellIndexString intValue];
	
	__weak UIImageView *weakView = self.userPhoto;
    
	[self.userPhoto setImageWithURLRequest:[[NSURLRequest alloc]
											initWithURL:[NSURL URLWithString:self.profilePicURL]]
	 
						  placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]
	 
								   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
	 {
		 weakView.image = image;
		 
		 //[weakCell setNeedsLayout];
		 
	 }
								   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                       
								   }
	 ];
	
	
	
	
}

// If changed in button state, save that state so that TimeLineVC can update its
// cell when returning (viewVillAppea)

- (void)buttonPressed:(UIButton *)sender
{
	
	
	
	NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
	[myDictionary setObject:self.myText forKey:@"myText"];
	[myDictionary setObject:self.profilePicURL forKey:@"profilePicURL"];
	[myDictionary setObject:self.retweetUserString forKey:@"retweetUserString"];
	[myDictionary setObject:self.userNameString forKey:@"userNameString"];
	[myDictionary setObject:self.userHandleString forKey:@"userHandleString"];
	[myDictionary setObject:self.timePassed forKey:@"timePassed"];
	[myDictionary setObject:self.dateTime forKey:@"dateTime"];
	
	NSString *cellIndexString = [NSString stringWithFormat:@"%d", sender.tag];
	[myDictionary setObject:cellIndexString forKey:@"cellIndexString"];
	
	//Create new Tweet to pass upwards
	//Tweet *newTweet = [self createNewTweet:myDictionary];
	
	
	
	if ([sender.titleLabel.text  isEqual: @"starButton"]) {
		if ([sender isSelected]) {
			[sender setSelected:NO];
			//decrement favorite count
			NSInteger favoritesNumber = [self.favoritesNumberString intValue];
			favoritesNumber -=1;
			self.favoritesNumberLabel.text = [NSString stringWithFormat:@"%d", favoritesNumber];
			
			//Changes below
			[myDictionary setObject:[NSString stringWithFormat:@"%d",favoritesNumber] forKey:@"favoritesNumberString"];
			
			NSString *starButtonSelectedString = @"0";
			
			[myDictionary setObject:starButtonSelectedString forKey:@"starButtonSelected"];
			
			[myDictionary setObject:self.retweetsNumberString forKey:@"retweetsNumberString"];
			
			BOOL retweetButtonSelected = self.retweetButton.selected;
			
			NSString *retweetButtonSelectedString;
			
			if (retweetButtonSelected == NO) {
				
				retweetButtonSelectedString = @"0";
			} else {
				retweetButtonSelectedString	= @"1";
				
			}
			
			[myDictionary setObject:retweetButtonSelectedString forKey:@"retweetButtonSelected"];
			
			// Send unfavorite message to Twitter
			[[TwitterClient instance] unfavoriteATweet:self.reply_id success:^(AFHTTPRequestOperation *operation, id response) {
				
			}failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"Error in unfavoriting tweet");
			}];
			
			
		} else {
			[sender setSelected:YES];
			//increment favorite count
			NSInteger favoritesNumber = [self.favoritesNumberString intValue];
			favoritesNumber +=1;
			self.favoritesNumberLabel.text = [NSString stringWithFormat:@"%d", favoritesNumber];
			
			
			//Changes below
			[myDictionary setObject:[NSString stringWithFormat:@"%d",favoritesNumber] forKey:@"favoritesNumberString"];
			
			NSString *starButtonSelectedString = @"1";
			
			[myDictionary setObject:starButtonSelectedString forKey:@"starButtonSelected"];
			
			[myDictionary setObject:self.retweetsNumberString forKey:@"retweetsNumberString"];
			
			BOOL retweetButtonSelected = self.retweetButton.selected;
			
			NSString *retweetButtonSelectedString;
			
			if (retweetButtonSelected == NO) {
				
				retweetButtonSelectedString = @"0";
			} else {
				retweetButtonSelectedString	= @"1";
				
			}
			[myDictionary setObject:self.retweetsNumberString forKey:@"retweetsNumberString"];
			
			//Send favorite message to Twiiter server
			
			
			[[TwitterClient instance] favoriteATweet:self.reply_id success:^(AFHTTPRequestOperation *operation, id response) {
				
			}failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"Error in favoriting tweet");
			}];
			
			
		}
	}
	
	
	if ([sender.titleLabel.text isEqual:@"retweetButton"]) {
		if ([sender isSelected]) {
			[sender setSelected:NO];
			//decrement retweet count
			NSInteger retweetsNumber = [self.retweetsNumberString intValue];
			retweetsNumber -=1;
			self.retweetsNumberLabel.text = [NSString stringWithFormat:@"%d", retweetsNumber];
			
			//Changes below
			[myDictionary setObject:[NSString stringWithFormat:@"%d", retweetsNumber] forKey:@"retweetsNumberString"];
			NSString *retweetButtonSelectedString = @"0";
			[myDictionary setObject:retweetButtonSelectedString forKey:@"retweetButtonSelected"];
			[myDictionary setObject:self.favoritesNumberString forKey:@"favoritesNumberString"];
			
			
			
			
			
			
		} else {
			[sender setSelected:YES];
			// increment retweet count
			NSInteger retweetsNumber = [self.retweetsNumberString intValue];
			retweetsNumber +=1;
			self.retweetsNumberLabel.text = [NSString stringWithFormat:@"%d", retweetsNumber];
			
			//Changes below
			[myDictionary setObject:[NSString stringWithFormat:@"%d",retweetsNumber] forKey:@"retweetsNumberString"];
			NSString *retweetButtonSelectedString = @"1";
			[myDictionary setObject:retweetButtonSelectedString forKey:@"retweetButtonSelected"];
			[myDictionary setObject:self.favoritesNumberString forKey:@"favoritesNumberString"];
			
			BOOL starButtonSelected = self.starButton.selected;
			NSString *starButtonSelectedString;
			if (starButtonSelected == NO) {
				starButtonSelectedString = @"0";
			} else {
				starButtonSelectedString = @"1";
			}
			[myDictionary setObject:starButtonSelectedString forKey:@"starButtonSelected"];
			
			
		}
		
		
	}
	
	
	//[[NSUserDefaults standardUserDefaults] setObject:newTweet forKey:@"buttonChanges"];
	// Test
	
	[[NSUserDefaults standardUserDefaults] setObject:myDictionary forKey:@"buttonChanges"];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
}


- (void) replyButtonPressed:(UIButton *)sender {
	
	//Get the reply_id
	
	
	
	NSString *reply_id = self.reply_id;
	
	NSString *replyUserScreenName = [@ "@" stringByAppendingString:self.userHandleString];
	
	NewTweetViewController *tweetModelViewController = [[NewTweetViewController	alloc] initWithNibName:@"NewTweetViewController" bundle:nil];
	tweetModelViewController.reply_id = reply_id;
	tweetModelViewController.replyUserScreenName = replyUserScreenName;
	
	
	tweetModelViewController.delegate = self;
	UINavigationController *navigationController = [[UINavigationController alloc]
													initWithRootViewController:tweetModelViewController];
	
	[self presentViewController:navigationController animated:YES completion: nil];
}

/*DON'T USE
 - (Tweet*) createNewTweet: (NSMutableDictionary*) dictionary
 {
 Tweet *newTweet = [[Tweet alloc] init];
 newTweet.myText = [dictionary objectForKey:@"myText"];
 newTweet.profilePicURL = [dictionary objectForKey:@"profilePicURL"];
 newTweet.retweetUserString = [dictionary objectForKey:@"retweetUserString"];
 newTweet.userNameString = [dictionary objectForKey:@"userNameString"];
 newTweet.userHandleString = [dictionary objectForKey:@"userHandleString"];
 newTweet.timePassed = [dictionary objectForKey:@"timePassed"];
 newTweet.dateTime = [dictionary objectForKey:@"dateTime"];
 newTweet.cellIndexString = [dictionary objectForKey:@"cellIndexString"];
 
 return newTweet;
 
 }
 */

@end
