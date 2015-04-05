//
//  LARLibraryTableViewController.m
//  HackerBooks
//
//  Created by Luis Aparicio Ramirez on 20/3/15.
//  Copyright (c) 2015 iKale. All rights reserved.
//

#import "LARLibraryTableViewController.h"
#import "LARBookViewController.h"
#import "Settings.h"

@interface LARLibraryTableViewController ()

@end

@implementation LARLibraryTableViewController


-(id) initWithLibrary:(LARLibraryModel *) aLibrary style:(UITableViewStyle)aStyle{

    if (self=[super initWithStyle:aStyle])
    {
        _modelLibrary=aLibrary;
    }
    self.title=@"Hacker Books";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
   }

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [self.modelLibrary loadFavorites];
    
    // Alta en notificaciones
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favoritesDidChange:)
                                                 name:DID_SELECT_FAVORITE_BOOK_NOTIFICATION_NAME
                                               object:nil];

}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
 
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    // Baja en notificaciones
   // [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  Notifications

- (void)favoritesDidChange:(NSNotification *)aNotification{
    [self.modelLibrary loadFavorites];
    [self.libraryTableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.

    return [self.modelLibrary countOfTags]+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    //la seccion 0 es la de favoritos
    if (section ==0){
        NSUInteger cantidad =[self.modelLibrary countOfFavorites];
        
        return cantidad;
        
    }else{
        
        return [self.modelLibrary bookCountForTag:[self.modelLibrary.tags objectAtIndex:section-1]];
    }
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section ==0){
        
        return @"Favorites";
        
    }else{
        
        return [[self.modelLibrary tagAtIndex:section-1]capitalizedString];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier ";
    LARLibraryCellTableViewCell *cell = (LARLibraryCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    
    // Configuramos la celda...
    
    if (cell == nil){
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LARLibraryCellTableViewCell" owner:self options:nil];
        cell = (LARLibraryCellTableViewCell *)[nib objectAtIndex:0];
    }
    
    //averiguamos el libro que corresponde a la celda
    
    LARBook *book =nil;
    
    if (indexPath.section==0){
        
        book=[self.modelLibrary favoriteBookAtIndex:indexPath.row];
        
    }else{
        
        book=[self.modelLibrary bookForTag:[self.modelLibrary tagAtIndex:indexPath.section-1] atIndex:indexPath.row];
        
    }
    
    //si es favorito ponemos una estrella negra, si no una blanca
    if (book.isFavorite){
        
        cell.bookFavoriteImage.highlighted=YES;
        cell.bookFavoriteImage.image = [UIImage imageNamed:@"726-star"];
        cell.bookFavoriteImage.highlightedImage= [UIImage imageNamed:@"726-star-selected"];
        
    }else{
        
        cell.bookFavoriteImage.highlighted=false;
        cell.bookFavoriteImage.image = [UIImage imageNamed:@"726-star"];
        cell.bookFavoriteImage.highlightedImage= [UIImage imageNamed:@"726-star"];
        
    }

    //sincronizamos vista y modelo
    cell.bookTitle.text=book.title;
    cell.bookAuthors.text = [book.authors componentsJoinedByString:@", "];
    
    
    //cargamos la imagen
    
    [cell.activityIndicator startAnimating];
    
    // crear un cola
    dispatch_queue_t loadCovers = dispatch_queue_create("loadCovers", 0);
    
    
    dispatch_async(loadCovers, ^{
        UIImage *img= [UIImage imageWithData:book.bookCover];
        
        
        // se ejecuta en primer plano
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.bookCoverImage.image=img;
            
             [cell.activityIndicator stopAnimating];
            
        });
    });

    
    
    return cell;
    
    
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView: (UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Devuelve la altura de la fila
    
    return 50;
}

-(void) dealloc{
    
    //nos damos de baja de la notificacion
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
  
    //cogemos el libro seleccionado
    
    LARBook *book =nil;
    
    if (indexPath.section==0){
        
        //cell.bookFavoriteImage.highlighted=YES;
        book=[self.modelLibrary favoriteBookAtIndex:indexPath.row];
        
    }else{
        
        book=[self.modelLibrary bookForTag:[self.modelLibrary tagAtIndex:indexPath.section-1] atIndex:indexPath.row];
    }
    
    // Avisar al delegado
    
    [self.delegate LARLibraryTableViewController:self didSelectBook:book];
    
    //mandamos una notificacion
    
    NSNotification *notificationSelectNewCharacter = [NSNotification notificationWithName:DID_SELECT_NEW_BOOK_NOTIFICATION_NAME object:self                                                                                 userInfo:@{@"NEW_BOOK": book}];
    
    [[NSNotificationCenter defaultCenter] postNotification:notificationSelectNewCharacter];
    
    
    [self saveLastSelectedBookAtSection:indexPath.section
                                    row:indexPath.row];
}


#pragma mark -  NSUserDefaults

- (NSDictionary *)setDefaults{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Por defecto, mostraremos el primero de la seccion de libros (obviando la de favoritos por si no hubiera aun ninguno)
    NSDictionary *defaultBooksCoords = @{@"SECTION" : @1, @"ROW" : @0};
    
    // lo asignamos
    [defaults setObject:defaultBooksCoords
                 forKey:@"LAST_BOOK_SELECTED"];
    // guardamos por si las moscas
    [defaults synchronize];
    
    return defaultBooksCoords;
    
}

- (void)saveLastSelectedBookAtSection:(NSUInteger)section row:(NSUInteger)row{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@{@"SECTION" : @(section),
                          @"ROW"     : @(row)}
                 forKey:@"LAST_BOOK_SELECTED"];
    
    [defaults synchronize]; // Por si acaso, que Murphy acecha.
}

- (LARBook *)lastSelectedBook{
    
    NSIndexPath *indexPath = nil;
    NSDictionary *coords = nil;
    
    coords = [[NSUserDefaults standardUserDefaults] objectForKey:@"LAST_BOOK_SELECTED"];
    
    if (coords == nil) {

        coords = [self setDefaults];
        
    }else{
        
    }
    
    // Transformamos esas coordenadas en un indexpath
    indexPath = [NSIndexPath indexPathForRow:[[coords objectForKey: @"ROW"] integerValue]
                                   inSection:[[coords objectForKey: @"SECTION"] integerValue]];
    
    // devolvemos el libro en cuestión
    
    LARBook *book =nil;
    
    if (indexPath.section==0){
        
        //cell.bookFavoriteImage.highlighted=YES;
        book=[self.modelLibrary favoriteBookAtIndex:indexPath.row];
        
    }else{
        
        book=[self.modelLibrary bookForTag:[self.modelLibrary tagAtIndex:indexPath.section-1] atIndex:indexPath.row];
    }
    
    return book;
}

#pragma mark -  LARLibraryTableViewControllerDelegate

-(void) LARLibraryTableViewController: (LARLibraryTableViewController *) aLibraryVC
                        didSelectBook:(LARBook *) aBook{
    
    // Crear el controlador
    LARBookViewController *bookVC = [[LARBookViewController alloc] initWithBook:aBook];
    
    // Hacer un push
    [self.navigationController pushViewController:bookVC
                                         animated:YES];
}


@end
