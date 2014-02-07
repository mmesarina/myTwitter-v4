//
//  TimelineVC.m
//  twitter
//
//  Created by Timothy Lee on 8/4/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "TimelineVC.h"
#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "TweetDetailViewController.h"
#import "NewTweetViewController.h"
#import "Tweet.h"
#import "TwitterClient.h"


#import "myConstants.h"





@interface TimelineVC ()

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) NSMutableArray *starButtonsArray;

- (void)onSignOutButton;
- (void)reload;
- (void) New:(id) sender;
//- (void) returnFromNewTweet;
- (void)starButtonPressed: (UIButton*) sender;
- (void)retweetButtonPressed: (UIButton*) sender;
- (void)replyButtonPressed: (UIButton*) sender;




@end

@implementation TimelineVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Twitter";
        
        [self reload];
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MyTweet"] != nil) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MyTweet"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"buttonChanges"] != nil){
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"buttonChanges"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	
	//MAKE THE NAVIGATIONBAR LIGHT BLUE
	self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:84.0/255.0 green:172.0/255.0 blue:239.0/255.0 alpha:1];
	
	
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onSignOutButton)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(New:)];
	
	//Make the barButtonItems "white"
	NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:18.0] , NSForegroundColorAttributeName: [UIColor whiteColor]};
	
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
	
	//Make the title "white"
	self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
	
	
    UINib *myCellNib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.tableView registerNib:myCellNib forCellReuseIdentifier:@"TweetCell"];
	
	// PULL REFRESH
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
	
	//Setup notification to know when the NewTweetViewController (modal view controller) is done
	//NSString * const returnFromNewTweetNotification = @"returnFromNewTweetNotification";
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnFromNewTweet) name:returnFromNewTweetNotification object:nil];
	
	
	
		
}

- (void) viewWillAppear:(BOOL)animated {
	
	
	//NSLog(@"IN viewWIllAppear");
	
	
	NSString *theTweetToAdd = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyTweet"];
	
	
	if (theTweetToAdd != nil) {
		//NSLog(@"theTweetToAdd = %@", theTweetToAdd);
	

	
		//Now show locally the tweet feed with your new tweet on top
		//Get 20 new tweets from Twitter
		//add your saved tweet to the tweets array
		//reload table
	
		[[TwitterClient instance] homeTimelineWithCount:20 sinceId:0 maxId:0 success:^(AFHTTPRequestOperation *operation, id response) {
		//NSLog(@"%@", response);
			self.tweets = [Tweet tweetsWithArray:response];
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			// Do nothing
		}];
	
		Tweet *newTweet = [[Tweet alloc] init];
		
		[self.tweets insertObject:[newTweet initNewTweet:theTweetToAdd] atIndex:0];
	
		//NSLog(@"Calling TABLEVIEW RELOADATA");
		[self.tableView reloadData];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MyTweet"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		
	}
	
	NSMutableDictionary *changedTweetFromDetailView = [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonChanges"];
	
	if (changedTweetFromDetailView != nil) {
		
		//Get the inde of the cell to replace with this updated tweet from Detail view
		
		Tweet *tweet = [[Tweet alloc] init];
		Tweet *copyTweet = [[Tweet alloc] init];
		copyTweet = [tweet initFromDictionary:changedTweetFromDetailView];
		NSInteger cellIndex = [copyTweet.cellIndexString intValue];
		
		[self.tweets insertObject:tweet atIndex:cellIndex];
		
		[self.tableView reloadData];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"buttonChanges"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

	
	
	return;
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//NSLog(@"# TWEETS = %d", self.tweets.count);
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Get the tweet data from NSMutableArray
	Tweet *tweet = self.tweets[indexPath.row];
	
	static NSString *CellIdentifier = @"TweetCell";
	
	TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	
	
	// START BUTTON
	[cell.starButton setImage:[UIImage imageNamed:@"twitter_icons_star_off.png"] forState:UIControlStateNormal];
	[cell.starButton setImage:[UIImage imageNamed:@"twitter_icons_star_on.png"] forState:UIControlStateSelected];
	[cell.starButton addTarget:self action:@selector(starButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	cell.starButton.tag = indexPath.row;
	
	// RETWEET BUTTON
	[cell.retweetButton2 setImage:[UIImage imageNamed:@"twitter_icons_retweet_off.png"] forState:UIControlStateNormal];
	[cell.retweetButton2 setImage:[UIImage imageNamed:@"twitter_icons_retweet_on.png"] forState:UIControlStateSelected];
	[cell.retweetButton2 addTarget:self action:@selector(retweetButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	cell.retweetButton2.tag = indexPath.row;
	
	
	// REPLY BUTTON
	
	[cell.replyButton setImage:[UIImage imageNamed:@"twitter_icons_reply_off.png"] forState:UIControlStateNormal];
	[cell.replyButton addTarget:self action:@selector(replyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	cell.replyButton.tag = indexPath.row;
	
	
	[cell.starButton setSelected: tweet.starButtonSelected];
	[cell.retweetButton2 setSelected: tweet.retweetButtonSelected];
	
	
	// If current user is the owner of this tweet, then disable retweet
	User *currentUser = [User currentUser];
	NSString *currentUsername = [currentUser valueOrNilForKeyPath:@"name"];
	
	if ([tweet.userNameString isEqualToString:currentUsername]) {
		cell.retweetButton2.enabled = NO;
	} else {
		cell.retweetButton2.enabled = YES;
	}
	
		
	[cell.retweetButton2 setSelected: tweet.retweetButtonSelected];
	
		
	cell.tweetTextView.text = tweet.myText;
	//NSLog(@"cell index = %ld  Text = %@", (long)indexPath.row, tweet.myText);
	//NSLog(@"Tweets count %lu", (unsigned long)self.tweets.count);
	

	
	[cell.tweetTextView	setAttributedText:[[NSAttributedString alloc] initWithString:tweet.myText attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSForegroundColorAttributeName:[UIColor blackColor]}]];
	
	
	cell.tweetTextView.delegate = self;
	cell.tweetTextView.tag = indexPath.row;
	cell.tag = indexPath.row;
	//cell.tweetTextView.scrollEnabled = NO;
	cell.tweetTextView.selectable = YES;
	
	
	
	
	[cell.retweetUserLabel setAttributedText:[[NSAttributedString alloc] initWithString:tweet.retweetUserString attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSForegroundColorAttributeName:[UIColor lightGrayColor]}]];
	
	
	[cell.userNameLabel setAttributedText:[[NSAttributedString alloc] initWithString:tweet.userNameString attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSForegroundColorAttributeName:[UIColor darkTextColor]}]];
	
	[cell.userHandleLabel setAttributedText:[[NSAttributedString alloc] initWithString:tweet.userHandleString attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSForegroundColorAttributeName:[UIColor lightGrayColor]}]];
	
	
	cell.dateLabel.text = tweet.timePassed;
	cell.backgroundColor = [UIColor clearColor];
	
	//NSLog(@"Tweet text = %@", tweet.myText);
	
	__weak UITableViewCell *weakCell = cell;
	
	
    
	[cell.imageView setImageWithURLRequest:[[NSURLRequest alloc]
											initWithURL:[NSURL URLWithString:tweet.profilePicURL]]
	 
						  placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]
	 
								   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
	 {
		 weakCell.imageView.image = image;
		 
		 [weakCell setNeedsLayout];
		 
	 }
								   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                       
								   }
	 ];
	
	
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//NSLog(@"heightForRowAtIndexPath!!!!");
    Tweet *tweet = self.tweets[indexPath.row];
    
    /*OLD considers only textView */
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat width = screenRect.size.width;
    width -= 64;
	
	//GET SIZE OF RETWEET USERNAME
	UILabel *retLabel = [[UILabel alloc] init];
	NSString *retString = tweet.retweetUserString;
	[retLabel setAttributedText:[[NSAttributedString alloc] initWithString:retString]];
	CGRect retRect = [retLabel.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
												  options:NSStringDrawingUsesLineFragmentOrigin
											   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8]}
												  context:nil];
	CGFloat retUserHeight = retRect.size.height;
	
	
	// GET SIZE OF LABELS
	
	UILabel *label = [[UILabel alloc] init];
	 
	 NSString *labelString = tweet.userNameString;
	
	[label setAttributedText:[[NSAttributedString alloc] initWithString:labelString]];
	
	
	CGRect labelRect = [label.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]} context:nil];
	
	
	CGFloat labelHeight = labelRect.size.height;
	
	
	//GET SIZE OF TEXTVIEW
	UITextView *textView = [[UITextView alloc] init];
	
    NSString *theText = tweet.myText;
    [textView setAttributedText:[[NSAttributedString alloc] initWithString:theText]];
    
   
	
    
	CGRect textRect = [textView.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
												  options:NSStringDrawingUsesLineFragmentOrigin
											   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}
												  context:nil];
    CGFloat textHeight = textRect.size.height + 20;
	
	// GETSIZE OF ICONS
	
	
	CGFloat iconHeight = 20;
	
	//ADD ALL OF THE CONTROL HEIGHTS UP
	
	CGFloat h = retUserHeight + 10 + labelHeight + 10 + textHeight + 10 + iconHeight + 10;
	
    return h;
	
		
}



- (NSIndexPath*) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
		
	TweetDetailViewController *detailViewController = [[TweetDetailViewController alloc]initWithNibName:@"TweetDetailViewController" bundle:nil];
	
	Tweet *theTweet = [self.tweets objectAtIndex:indexPath.row];
	
	detailViewController.retweetUserString = theTweet.retweetUserString;
	
	detailViewController.profilePicURL = theTweet.profilePicURL;
	detailViewController.userNameString = theTweet.userNameString;
	detailViewController.userHandleString = theTweet.userHandleString;
	detailViewController.myText = theTweet.myText;
	detailViewController.dateTime = theTweet.dateTime;
	detailViewController.retweetsNumberString = theTweet.retweetsNumberString;
	detailViewController.favoritesNumberString = theTweet.favoritesNumberString;
	detailViewController.starButtonSelected = theTweet.starButtonSelected;
	detailViewController.retweetButtonSelected = theTweet.retweetButtonSelected;
	detailViewController.cellIndexString = [NSString stringWithFormat:@"%d",indexPath.row];
	detailViewController.timePassed = theTweet.timePassed;
	// Pass the reply_id in order to for detail view to pass it to Compose view (NewTweetViewController)
	detailViewController.reply_id = theTweet.status_id;
	

	 
	
	[self.navigationController pushViewController:detailViewController animated:YES];
	
	return indexPath;
}




- (void)textViewDidChange:(UITextView *)textView {
	
    [self.tableView beginUpdates]; // This will cause an animated update of
    [self.tableView endUpdates];   // the height of your UITableViewCell
}



#pragma mark - Table view delegate


#pragma mark - Private methods

- (void)onSignOutButton {
    [User setCurrentUser:nil];
}

- (void)reload {
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:0 maxId:0 success:^(AFHTTPRequestOperation *operation, id response) {
        //NSLog(@"%@", response);
		[self.refreshControl endRefreshing];
        self.tweets = [Tweet tweetsWithArray:response];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self.refreshControl endRefreshing];
        // Do nothing
    }];
	
	
}

- (void)New:(id) sender {
	
	//NSLog(@"Inside New:");
	NewTweetViewController *tweetModelViewController = [[NewTweetViewController	alloc] initWithNibName:@"NewTweetViewController" bundle:nil];
	
	tweetModelViewController.delegate = self;
	UINavigationController *navigationController = [[UINavigationController alloc]
													
													initWithRootViewController:tweetModelViewController];
	
	[self presentViewController:navigationController animated:YES completion: nil];
	

	
}

- (void)starButtonPressed: (UIButton*) sender{
	NSLog(@"in StartButtonPressed");
	if ([sender isSelected]) {
		[sender setSelected:NO];
		//decrement favorite count
		int index= sender.tag;
		Tweet *theTweet = [self.tweets objectAtIndex:index];
		NSInteger favoritesNumber = [theTweet.favoritesNumberString intValue];
		favoritesNumber -=1;
		theTweet.favoritesNumberString = [NSString stringWithFormat:@"%d", (int) favoritesNumber];
		//save state of button
		theTweet.starButtonSelected = NO;
		
		[self.tweets replaceObjectAtIndex:index withObject:theTweet];
		
		// Send unfavorite mesage
		[[TwitterClient instance] unfavoriteATweet:theTweet.status_id success:^(AFHTTPRequestOperation *operation, id response) {
			
		}failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"Error in unfavoriting tweet");
		}];
		 
		
	}
	else {
		[sender setSelected:YES];
		// increment favorite count
		int index= sender.tag;
		Tweet *theTweet = [self.tweets objectAtIndex:index];
		NSInteger favoritesNumber = [theTweet.favoritesNumberString intValue];
		favoritesNumber +=1;
		theTweet.favoritesNumberString = [NSString stringWithFormat:@"%d", (int) favoritesNumber];
		// save state of button
		theTweet.starButtonSelected = YES;
		[self.tweets replaceObjectAtIndex:index withObject:theTweet];
		
		// Send favorite message
		
		
		[[TwitterClient instance] favoriteATweet:theTweet.status_id success:^(AFHTTPRequestOperation *operation, id response) {
			
		}failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"Error in favoriting tweet");
		}];
		
	}
	
	[self.tableView reloadData];
	
}

- (void)retweetButtonPressed:(UIButton *)sender {
	NSLog(@"in retweetButtonPressed");
	if ([sender isSelected]){
		[sender setSelected:NO];
		// decrement retweet count
		int index = sender.tag;
		Tweet *theTweet = [self.tweets objectAtIndex:index];
		NSInteger retweetsNumbers = [theTweet.retweetsNumberString intValue];
		retweetsNumbers -=1;
		theTweet.retweetsNumberString = [NSString stringWithFormat:@"%d", (int) retweetsNumbers];
		
		// save state of button
		theTweet.retweetButtonSelected = NO;
		
		[self.tweets replaceObjectAtIndex:index withObject:theTweet];
		
		//Get the retweet number (current_user_retweet_id) from the Tweet
		
		NSString *current_user_retweet_id = theTweet.current_user_retweet_id;
		
		// Destroy the retweet
		if (current_user_retweet_id != nil) {
			[[TwitterClient instance] destroyARetweet:current_user_retweet_id success:^(AFHTTPRequestOperation *operation, id response) {
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"Destroy retweet error  is [%@]", error);
			}];
		} else {
			//If currenty_user_retweet_id = nil, but the Retweet button is selected, it is
			// because we have retweeted but we have not reloaded from twitter , so don't have a current_user_retweet_id yet.
		}
		
		
		
		// complete
	} else {
		[sender setSelected:YES];
		
		//increment retweet count
		int index = sender.tag;
		
		Tweet *theTweet = [self.tweets objectAtIndex:index];
		
		NSInteger retweetsNumber = [theTweet.retweetsNumberString intValue];
		
		retweetsNumber +=1;
		
		theTweet.retweetsNumberString = [NSString stringWithFormat:@"%d", (int) retweetsNumber];
		
		// save the state of button
		theTweet.retweetButtonSelected = YES;
		[self.tweets replaceObjectAtIndex:index withObject:theTweet];
		
		//Send the retweet
		
		// Get the tweet status_id
		
		NSString *status_id = theTweet.status_id;
		// retweet
		
		
		
		[[TwitterClient instance] postARetweet:status_id success:^(AFHTTPRequestOperation *operation, id response) {
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"Retweet error  is [%@]", error);
		}];
		
		
	}
	
	[self.tableView reloadData];
	
	
	
}

- (void)replyButtonPressed: (UIButton*) sender {
	
	//Get the reply_id
	int index = sender.tag;
	Tweet *theTweet = [self.tweets objectAtIndex:index];
	NSString *reply_id = theTweet.status_id;
	NSString *replyUserScreenName = [@ "@" stringByAppendingString:theTweet.userHandleString];
	
	NewTweetViewController *tweetModelViewController = [[NewTweetViewController	alloc] initWithNibName:@"NewTweetViewController" bundle:nil];
	tweetModelViewController.reply_id = reply_id;
	tweetModelViewController.replyUserScreenName = replyUserScreenName;
	
	
	tweetModelViewController.delegate = self;
	UINavigationController *navigationController = [[UINavigationController alloc]
													initWithRootViewController:tweetModelViewController];
	
	[self presentViewController:navigationController animated:YES completion: nil];
	
	
	
}



//- (void) returnFromNewTweet {
	//Now show locally the tweet feed with your new tweet on top
	//Get 20 new tweets from Twitter
	//add your saved tweet to the tweets array
	//reload table
	//NSLog(@"In RETURNFROMNEWTWEET GOT NOTIFIED");
	//[[TwitterClient instance] homeTimelineWithCount:20 sinceId:0 maxId:0 success:^(AFHTTPRequestOperation *operation, id response) {
        //NSLog(@"%@", response);
      //  self.tweets = [Tweet tweetsWithArray:response];
        //[self.tableView reloadData];
    //} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Do nothing
    //}];

	//NSString *theTweetToAdd = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyTweet"];
	//NSLog(@"theTweetToAdd = %@", theTweetToAdd);
	//Tweet *newTweet = [[Tweet alloc] init];
	//[self.tweets addObject: [newTweet initNewTweet:theTweetToAdd]];
	
	
	// Clear NSUserDefault value for MyTWeet since we are done adding it to the tweets array
	//[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MyTweet"];
//}

@end
