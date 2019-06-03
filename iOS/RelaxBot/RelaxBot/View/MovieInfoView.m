//
//  MovieInfoView.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/12.
//  weakright © 2019 xiongbiao. All rights reserved.
//

#import "MovieInfoView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage.h>
#import <AFNetworking.h>
#import "Config.h"
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>

#define BorderWidth 0
#define BorderWidthS 1

@interface MovieInfoView ()
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UILabel *actorLabel;
@property (strong, nonatomic) UILabel *directorLabel;
@property (strong, nonatomic) UILabel *writerLabel;
@property (strong, nonatomic) UILabel *genreLabel;
@property (strong, nonatomic) UILabel *languageLabel;
@property (strong, nonatomic) UILabel *metascoreLabel;
@property (strong, nonatomic) UILabel *plotLabel;
@property (strong, nonatomic) UIImageView *posterImageView;
@property (strong, nonatomic) UILabel *releasedLabel;
@property (strong, nonatomic) UILabel *runtimeLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *imdbRatingBgL;
@property (strong, nonatomic) UILabel *imdbRatingBgR;
@property (strong, nonatomic) UIImageView *imdbRatingView;
@property (strong, nonatomic) UILabel *imdbRatingLabel;
@property (strong, nonatomic) UILabel *metascoreText;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *likeButton;
@property (nonatomic, strong) DGActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *activityLabel;
@end

@implementation MovieInfoView

- (instancetype)init{
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.actorLabel];
        [self.containerView addSubview:self.titleLabel];
        [self.containerView addSubview:self.writerLabel];
        [self.containerView addSubview:self.genreLabel];
        [self.containerView addSubview:self.runtimeLabel];
        [self.containerView addSubview:self.directorLabel];
        [self.containerView addSubview:self.metascoreLabel];
        [self.containerView addSubview:self.languageLabel];
        [self.containerView addSubview:self.imdbRatingBgL];
        [self.containerView addSubview:self.imdbRatingBgR];
        [self.containerView addSubview:self.imdbRatingView];
        [self.containerView addSubview:self.imdbRatingLabel];
        [self.containerView addSubview:self.plotLabel];
        [self.containerView addSubview:self.metascoreText];
        [self.containerView addSubview:self.releasedLabel];
        [self.containerView addSubview:self.posterImageView];
        [self.containerView addSubview:self.likeButton];
        [self addSubview:self.cancelButton];
        [self.containerView addSubview:self.activityView];
        [self.activityView addSubview:self.activityLabel];
    }
    return self;
}
- (void)setMovieInfo:(MovieInfo *)movieInfo{
    _movieInfo = movieInfo;
    Movie *movie = movieInfo.movie;
    NSLog(@"Movie type: %u", movieInfo.type);
    self.likeButton.selected = NO;
    if (movieInfo.type == MovieInfoTypeActor){
        self.actorLabel.layer.borderWidth = BorderWidthS;
    }else{
        self.actorLabel.layer.borderWidth = BorderWidth;
    }
    if (movieInfo.type == MovieInfoTypeDirector){
        self.directorLabel.layer.borderWidth = BorderWidthS;
    }else{
        self.directorLabel.layer.borderWidth = BorderWidth;
    }
    if (movieInfo.type == MovieInfoTypeGenre){
        self.genreLabel.layer.borderWidth = BorderWidthS;
    }else{
        self.genreLabel.layer.borderWidth = BorderWidth;
    }
    if (movieInfo.type == MovieInfoTypeReleased){
        self.releasedLabel.layer.borderWidth = BorderWidthS;
    }else{
        self.releasedLabel.layer.borderWidth = BorderWidth;
    }
    if (movieInfo.type == MovieInfoTypeWriter){
        self.writerLabel.layer.borderWidth = BorderWidthS;
    }else{
        self.writerLabel.layer.borderWidth = BorderWidth;
    }
    if (movieInfo.type == MovieInfoTypePlot){
        self.plotLabel.layer.borderWidth = BorderWidthS;
    }else{
        self.plotLabel.layer.borderWidth = BorderWidth;
    }
    if (movieInfo.type == MovieInfoTypeRating){
        self.imdbRatingLabel.layer.borderWidth = BorderWidthS;
    }else{
        self.imdbRatingLabel.layer.borderWidth = BorderWidth;
    }
    
    [self.posterImageView sd_setImageWithURL:[NSURL URLWithString:movie.Poster]];
    self.titleLabel.text = movie.Title;
    self.actorLabel.attributedText = [self getAttributeStringWithContent:movie.Actors contentSize:15 title:@"Stars: " titleSize:18];
    self.genreLabel.text = movie.Genre;
    self.runtimeLabel.attributedText = [self getAttributeStringWithContent:movie.Runtime contentSize:14 title:@"Running Time: " titleSize:15];
    self.directorLabel.attributedText = [self getAttributeStringWithContent:movie.Director contentSize:15 title:@"Director: " titleSize:18];
    self.metascoreLabel.text = [NSString stringWithFormat:@" %@ ", movie.Metascore];
    self.languageLabel.attributedText = [self getAttributeStringWithContent:movie.Language contentSize:14 title:@"Language: " titleSize:15];
    self.imdbRatingLabel.attributedText = [self getRatingAttributeStringWithScore:movie.imdbRating];
    self.plotLabel.text = movie.Plot;
    self.releasedLabel.attributedText = [self getAttributeStringWithContent:movie.Released contentSize:14 title:@"Released: " titleSize:15];
    self.writerLabel.attributedText = [self getAttributeStringWithContent:movie.Writer contentSize:15 title:@"Writer: " titleSize:18];
    
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView).offset(-10);
    }];
    [self.genreLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.titleLabel);
    }];
    [self.metascoreLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.genreLabel.mas_bottom).offset(5);
        make.width.mas_equalTo(26);
        make.height.mas_equalTo(23);
    }];
    [self.runtimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.titleLabel);
    }];
    [self.languageLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.titleLabel);
    }];
    [self.imdbRatingBgL mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(22 * [movie.imdbRating floatValue]);
        make.left.top.bottom.equalTo(self.imdbRatingView);
    }];
    [self.plotLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.titleLabel);
    }];
    [self.directorLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.titleLabel);
    }];
    [self.writerLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.titleLabel);
    }];
    [self.actorLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.titleLabel);
    }];
    [self.releasedLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.titleLabel);
    }];
    
    [self.imdbRatingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.posterImageView);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(220);
        make.top.equalTo(self.posterImageView.mas_bottom).offset(10);
    }];
    [self.imdbRatingLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imdbRatingView.mas_right).offset(3);
        make.top.equalTo(self.imdbRatingView).offset(2);
        make.height.mas_equalTo(self.imdbRatingView);
    }];
    [self.imdbRatingBgR mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imdbRatingBgL.mas_right);
        make.right.top.bottom.equalTo(self.imdbRatingView);
    }];
    [self.likeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.right.equalTo(self.titleLabel);
        make.centerY.equalTo(self.imdbRatingLabel);
    }];
    
    [self layoutIfNeeded];
}
- (void)likeButtonClick:(UIButton *)button{
    if (button.tag == 0){
        button.tag = 1;
        button.selected = YES;
    }else{
        button.tag = 0;
        button.selected = NO;
    }
    [self sendRequestWithTag:button.tag];
}
- (void)sendRequestWithTag:(NSInteger)tag{
    NSLog(@"%@", self.movieInfo.movie.Title);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *param = @{
                            @"movie" : self.movieInfo.movie.Title,
                            @"like" : @(tag)
                            };
    [manager POST:kLikeUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger status = [responseObject[@"status"] integerValue];
        if (status == 1) {

        }else{
            if (tag == 0) {
                self.likeButton.selected = NO;
            }else{
                self.likeButton.selected = YES;
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (tag == 0) {
            self.likeButton.selected = NO;
        }else{
            self.likeButton.selected = YES;
        }
    }];
}
- (NSAttributedString *)getRatingAttributeStringWithScore:(NSString *)score{
    NSString *string = [score stringByAppendingString:@"/10"];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:string];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[self colorWithRed:254 green:202 blue:28] range:NSMakeRange(0, [score length])];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(0, [score length])];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[self colorWithRed:151 green:151 blue:151] range:NSMakeRange([score length], 3)];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange([score length],3)];
    return attributeString;
}
- (NSAttributedString *)getAttributeStringWithContent:(NSString *)content contentSize:(CGFloat)contentSize title:(NSString *)title titleSize:(CGFloat)titleSize{
    NSString *string = [title stringByAppendingString:content];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:string];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[self colorWithRed:102 green:102 blue:102] range:NSMakeRange(0, [title length])];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:titleSize] range:NSMakeRange(0, [title length])];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[self colorWithRed:151 green:151 blue:151] range:NSMakeRange([title length], [content length])];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT" size:contentSize] range:NSMakeRange([title length], [content length])];
    return attributeString;
}
- (UIColor *)colorWithRed:(int)red green:(int)green blue:(int)blue{
    UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    return color;
}
- (void)layoutSubviews{
    [self.activityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.activityView);
        make.bottom.equalTo(self.activityView).offset(-15);
    }];
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.mas_equalTo(160);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(500);
    }];
    
    [self.posterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20);
        make.left.equalTo(self).offset(10);
        make.width.mas_equalTo(144);
        make.height.mas_equalTo(213.6);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.posterImageView.mas_right).offset(15);
        make.top.equalTo(self.posterImageView);
    }];
    [self.genreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
    }];
    [self.metascoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.genreLabel.mas_bottom).offset(5);
        make.width.mas_equalTo(26);
        make.height.mas_equalTo(23);
    }];
    [self.runtimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.metascoreLabel.mas_bottom).offset(5);
    }];
    [self.languageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.runtimeLabel.mas_bottom).offset(5);
    }];
    
    [self.plotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.posterImageView);
        make.top.equalTo(self.imdbRatingView.mas_bottom).offset(5);
    }];
    [self.directorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.posterImageView);
        make.top.equalTo(self.plotLabel.mas_bottom).offset(5);
    }];
    [self.actorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.posterImageView);
        make.top.equalTo(self.directorLabel.mas_bottom).offset(5);
    }];
    [self.writerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.posterImageView);
        make.top.equalTo(self.actorLabel.mas_bottom).offset(5);
    }];
    [self.metascoreText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.metascoreLabel.mas_right).offset(3);
        make.top.bottom.equalTo(self.metascoreLabel);
    }];
    [self.releasedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.languageLabel.mas_bottom).offset(5);
    }];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView.mas_bottom).offset(5);
        make.width.height.mas_equalTo(34);
        make.centerX.equalTo(self);
    }];
}
- (void)dismissView{
    if ([self.delegate respondsToSelector:@selector(dismissMovieInfoClick)]) {
        [self.delegate dismissMovieInfoClick];
    }
}
-(UILabel *)actorLabel{
    if (!_actorLabel) {
        UILabel *label = [[UILabel alloc]init];
        self.actorLabel = label;
        label.layer.borderWidth = BorderWidth;
        label.layer.borderColor = [[UIColor redColor] CGColor];
        label.numberOfLines = 0;
        
    }
    return _actorLabel;
}
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc]init];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        label.textColor = [UIColor blackColor];
        self.titleLabel = label;
        label.numberOfLines = 0;
        
    }
    return _titleLabel;
}
- (UIImageView *)posterImageView{
    if (!_posterImageView) {
        UIImageView *imageView = [[UIImageView alloc]init];
        self.posterImageView = imageView;
        
    }
    return _posterImageView;
}

- (UILabel *)genreLabel{
    if (!_genreLabel) {
        UILabel *label = [[UILabel alloc]init];
//        label.backgroundColor = [UIColor blueColor];
        label.layer.borderWidth = BorderWidth;
        label.layer.borderColor = [[UIColor redColor] CGColor];
        label.textColor = [self colorWithRed:123 green:123 blue:123];
        label.font = [UIFont fontWithName:@"ArialMT" size:15];
        label.numberOfLines = 0;
        self.genreLabel = label;
    }
    return _genreLabel;
}
- (UILabel *)runtimeLabel{
    if (!_runtimeLabel) {
        UILabel *label = [[UILabel alloc]init];
//        label.backgroundColor = [UIColor brownColor];

        label.numberOfLines = 0;
        self.runtimeLabel = label;
    }
    return _runtimeLabel;
}
- (UILabel *)directorLabel{
    if (!_directorLabel) {
        UILabel *label = [[UILabel alloc]init];
//        label.backgroundColor = [UIColor purpleColor];
        label.numberOfLines = 0;
        label.layer.borderWidth = BorderWidth;
        label.layer.borderColor = [[UIColor redColor] CGColor];
        self.directorLabel = label;
    }
    return _directorLabel;
}
- (UILabel *)writerLabel{
    if (!_writerLabel) {
        UILabel *label = [[UILabel alloc]init];
        //        label.backgroundColor = [UIColor purpleColor];
        label.numberOfLines = 3;
        label.layer.borderWidth = BorderWidth;
        label.layer.borderColor = [[UIColor redColor] CGColor];
        self.writerLabel = label;
    }
    return _writerLabel;
}
- (UILabel *)metascoreLabel{
    if (!_metascoreLabel) {
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [self colorWithRed:17 green:210 blue:78];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"ArialMT" size:16];
        label.numberOfLines = 0;
        self.metascoreLabel = label;
    }
    return _metascoreLabel;
}
- (UILabel *)languageLabel{
    if (!_languageLabel) {
        UILabel *label = [[UILabel alloc]init];
//        label.backgroundColor = [UIColor orangeColor];
        label.numberOfLines = 0;
        self.languageLabel = label;
    }
    return _languageLabel;
}
- (UIImageView *)imdbRatingView{
    if (!_imdbRatingView) {
        UIImageView *image = [[UIImageView alloc]init];
        
        image.image = [UIImage imageNamed:@"rating"];
        self.imdbRatingView = image;
    }
    return _imdbRatingView;
}
- (UILabel *)imdbRatingLabel{
    if (!_imdbRatingLabel) {
        UILabel *label = [[UILabel alloc]init];
//        label.backgroundColor = [UIColor blueColor];
        label.numberOfLines = 0;
        label.layer.borderWidth = BorderWidth;
        label.layer.borderColor = [[UIColor redColor] CGColor];
        self.imdbRatingLabel = label;
    }
    return _imdbRatingLabel;
}
- (UILabel *)imdbRatingBgL{
    if (!_imdbRatingBgL) {
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [self colorWithRed:254 green:202 blue:28];
        self.imdbRatingBgL = label;
    }
    return _imdbRatingBgL;
}
- (UILabel *)imdbRatingBgR{
    if (!_imdbRatingBgR) {
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor lightGrayColor];
        self.imdbRatingBgR = label;
    }
    return _imdbRatingBgR;
}
- (UILabel *)plotLabel{
    if (!_plotLabel) {
        UILabel *label = [[UILabel alloc]init];
//        label.backgroundColor = [UIColor lightGrayColor];
        label.font = [UIFont fontWithName:@"ArialMT" size:15];
        label.textColor = [self colorWithRed:151 green:151 blue:151];
        label.numberOfLines = 0;
        label.layer.borderWidth = BorderWidth;
        label.layer.borderColor = [[UIColor redColor] CGColor];
        self.plotLabel = label;
    }
    return _plotLabel;
}
- (UILabel *)metascoreText{
    if (!_metascoreText) {
        UILabel *label = [[UILabel alloc]init];
        label.font = [UIFont fontWithName:@"ArialMT" size:15];
        label.text = @"Metascore";
        label.textColor = [self colorWithRed:151 green:151 blue:151];
        self.metascoreText = label;
    }
    return _metascoreText;
}
- (UILabel *)releasedLabel{
    if (!_releasedLabel) {
        UILabel *label = [[UILabel alloc]init];
        //        label.backgroundColor = [UIColor orangeColor];
        label.layer.borderWidth = BorderWidth;
        label.layer.borderColor = [[UIColor redColor] CGColor];
        label.numberOfLines = 0;
        self.releasedLabel = label;
    }
    return _releasedLabel;
}
- (UIView *)containerView{
    if (!_containerView) {
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = YES;
        self.containerView = view;
    }
    return _containerView;
}
- (UIButton *)cancelButton{
    if (!_cancelButton) {
        UIButton *button = [[UIButton alloc]init];
//        button.backgroundColor = [UIColor blueColor];
        button.layer.cornerRadius = 17;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 1.5;
        button.layer.borderColor = [[UIColor whiteColor] CGColor];
        [button setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchDown];
        self.cancelButton = button;
    }
    return _cancelButton;
}
- (UIButton *)likeButton{
    if (!_likeButton){
        UIButton *button = [[UIButton alloc]init];
//        button.backgroundColor = [UIColor purpleColor];
        [button setImage:[UIImage imageNamed:@"like"] forState:UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
        button.tag = 0;
        [button addTarget:self action:@selector(likeButtonClick:) forControlEvents:UIControlEventTouchDown];
        self.likeButton = button;
    }
    return _likeButton;
}
- (DGActivityIndicatorView *)activityView{
    if (!_activityView) {
        DGActivityIndicatorView *activityView = [[DGActivityIndicatorView alloc]initWithType:DGActivityIndicatorAnimationTypeBallSpinFadeLoader tintColor:systemColor size:50.0f];
        activityView.hidden = YES;
        activityView.layer.cornerRadius= 5;
        activityView.layer.masksToBounds = YES;
        activityView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.8];
        self.activityView = activityView;
    }
    return _activityView;
}
- (UILabel *)activityLabel{
    if (!_activityLabel) {
        UILabel *label = [[UILabel alloc]init];
        label.text = @"Loading...";
        label.textColor = systemColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:16];
        self.activityLabel = label;
    }
    return _activityLabel;
}
@end
