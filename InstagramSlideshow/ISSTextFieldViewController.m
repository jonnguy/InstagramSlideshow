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
    
    NSLog(@"Saved other token: %@", [ISSDataShare shared].secondAuthToken);
    [[ISSDataShare shared] fetchTagImagesWithAuth:[ISSDataShare shared].secondAuthToken completionHandler:^(NSDictionary *dict, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"Fetched 2nd dict");
        }
    }];
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
