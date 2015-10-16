//
//  ViewController.m
//  JustAuth
//
//  Created by Jon Nguy on 10/16/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextView *tokenTextView;
@property (weak, nonatomic) IBOutlet UILabel *label;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Webview stuff.. instagram..
    NSString* authURL = [NSString stringWithFormat: @"%@?client_id=%@&redirect_uri=%@&response_type=code&scope=%@&DEBUG=True", INSTAGRAM_AUTHURL, INSTAGRAM_CLIENT_ID, INSTAGRAM_REDIRECT_URI, INSTAGRAM_SCOPE];
    
    NSLog(@"Auth url:%@", authURL);
    [self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: authURL]]];
    [self.webView setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [self checkRequestForCallbackURL: request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.webView.layer removeAllAnimations];
    self.webView.userInteractionEnabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.webView.layer removeAllAnimations];
    self.webView.userInteractionEnabled = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self webViewDidFinishLoad:webView];
}

- (BOOL)checkRequestForCallbackURL:(NSURLRequest *)request {
    NSString* urlString = [[request URL] absoluteString];
    if ([urlString hasPrefix: INSTAGRAM_REDIRECT_URI]) {
        // extract and handle access token
        NSRange range = [urlString rangeOfString: @"code="];
        [self makePostRequest:[urlString substringFromIndex: range.location+range.length]];
        return NO;
    }
    
    return YES;
}

- (void)makePostRequest:(NSString *)code {
    NSString *post = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",INSTAGRAM_CLIENT_ID,INSTAGRAM_CLIENTSERCRET,INSTAGRAM_REDIRECT_URI,code];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *requestData = [NSMutableURLRequest requestWithURL:
                                        [NSURL URLWithString:@"https://api.instagram.com/oauth/access_token"]];
    [requestData setHTTPMethod:@"POST"];
    [requestData setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [requestData setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [requestData setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:requestData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"Successfully logged in with token == %@", dict[@"access_token"]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.label.text = dict[@"access_token"];
            });
            
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = dict[@"access_token"];
        }
    }];
    
    [dataTask resume];
}

@end
