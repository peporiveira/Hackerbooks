//
//  LARPDFViewController.h
//  HackerBooks
//
//  Created by Luis Aparicio Ramirez on 20/3/15.
//  Copyright (c) 2015 iKale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LARBook.h"

@interface LARPDFViewController : UIViewController <UIWebViewDelegate>
@property (strong,nonatomic) LARBook *book;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

-(id) initWithBook: (LARBook *) aBook;

@end
