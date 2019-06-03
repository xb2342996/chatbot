//
//  Movie.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/12.
//  Copyright © 2019 xiongbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

enum MovieInfoType {
    MovieInfoTypeOverview = 0,
    MovieInfoTypeActor,
    MovieInfoTypeDirector,
    MovieInfoTypeGenre,
    MovieInfoTypePlot,
    MovieInfoTypeReleased,
    MovieInfoTypeWriter,
    MovieInfoTypeRating,
};

@interface Movie : NSObject
@property (copy, nonatomic) NSString *Actors;
@property (copy, nonatomic) NSString *Director;
@property (copy, nonatomic) NSString *Writer;
@property (copy, nonatomic) NSString *Genre;
@property (copy, nonatomic) NSString *Language;
@property (copy, nonatomic) NSString *Metascore;
@property (copy, nonatomic) NSString *Plot;
@property (copy, nonatomic) NSString *Poster;
@property (copy, nonatomic) NSString *Released;
@property (copy, nonatomic) NSString *Runtime;
@property (copy, nonatomic) NSString *Title;
@property (copy, nonatomic) NSString *imdbRating;
@end

@interface MovieInfo : NSObject
@property (strong, nonatomic) Movie *movie;
@property (assign, nonatomic) enum MovieInfoType type;
@end
NS_ASSUME_NONNULL_END
