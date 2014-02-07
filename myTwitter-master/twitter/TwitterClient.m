//
//  TwitterClient.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "TwitterClient.h"
#import "AFNetworking.h"

#define TWITTER_BASE_URL [NSURL URLWithString:@"https://api.twitter.com/"]
#define TWITTER_CONSUMER_KEY @"biYAqubJD0rK2cRatIQTZw"
#define TWITTER_CONSUMER_SECRET @"2cygl2irBgMQVNuWJwMn6vXiyDnWtht7gSyuRnf0Fg"

static NSString * const kAccessTokenKey = @"kAccessTokenKey";

@implementation TwitterClient

+ (TwitterClient *)instance {
    static dispatch_once_t once;
    static TwitterClient *instance;
    
    dispatch_once(&once, ^{
        instance = [[TwitterClient alloc] initWithBaseURL:TWITTER_BASE_URL key:TWITTER_CONSUMER_KEY secret:TWITTER_CONSUMER_SECRET];
    });
    
    return instance;
}

- (id)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret {
    self = [super initWithBaseURL:TWITTER_BASE_URL key:TWITTER_CONSUMER_KEY secret:TWITTER_CONSUMER_SECRET];
    if (self != nil) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:kAccessTokenKey];
        if (data) {
            self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    return self;
}

#pragma mark - Users API

- (void)authorizeWithCallbackUrl:(NSURL *)callbackUrl

		success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success

		failure:(void (^)(NSError *error))failure
        {
			self.accessToken = nil;
			[super authorizeUsingOAuthWithRequestTokenPath:@"oauth/request_token" userAuthorizationPath:@"oauth/authorize"
				callbackURL:callbackUrl
				accessTokenPath:@"oauth/access_token"
				accessMethod:@"POST"
				scope:nil
				success:success
				failure:failure];
		}

- (void)currentUserWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [self getPath:@"1.1/account/verify_credentials.json" parameters:nil success:success failure:failure];
}

#pragma mark - Statuses API

- (void)homeTimelineWithCount:(int)count sinceId:(int)sinceId maxId:(int)maxId success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"count": @(count), @"include_my_retweet":@true}];
   
	if (sinceId > 0) {
        [params setObject:@(sinceId) forKey:@"since_id"];
    }
    if (maxId > 0) {
        [params setObject:@(maxId) forKey:@"max_id"];
    }
    [self getPath:@"1.1/statuses/home_timeline.json" parameters:params success:success failure:failure];
}

#pragma mark - Private methods

- (void)setAccessToken:(AFOAuth1Token *)accessToken {
    [super setAccessToken:accessToken];

    if (accessToken) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kAccessTokenKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAccessTokenKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)postATweet:(NSString *)tweet success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
   
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"status": tweet}];
	
    [self postPath:@"1.1/statuses/update.json" parameters:params success:success failure:failure];
}

/*
- (void)postARetweet:(NSString*)tweetID success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id": tweetID}];
	
    [self postPath:@"1.1/statuses/retweet.json" parameters:params success:success failure:failure];
}
*/


- (void)postARetweet:(NSString*)tweetID success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
	
	// Resource URL : https://api.twitter.com/1.1/statuses/destroy/240854986559455234.json
	// POST https://api.twitter.com/1.1/statuses/destroy/:id.json
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id": tweetID}];
	
	NSString *myString =@"1.1/statuses/retweet/";
	NSString *secondString = [myString stringByAppendingString:tweetID];
	NSString *thirdString = [secondString stringByAppendingString:@".json"];
	
	[self postPath:thirdString parameters:params success:success failure:failure];
	
}

- (void) favoriteATweet:(NSString*)tweetID success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id": tweetID}];
	
	
	NSString *myString =@"1.1/favorites/create/";
	NSString *secondString = [myString stringByAppendingString:tweetID];
	NSString *thirdString = [secondString stringByAppendingString:@".json"];
	
	[self postPath:thirdString parameters:params success:success failure:failure];
	
	
}

- (void) unfavoriteATweet:(NSString*)tweetID success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id": tweetID}];
	
	NSString *myString =@"1.1/favorites/destroy/";
	NSString *secondString = [myString stringByAppendingString:tweetID];
	NSString *thirdString = [secondString stringByAppendingString:@".json"];
	
	[self postPath:thirdString parameters:params success:success failure:failure];
		
}
- (void)destroyARetweet:(NSString*)current_user_retweet_id success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
	
	// Resource URL : https://api.twitter.com/1.1/statuses/destroy/240854986559455234.json
	// POST https://api.twitter.com/1.1/statuses/destroy/:id.json
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id": current_user_retweet_id}];
	
	NSString *myString =@"1.1/statuses/destroy/";
	NSString *secondString = [myString stringByAppendingString:current_user_retweet_id];
	NSString *thirdString = [secondString stringByAppendingString:@".json"];
	
	[self postPath:thirdString parameters:params success:success failure:failure];
	
}


@end
