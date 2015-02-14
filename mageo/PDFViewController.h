//
//  PDFViewController.h
//  mageo
//
//  Created by swallow on 2/13/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webview_pdf;

@property (nonatomic,strong) NSString * filepath_pdf;

@end
