//
//  PDFViewController.m
//  mageo
//
//  Created by swallow on 2/13/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import "PDFViewController.h"

@interface PDFViewController ()

@end

@implementation PDFViewController

@synthesize webview_pdf, filepath_pdf;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSURL * fileurl = [NSURL fileURLWithPath:filepath_pdf ];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:fileurl];
    //NSURLRequest *request = [NSURLRequest requestWithURL:fileurl cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60.0 ];
    
    [webview_pdf setScalesPageToFit:YES];
    [webview_pdf loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
