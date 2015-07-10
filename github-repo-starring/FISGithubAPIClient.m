//
//  FISGithubAPIClient.m
//  github-repo-list
//
//  Created by Joe Burgess on 5/5/14.
//  Copyright (c) 2014 Joe Burgess. All rights reserved.
//

#import "FISGithubAPIClient.h"
#import "FISConstants.h"
#import <AFNetworking.h>

@implementation FISGithubAPIClient
NSString *const GITHUB_API_URL=@"https://api.github.com";

+(void)getRepositoriesWithCompletion:(void (^)(NSArray *))completionBlock
{
    NSString *githubURL = [NSString stringWithFormat:@"%@/repositories?client_id=%@&client_secret=%@",GITHUB_API_URL,GITHUB_CLIENT_ID,GITHUB_CLIENT_SECRET];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager GET:githubURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject){
        
        completionBlock(responseObject);
        
    }
         failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        NSLog(@"Fail: %@",error.localizedDescription);
    }];
}

// https://api.github.com/repos/yoyoyoseob/whack-a-doge

// https://api.github.com/users/yoyoyoseob/starred This will return a list of all repos starred by user

// https://api.github.com/user/starred/yoyoyoseob/whack-a-doge?access_token=d40baea60933b4e7058c6596cb7704a200ca3b95
// EXTRA PARAM IS ACCESS TOKEN

+(void)checkIfStarred:(NSString *)fullName withCompletion:(void (^)(BOOL starred))completionBlock
{
    NSURLSession *urlSession = [NSURLSession sharedSession];
//    
//    NSString *userStarredRepoURL = [NSString stringWithFormat:@"%@/user/starred/%@?client_id=%@&client_secret=%@&access_token=%@", GITHUB_API_URL, fullName, GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, GITHUB_ACCESS_TOKEN];
//    
    NSURL *url = [FISGithubAPIClient urlForStarredRepo:fullName];
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *headerResponse = (NSHTTPURLResponse *)response;
    
        NSLog(@"Status: %lu", headerResponse.statusCode);
        
        if (headerResponse.statusCode == 204)
        {
            completionBlock(YES);
        }
        else if (headerResponse.statusCode == 404)
        {
            completionBlock(NO);
        }
    }];
    
    [task resume];
}

+(void)starRepo:(NSString *)fullName withCompletion:(void (^)(BOOL starred))completionBlock
{
    NSURL *url = [FISGithubAPIClient urlForStarredRepo:fullName];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *headerResponse = (NSHTTPURLResponse *)response;
        
        if (headerResponse.statusCode == 204)
        {
            completionBlock(YES);
        }
        else
        {
            completionBlock(NO);
        }
    }];
    
    [task resume];
}

+(void)unstarRepo:(NSString *)fullName withCompletion:(void (^)(BOOL unstarred))completionBlock
{
    NSURL *url = [FISGithubAPIClient urlForStarredRepo:fullName];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"DELETE";
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *headerResponse = (NSHTTPURLResponse *)response;
        
        if (headerResponse.statusCode == 204)
        {
            completionBlock(YES);
        }
        else
        {
            completionBlock(NO);
        }
    }];
    
    [task resume];
}

+(NSURL *)urlForStarredRepo:(NSString *)fullName
{
    NSString *userStarredRepoURL = [NSString stringWithFormat:@"%@/user/starred/%@?client_id=%@&client_secret=%@&access_token=%@", GITHUB_API_URL, fullName, GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, GITHUB_ACCESS_TOKEN];
    
    return [NSURL URLWithString:userStarredRepoURL];
}

+(void)toggleStarForRepo:(NSString *)fullName withCompletion:(void (^)(BOOL starred))completionBlock
{
    // Check starred status
    [FISGithubAPIClient checkIfStarred:fullName withCompletion:^(BOOL starred) {
        if (starred)
        {
            // Currently starred - unstar it
            [FISGithubAPIClient unstarRepo:fullName withCompletion:^(BOOL unstarred) {
                completionBlock(NO); // This will only get called with UNSTARRING IS COMPLETE which is where we want it
            }];
        }
        else
        {
            // Currently unstarred - star it
            [FISGithubAPIClient starRepo:fullName withCompletion:^(BOOL starred) {
                completionBlock(YES);
            }];
        }
    }];
}



@end
