//
//  ISSTextFieldViewController.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/15/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSTextFieldViewController.h"

@interface ISSTextFieldViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;

@end

@implementation ISSTextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedButton:(id)sender {
    NSLog(@"Text field text: %@", self.tokenTextField.text);
    
    [[NSUserDefaults standardUserDefaults] setObject:self.tokenTextField.text forKey:@"OtherAPIKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [ISSDataShare shared].secondAuthToken = self.tokenTextField.text;
    
    [self doSomething];
}

- (void)doSomething {
    NSString *reqString = [NSString stringWithFormat:@"%@%@", INSTAGRAM_APITAG, TOKEN_COMBINED];
    NSLog(@"reqString: %@", reqString);
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqString]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *data = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", dict);
        }
    }];
    
    [data resume];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
