//
//  LARBook.m
//  HackerBooks
//
//  Created by Luis Aparicio Ramirez on 20/3/15.
//  Copyright (c) 2015 iKale. All rights reserved.
//

#import "LARBook.h"
#import "Settings.h"


@implementation LARBook

@synthesize bookCover=_bookCover;
@synthesize bookPDF=_bookPDF;

#pragma mark - inicializadores

//inicializador designado
-(id) initWithTitle: (NSString *) aTitle
            authors: (NSArray *)  arrayOfAuthors
               tags: (NSArray *)  arrayOfTags
       bookCoverURL: (NSURL *) aBookCoverURL
         bookPDFURL: (NSURL *) aBookPDFURL
         isFavorite:(BOOL)aIsFavorite{
    if (self=[super init]) {
        _title = aTitle;
        _authors=arrayOfAuthors;
        _tags=arrayOfTags;
        _bookCoverURL=aBookCoverURL;
        _bookPDFURL=aBookPDFURL;
        _isFavorite=aIsFavorite;
    }
    return self;
}

//iniciador de conveniencia
-(id) initWithTitle: (NSString *) aTitle{
    return [self initWithTitle:aTitle authors:nil tags:nil bookCoverURL:nil bookPDFURL:nil isFavorite:false];
}


#pragma mark - inicializador JSON
-(id)initWithDictionary:(NSDictionary *)aDict andMarkAsFavorite: (BOOL) aIsFavorite{
    return [self initWithTitle:[aDict objectForKey:@"title"]
                       authors:[self extractAuthorsFromJSONString:[aDict objectForKey:@"authors"]]
                          tags:[self extractTagsFromJSONString:[aDict objectForKey:@"tags"]]
                  bookCoverURL:[NSURL URLWithString:[aDict objectForKey:@"image_url"]]
                    bookPDFURL:[NSURL URLWithString:[aDict objectForKey:@"pdf_url"]]
                    isFavorite:aIsFavorite];
}

-(id)initWithDictionary:(NSDictionary *)aDict{
    return [self initWithTitle:[aDict objectForKey:@"title"]
                       authors:[self extractAuthorsFromJSONString:[aDict objectForKey:@"authors"]]
                          tags:[self extractTagsFromJSONString:[aDict objectForKey:@"tags"]]
                  bookCoverURL:[NSURL URLWithString:[aDict objectForKey:@"image_url"]]
                    bookPDFURL:[NSURL URLWithString:[aDict objectForKey:@"pdf_url"]]
                    isFavorite:false];
}

-(NSArray *) extractAuthorsFromJSONString:(NSString *) JSONAuthorsString{
      NSArray *authors = [JSONAuthorsString componentsSeparatedByString:@", "];

    return authors;
}

-(NSArray *) extractTagsFromJSONString:(NSString *) JSONTagsString{
    NSArray *tags= [JSONTagsString componentsSeparatedByString:@", "];
    return tags;
}



#pragma mark - overwrite bookCover and bookPDF inicializers
-(NSData *) bookCover{
    if (_bookCover==nil){
        if(![self isFileDownload:self.bookCoverURL]){
          

            [self downloadFile:self.bookCoverURL withFileName:[self discoverFileName:self.bookCoverURL]];
            
            NSData *data = [NSData dataWithContentsOfFile:[self discoverFileName:self.bookCoverURL]];
            _bookCover=data;
            
        }else{
            NSData *data = [NSData dataWithContentsOfFile:[self discoverFileName:self.bookCoverURL]];
            _bookCover=data;
        }
    }
    return _bookCover;
}


-(NSString *)bookPDFFileName{
    return [self discoverFileName:self.bookPDFURL];
}

-(NSData *) bookPDF{
    if([self isFileDownload:self.bookPDFURL]){
        return [NSData dataWithContentsOfFile:[self discoverFileName:self.bookPDFURL]];
        
    }else{
        
        [self bookPDFDownload];
        return [NSData dataWithContentsOfFile:[self discoverFileName:self.bookPDFURL]];

    }
}


-(void) bookPDFDownload{
   
        if(![self isFileDownload:self.bookPDFURL]){
        
            [self downloadFile:self.bookPDFURL withFileName:self.bookPDFFileName];
            
        }
    
}

- (NSString *) discoverFileName: (NSURL *) aURL{
    
    //vemos cual es la ruta fisica del directorio de cache
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory=[paths objectAtIndex: 0];
    
    //sacamos el nombre teorico que tendria el fichero si estuviera grabado.
    
    NSString *nombreFichero = [aURL absoluteString];
    
    nombreFichero = [[[nombreFichero stringByReplacingOccurrencesOfString:@"/"withString:@"_"]stringByReplacingOccurrencesOfString:@":" withString:@"_"]stringByReplacingOccurrencesOfString:@"www." withString:@"www_"];
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",cachesDirectory,nombreFichero];
    
    return fileName;
}

-(BOOL) isFileDownload: (NSURL *) aURL{
    
    NSString *fileName = [self discoverFileName:aURL];
    //comprobamos si existe esa ruta
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath: fileName]){
        
        return true;
    }
    
    return false;
}

- (void) downloadFile: (NSURL *) aURL withFileName: (NSString *) aFileName{
    
    // Load pdf into NSData
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:aURL
                                            options:kNilOptions
                                              error:&error];
    if(data==nil){
        // Error when loading pdf
        NSLog(@"Error %@ when loading data within the browser",error.localizedDescription);
    }
    

    [data writeToFile:aFileName atomically:TRUE];
}

//Marca un libro como favorito
-(void) markAsFavoriteWithValue: (BOOL) favoriteValue{
    NSMutableDictionary *favoriteList;
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    favoriteList= [[defaults objectForKey:@"favorites"] mutableCopy];
    
    if (favoriteList==nil){
        favoriteList= [[NSMutableDictionary alloc]init];
    }
    
    
    
    if (favoriteValue==YES){
        [favoriteList setObject:@"YES" forKey:self.title];
        
    }else{
        
        [favoriteList removeObjectForKey:self.title];
    }

    
    [defaults setObject: favoriteList forKey:@"favorites"];
    [defaults synchronize];

    self.isFavorite=favoriteValue;
    
    
    // Enviar notificación
    NSNotification *notificationFavoriteBook = [NSNotification notificationWithName:DID_SELECT_FAVORITE_BOOK_NOTIFICATION_NAME                                                                             object:self                                                                           userInfo:@{@"BOOK": self}];
    [[NSNotificationCenter defaultCenter] postNotification:notificationFavoriteBook];

}



//quitamos un titulo de favoritos
-(NSMutableArray *) deleteFromFavoritesArray: (NSMutableArray *)array withTitle:(NSString *) title{
    
    for(int i=0;i<[array count];i++){
        LARBook *elemento= [array objectAtIndex:i];
        if (elemento.title==title){
            [array removeObjectAtIndex:i];
            break;
        }
    }
    return array;
}

-(NSMutableDictionary *) exportBookAsDictiornary:(LARBook *) book{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    [dict setObject: book.title forKey:@"title"];
    [dict setObject: book.authors forKey:@"authors"];
    [dict setObject: book.tags forKey:@"tags"];
    [dict setObject: book.bookCoverURL forKey:@"bookCoverURL"];
    [dict setObject: book.bookPDFURL forKey:@"bookPDFURL"];
    
    return dict;

}

@end