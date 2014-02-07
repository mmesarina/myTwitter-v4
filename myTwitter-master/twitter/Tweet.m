//
//  Tweet.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "Tweet.h"
static const double MINUTE = 60;
static const double HOUR = 3600;
static const double DAY = 86400;
static const double WEEK = 604800;

@interface Tweet ()

- (NSString*) timeStamp:(NSTimeInterval) diff;
@end


@implementation Tweet


//- (NSString *)text {
  //  return [self.data valueOrNilForKeyPath:@"text"];
//}


+ (NSMutableArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:array.count];
	NSInteger i = 0;
    for (NSDictionary *params in array) {
		if (i == 0) {
			//NSLog(@"params = %@", params);
		}
		[tweets addObject:[[Tweet alloc] initWithDictionary:params]];
		i++;
		
    }
    return tweets;
}

-(id) initWithDictionary:(NSDictionary *)dictionary {
    
    //NSLog(@"In initWithDictionary");
	
	self = [super init];
    if (self  ) {
		
		self.myText = dictionary[@"text"];
		
		NSDictionary *user = [[NSDictionary alloc] init];
		user = dictionary[@"user"];
		self.profilePicURL = [user objectForKey:@"profile_image_url"];
		//NSLog(@"profilePicURL = %@", self.profilePicURL);
		
		
		NSDictionary *retweetStatus = dictionary[@"retweeted_status"];
		if (retweetStatus != nil) {
			NSDictionary *retweeter_user = [retweetStatus objectForKey:@"user"];
			NSString *retweeter_screen_name = [retweeter_user objectForKey:@"screen_name"];
		    NSString *newString = [retweeter_screen_name stringByAppendingString:@" retweeted"];
			self.retweetUserString = newString;
		} else {
			self.retweetUserString = @"";
		}
		
		
		
		self.userNameString = [user objectForKey:@"name"];
		self.userHandleString = [user objectForKey:@"screen_name"];
		
		//Compute time passed
		
		
		NSDateFormatter *fromTwitter = [[NSDateFormatter alloc] init];
		
		[fromTwitter setDateFormat:@"EEE MMM dd HH:mm:ss vvvv yyyy"];
		
		
		NSString *createdAt = [dictionary objectForKey:@"created_at"];
		NSDate *createdDate = [fromTwitter dateFromString:createdAt];
		NSTimeInterval diff = -[createdDate timeIntervalSinceNow];
		
		
		
		self.timePassed = [self timeStamp:diff];
		
		

		NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
		[dateFormatter2 setDateFormat:@"MM/dd/yy, HH:mm a"];
		NSString *formattedDateString = [dateFormatter2 stringFromDate:createdDate];
		
		self.dateTime = formattedDateString;
		
		//NSString *strFromInt = [NSString stringWithFormat:@"%d", [dictionary //objectForKey:@"retweet_count"]];
		//self.testString = strFromInt;
		id temp = [dictionary objectForKey:@"retweet_count"];
		NSString *tempString = [NSString stringWithFormat:@"%@",temp];
		self.retweetsNumberString = tempString;
		
		temp = [user objectForKey:@"favourites_count"];
		tempString = [NSString stringWithFormat:@"%@", temp];
		self.favoritesNumberString = tempString;
		
		// load status id of tweet
		
		self.status_id = [dictionary objectForKey:@"id_str"];
		
		// if this tweet was retweeted by you, get current_user_retweet id_str value
		NSDictionary *tmpDic = [dictionary objectForKey:@"current_user_retweet"];
		if (tmpDic != nil){
			NSString *current_user_retweet_id = [tmpDic objectForKey:@"id_str"];
			self.current_user_retweet_id = current_user_retweet_id;
			self.retweetButtonSelected = YES;
			
		} else {
			self.retweetButtonSelected = NO;
		}
		
		self.starButtonSelected = NO; //Default when loading the first time
		
		
		
    }
    return self;
}


- (id) initNewTweet:(NSString*) tweetText
{
	self = [super init];
    if (self  ) {
		//Tweet *newTweet = [[Tweet alloc] init];
		User *currentUser = [User currentUser];
	
		self.myText = tweetText;
		self.profilePicURL = [currentUser objectForKey:@"profile_image_url"];
		self.retweetUserString = [currentUser valueOrNilForKeyPath:@""];
		self.userNameString = [currentUser valueOrNilForKeyPath:@"name"];
		self.userHandleString= [currentUser valueOrNilForKeyPath:@"screen_name"];
		self.timePassed = @"";
	
		NSDate *currentDate = [NSDate date];
		NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
		[dateFormatter2 setDateFormat:@"MM/dd/yy, HH:mm a"];
		NSString *formattedDateString = [dateFormatter2 stringFromDate:currentDate];
	
		self.dateTime = formattedDateString;
	
		
		self.retweetUserString=@"0";
		self.favoritesNumberString = @"0";
		self.starButtonSelected = NO;
		self.retweetButtonSelected = NO;
	
		
	}
	return self;
}


- (id) initFromDictionary:(NSMutableDictionary*) dictionary {
	self = [super init];
    if (self  ) {
		self.myText =[dictionary objectForKey:@"myText"];
		self.profilePicURL =[dictionary objectForKey:@"profilePicURL"];
		self.retweetUserString = [dictionary objectForKey:@"retweetUserString"];
		self.userNameString = [dictionary objectForKey:@"userNameString"];
		self.userHandleString = [dictionary objectForKey:@"userHandleString"];
		self.timePassed = [dictionary objectForKey:@"timePassed"];
		self.dateTime = [dictionary objectForKey:@"dateTime"];
		self.retweetsNumberString = [dictionary objectForKey:@"retweetsNumberString"];
		self.favoritesNumberString = [dictionary objectForKey:@"favoritesNumberString"];
		
		NSInteger tmpInt =[[dictionary objectForKey:@"starButtonSelected"] intValue];
		if (tmpInt == 0)
			self.starButtonSelected = NO;
		else
			self.starButtonSelected = YES;
	
		
		tmpInt = [[dictionary objectForKey:@"retweetButtonSelected"] intValue];
		if (tmpInt == 0){
			self.retweetButtonSelected = NO;
		} else {
			self.retweetButtonSelected= YES;
		}
		
		
		self.cellIndexString = [dictionary objectForKey:@"cellIndexString"];
		
	}
	
	return self;
}

- (NSString*) timeStamp:(NSTimeInterval) diff {
	
	NSString *newString;
	
	if (diff < MINUTE ) {
		NSString *timeLabelString = @" sec";
		NSString *timeString = [NSString stringWithFormat:@"%.0f", floor(diff)];
		newString = [timeString stringByAppendingString:timeLabelString];
		
	} else if (diff < HOUR) {
		NSString *timeLabelString = @" min";
		NSString *timeString = [NSString stringWithFormat:@"%.0f", floor(diff/MINUTE)];
		newString = [timeString stringByAppendingString:timeLabelString];
	
	} else if (diff < DAY) {
		NSString *timeLabelString = @" hrs";
		NSString *timeString = [NSString stringWithFormat:@"%.0f", floor(diff/HOUR)];
		newString = [timeString stringByAppendingString:timeLabelString];
	
	} else if (diff < DAY*365) {
		NSString *timeLabelString = @" dys";
		NSString *timeString = [NSString stringWithFormat:@"%.0f", floor(diff/DAY)];
		newString = [timeString stringByAppendingString:timeLabelString];
		
	} else {
		newString = @"over year";
	}
		
	//NSLog(@"newString = %@", newString);
	return newString;
	
}


@end
