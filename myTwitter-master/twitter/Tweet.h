//
//  Tweet.h
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : RestObject


@property (nonatomic, strong) NSString *myText;

@property (nonatomic, strong) NSString *profilePicURL;

@property (strong, nonatomic) NSString *retweetUserString;

@property (strong, nonatomic) NSString *userNameString;

@property (strong, nonatomic) NSString *userHandleString;

@property (strong, nonatomic) NSString *timePassed;


//FOR DETAIL VIEW

@property (strong, nonatomic) NSString *dateTime;

@property (strong, nonatomic) NSString *retweetsNumberString;

@property (strong, nonatomic) NSString *favoritesNumberString;


// FOR BUTTONS
@property (nonatomic) BOOL starButtonSelected;
@property (nonatomic) BOOL retweetButtonSelected;


//FOR PASSING INDEX NUMBER OF CELL FROM DETAIL VIEW
@property (nonatomic) NSString *cellIndexString;

//For retweeting need status_id of tweet
@property (nonatomic, strong) NSString *status_id;

//To destroy the rewteet we need to know the id of the current_user_retweet optino in json feed
@property (nonatomic, strong) NSString *current_user_retweet_id;





+ (NSMutableArray *)tweetsWithArray:(NSArray *)array;

-(id) initWithDictionary:(NSDictionary *)dictionary;

- (id) initNewTweet:(NSString*) tweetText;

- (id) initFromDictionary:(NSMutableDictionary*) dictionary;
@end
