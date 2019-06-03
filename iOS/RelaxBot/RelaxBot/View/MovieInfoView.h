//
//  MovieInfoView.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/12.
//  Copyright © 2019 xiongbiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MovieInfoViewDelegate <NSObject>
-(void)dismissMovieInfoClick;
@end

@interface MovieInfoView : UIView
@property (nonatomic, strong) MovieInfo *movieInfo;
@property (nonatomic, weak) id <MovieInfoViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
