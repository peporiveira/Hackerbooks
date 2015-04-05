//
//  LARPDFViewController.m
//  HackerBooks
//
//  Created by Luis Aparicio Ramirez on 20/3/15.
//  Copyright (c) 2015 iKale. All rights reserved.
//

#import "LARPDFViewController.h"
#import "Settings.h"

@interface LARPDFViewController ()

@end

@implementation LARPDFViewController


-(id) initWithBook: (LARBook *) aBook{
    
    if (self=[super init]){
        
        _book=aBook;
        self.title=aBook.title;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    
    //asignamos delegado
    self.webView.delegate = self;
    
    [self syncWithModel];

    //nos damos de alta en la notificacion de aviso cuando se cambie de personaje
    NSNotificationCenter *nCenter = [NSNotificationCenter defaultCenter];
    [nCenter addObserver:self
                selector:@selector (notifyBookDidChange:)
                    name:DID_SELECT_NEW_BOOK_NOTIFICATION_NAME
                  object:nil];
    

}


-(void) syncWithModel{
    
    [self.activityView startAnimating];
 
    
    // crear un cola para descargar los pdfs del modelo
    dispatch_queue_t loadPDF = dispatch_queue_create("loadPDF", 0);
    
    dispatch_async(loadPDF, ^{
        NSData *data = self.book.bookPDF;
            
            // se ejecuta en primer plano
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView loadData:data MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@"https://"]];
                
                [self.activityView stopAnimating];
                
            });
        });

        
       self.title=self.book.title;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - notifications

-(void) notifyBookDidChange: (NSNotification *) notification{
    
    NSDictionary *dict = [notification userInfo];
    
    LARBook *newbook = [dict objectForKey:@"NEW_BOOK"];
    
    //actualizamos el modelo
    self.book=newbook;
    
    //Sincronizamos vista y modelo
    [self syncWithModel];
}


#pragma mark - UIWebViewDelegate
-(void) webViewDidFinishLoad:(UIWebView *)webView{
    
    [self.activityView setHidden:YES];
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType{
    
    if ((navigationType==UIWebViewNavigationTypeLinkClicked) ||
        (navigationType==UIWebViewNavigationTypeFormSubmitted)){
        
        return false;
        
    }else{
        
        return true;
    }
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    [self.activityView setHidden:YES];
    
    NSLog(@"Error: %@", error.description);
}
@end
