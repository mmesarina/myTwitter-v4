//
//  NewTweetViewController.m
//  twitter
//
//  Created by malena mesarina on 2/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "NewTweetViewController.h"
#import "UIImageView+AFNetworking.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "TwitterClient.h"
#import "myConstants.h"



@interface NewTweetViewController ()

- (void) onTweetButton;
- (void) onCancelButton;


@end

@implementation NewTweetViewController

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
    // Do any additional setup after loading the view from its nib.
	
	//MAKE THE NAVIGATIONBAR LIGHT BLUE
	self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:84.0/255.0 green:172.0/255.0 blue:239.0/255.0 alpha:1];

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(onCancelButton)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweetButton)];
	
	//Make the barButtonItems "white"
	NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:18.0] , NSForegroundColorAttributeName: [UIColor whiteColor]};
	
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];

	
	// Show the current user photo, name  and Twitter Handler
	User *currentUser = [User currentUser];
    
    NSString *currentUsername = [currentUser valueOrNilForKeyPath:@"name"];
	
    NSString *currentHandle = [currentUser valueOrNilForKeyPath:@"screen_name"];
    NSString *currentImageLink = [currentUser valueOrNilForKeyPath:@"profile_image_url"];
	//NSLog(@"currentUsername = %@", currentUsername);
	
	self.userNameLabel.text = currentUsername;
	self.userHandleLabel.text = currentHandle;
	
	__weak UIImageView *weakView = self.userPhoto;
    
	[self.userPhoto setImageWithURLRequest:[[NSURLRequest alloc]
			initWithURL:[NSURL URLWithString:currentImageLink]]
			placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]
			success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
			{
					weakView.image = image;
		 
					//[weakCell setNeedsLayout];
		 
			}
			failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                       
			}
	 ];
	
	if (self.reply_id == nil){
		self.tweetTextView.text = @"write here ";
	} else{
		
		self.tweetTextView.text = self.replyUserScreenName;
		
	}
	
	self.tweetTextView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma - UITextView methods


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	
    //NSLog(@"In textFieldShouldBeginEditing");
	
	return YES;
}



//Method detect new characters entered, if the return key or new line character have been entered then eliminate the keyboard

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	//NSLog(@"In shouldChangeTextInRange");
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    if (location != NSNotFound){
		
		
		[[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"MyTweet"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[textView resignFirstResponder];
		
		
		
		return YES;
    } else {
		
		[[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"MyTweet"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		return YES;
		
		
	}
	
	
}




#pragma - private mathods

- (void) onTweetButton {
	
	
	NSString *theTweetToAdd = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyTweet"];
	
	
	if (self.reply_id == nil) {
		//Post your tweet
		[[TwitterClient instance] postATweet:theTweetToAdd success:^(AFHTTPRequestOperation *operation, id response) {
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"New Tweet Post error is [%@]", error);
		}];
	} else {
		
		[[TwitterClient instance] postATweet:theTweetToAdd success:^(AFHTTPRequestOperation *operation, id response) {
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"New Tweet Post error is [%@]", error);
		}];
		
		// Remove the "MyTweet" object from NSUserdefaults because we do not want to insert the reply in the timeline
		// that way TimeLineVC won't insert it
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MyTweet"];
		
		
	}
	
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
	
	return;
	 
	 }

- (void) onCancelButton {
	
	
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
