//
//  LARBookViewController.m
//  HackerBooks
//
//  Created by Luis Aparicio Ramirez on 20/3/15.
//  Copyright (c) 2015 iKale. All rights reserved.
//

#import "LARBookViewController.h"
#import "LARPDFViewController.h"
#import "LARLibraryTableViewController.h"

@interface LARBookViewController ()

@end

@implementation LARBookViewController

- (IBAction)showPDF:(id)sender;{
    
    //creamos la nueva vista y le pasamos el libro
    LARPDFViewController *PDFVC = [[LARPDFViewController alloc]initWithBook:self.book];
    
    [self.navigationController pushViewController:PDFVC animated:YES];
}

-(id) initWithBook: (LARBook *) aBook{

    if (self = [super init]) {
        _book = aBook;
        self.title = aBook.title;
    }
    
    return self;
}

- (IBAction)setFavorite:(id)sender{
    
    if (self.book.isFavorite){
        
        [self.book markAsFavoriteWithValue:NO];
        
    }else{
        
        [self.book markAsFavoriteWithValue:YES];
    }
    
    [self syncViewModel];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    
    [self syncViewModel];
    
    
    if (([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft)||([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight)){
        
        [self addLandscapeView];
        
    }else{
        
        [self.LandscapeView removeFromSuperview];
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    if (([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft)||([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight)){
        
        [self addLandscapeView];
        
    }else{
        
        [self.LandscapeView removeFromSuperview];
    }
    
}

- (void)addLandscapeView{
    
    [self.view addSubview:self.LandscapeView];
}




- (void)syncViewModel{
    self.title =self.book.title;
    
    //sincronizamos vista vertical
    self.bookCoverImage.image=[UIImage imageWithData:self.book.bookCover];
    self.bookTitleLabel.text=self.book.title;
    self.bookAuthorsLabel.text= [self.book.authors componentsJoinedByString:@", "];
    self.bookTagsLabel.text= [self.book.tags componentsJoinedByString:@", "];

    //sincronizamos vista horizontal
    self.bookCoverImageLandscape.image=[UIImage imageWithData:self.book.bookCover];
    self.bookTitleLabelLandscape.text=self.book.title;
    self.bookAuthorsLabelLanscape.text= [self.book.authors componentsJoinedByString:@", "];
    self.bookTagsLabelLandscape.text= [self.book.tags componentsJoinedByString:@", "];
    
    
    if (self.book.isFavorite){
        
        [self.toolbarButtonMarkAsFavorite setTitle:@"Quitar de Favoritos"];
        [self.toolbarButtonMarkAsFavoriteLandscape setTitle:@"Quitar de Favoritos"];
        
    }else{
        

        [self.toolbarButtonMarkAsFavorite setTitle:@"Poner como Favorito"];
        [self.toolbarButtonMarkAsFavoriteLandscape setTitle:@"Poner como Favorito"];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISplitViewControllerDelegate
-(void) splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode{
    
    if (displayMode == UISplitViewControllerDisplayModePrimaryHidden){
        
        self.navigationItem.leftBarButtonItem = svc.displayModeButtonItem;
    }
    
    else if (displayMode == UISplitViewControllerDisplayModeAllVisible){
        
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark -  LARLibrartTableViewControllerDelegate

-(void) LARLibraryTableViewController: (LARLibraryTableViewController *) aLibraryVC
                        didSelectBook:(LARBook *) aBook{
    
    self.book = aBook;
    [self syncViewModel];
}


@end
