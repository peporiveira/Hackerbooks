//
//  AppDelegate.m
//  HackerBooks
//
//  Created by Ivan on 20/3/15.
//  Copyright (c) 2015 Ivan. All rights reserved.
//

#import "AppDelegate.h"
#import "IAALibraryModel.h"

#import "IAABookViewController.h"
#import "IAALibraryTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //creamos el modelo
    IAALibraryModel *libraryModel=[[IAALibraryModel alloc]init];
    
    
    
    // crear un cola para descargar los pdfs del modelo
    dispatch_queue_t loadPDFs = dispatch_queue_create("loadPDFs", 0);
    
    
    dispatch_async(loadPDFs, ^{
        [libraryModel downloadPDFS];

        });

    
    

    //miramos en que dispositivo estamos
    UIViewController *rootVC = nil;
    
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad)
    {
        //pantalla grande
        
        rootVC=[self rootViewControllerForPadWithModel:libraryModel];
        
        
    }
    else{
        //pantalla pequeña
        rootVC=[self rootViewControllerForPhoneWithModel:libraryModel];
        
    }
    
    
    //asignamos el split como controlador raiz
    self.window.rootViewController = rootVC;

    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

-(UIViewController *) rootViewControllerForPhoneWithModel: (IAALibraryModel *)libraryModel
{
    //creamos una instancia de los controladores
     IAALibraryTableViewController *libraryVC = [[IAALibraryTableViewController alloc]initWithLibrary:libraryModel style:UITableViewStylePlain];

    
    //Creamos un navigation controller para cada controlador
    
    UINavigationController *navLibraryVC = [[UINavigationController alloc]initWithRootViewController:libraryVC];

    libraryVC.delegate=libraryVC.self;
    
    return navLibraryVC;
}

- (UIViewController *)rootViewControllerForPadWithModel: (IAALibraryModel *)libraryModel

{
    // Controladores
    IAALibraryTableViewController *libraryVC = [[IAALibraryTableViewController alloc]initWithLibrary:libraryModel style:UITableViewStylePlain];
    
    IAABookViewController *bookVC = [[IAABookViewController alloc] initWithBook:[libraryVC lastSelectedBook]];
    
    // Combinadores
    UINavigationController *BookNav = [[UINavigationController alloc] initWithRootViewController:bookVC];
    
    UINavigationController *libraryNav
    = [[UINavigationController alloc] initWithRootViewController:libraryVC];
    
    UISplitViewController *splitVC = [[UISplitViewController alloc] init];
    splitVC.viewControllers = @[libraryNav, BookNav];
    
    //añadirmos esta linea para que muestre el boton del splitview cuando este en horizontal.
    BookNav.topViewController.navigationItem.leftBarButtonItem = splitVC.displayModeButtonItem;

    
    // Delegados
    splitVC.delegate = bookVC;
    libraryVC.delegate = bookVC;
    
    return splitVC;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
