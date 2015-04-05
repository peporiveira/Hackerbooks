//
//  LARLibraryTableViewController.h
//  HackerBooks
//
//  Created by Luis Aparicio Ramirez on 20/3/15.
//  Copyright (c) 2015 iKale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LARLibraryModel.h"
#import "LARLibraryCellTableViewCell.h"


@class LARLibraryTableViewController;

@protocol LARLibraryTableViewControllerDelegate <NSObject>

-(void) LARLibraryTableViewController: (LARLibraryTableViewController *) aLibraryVC
                    didSelectBook:(LARBook *) aBook;

@end

@interface LARLibraryTableViewController : UITableViewController <LrLibraryTableViewControllerDelegate>

@property (strong,nonatomic) IAALibraryModel *modelLibrary;
@property (weak, nonatomic) id<IAALibraryTableViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableView *libraryTableView;

- (IAABook *)lastSelectedBook;

-(id) initWithLibrary: (IAALibraryModel *) aLibrary
              style: (UITableViewStyle) aStyle;
@end
