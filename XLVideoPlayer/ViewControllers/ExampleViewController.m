//
//  ExampleViewController.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/23.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin
//  博客：http://www.jianshu.com/users/edad244257e2/latest_articles

#import "ExampleViewController.h"
#import "AppDelegate.h"
#import "VideoDetailViewController.h"
#import "XLVideoCell.h"
#import "XLVideoPlayer.h"
#import "XLVideoItem.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import <AVFoundation/AVFoundation.h>

#define videoListUrl @"http://c.3g.163.com/nc/video/list/VAP4BFR16/y/0-10.html"

UIImage* getVideoImage(NSString* videoURL, float time)
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime ctime = CMTimeMakeWithSeconds(time, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:ctime actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

@interface ExampleViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    NSIndexPath *_indexPath;
    XLVideoPlayer *_player;
    CGRect _currentPlayCellRect;
}

@property (weak, nonatomic) IBOutlet UITableView *exampleTableView;

@property (nonatomic, strong) NSMutableArray *videoArray;

@end

@implementation ExampleViewController

- (instancetype)init {
    if (self = [super init]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"ExampleViewController" owner:nil options:nil].lastObject;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.title = @"Video List";
    }
    return self;
}

- (NSMutableArray *)videoArray {
    if (!_videoArray) {
        _videoArray = [NSMutableArray array];
    }
    return _videoArray;
}

#pragma mark - life cyle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.exampleTableView.estimatedRowHeight = 100;

    [self fetchVideoListData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_player destroyPlayer];
    _player = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - network

- (void)fetchVideoListData {
    /*
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:videoListUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//        NSLog(@"%@", responseObject);
        NSArray *dataArray = responseObject[@"VAP4BFR16"];
        for (NSDictionary *dict in dataArray) {
            [self.videoArray addObject:[XLVideoItem mj_objectWithKeyValues:dict]];
        }
        [self.exampleTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
    /*/
    NSString* docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator* dirEnum = [fm enumeratorAtPath:docPath];
    NSString* thumbnailDirectoryPath = [AppDelegate ensureDirectory:@"thumbnail"];
    for (NSString* path in dirEnum)
    {
        if (path.pathComponents.count > 1)
            continue;
        
        NSString* extName = [[path pathExtension] lowercaseString];
        if (![extName isEqualToString:@"mp4"] && ![extName isEqualToString:@"avi"] && ![extName isEqualToString:@"mov"] && ![extName isEqualToString:@"m4v"] && ![extName isEqualToString:@"mkv"])
            continue;
        
        XLVideoItem* videoItem = [[XLVideoItem alloc] init];
        videoItem.mp4_url = [docPath stringByAppendingPathComponent:path];
        videoItem.title = [path lastPathComponent];
        NSString* thumbnailPath = [[thumbnailDirectoryPath stringByAppendingPathComponent:path] stringByAppendingPathExtension:@"png"];
        if (![fm fileExistsAtPath:thumbnailPath])
        {
            UIImage* thumbnail = getVideoImage(videoItem.mp4_url, 0.5f);
            NSData* thumbnailData = UIImagePNGRepresentation(thumbnail);
            [thumbnailData writeToFile:thumbnailPath atomically:YES];
        }
        videoItem.cover = [NSString stringWithFormat:@"file://%@", thumbnailPath];
        [self.videoArray addObject:videoItem];
    }
    [self.exampleTableView reloadData];
    //*/
}

- (void)showVideoPlayer:(UITapGestureRecognizer *)tapGesture {
    [_player destroyPlayer];
    _player = nil;
    
    UIView *view = tapGesture.view;
    XLVideoItem *item = self.videoArray[view.tag - 100];

    _indexPath = [NSIndexPath indexPathForRow:view.tag - 100 inSection:0];
    XLVideoCell *cell = [self.exampleTableView cellForRowAtIndexPath:_indexPath];
    
    _player = [[XLVideoPlayer alloc] init];
    _player.videoUrl = item.mp4_url;
    [_player playerBindTableView:self.exampleTableView currentIndexPath:_indexPath];
    _player.frame = view.bounds;

    [cell.contentView addSubview:_player];  
    
    _player.completedPlayingBlock = ^(XLVideoPlayer *player) {
        [player destroyPlayer];
        _player = nil;
    };
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XLVideoCell *cell = [XLVideoCell videoCellWithTableView:tableView];
    XLVideoItem *item = self.videoArray[indexPath.row];
    cell.videoItem = item;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showVideoPlayer:)];
    [cell.videoImageView addGestureRecognizer:tap];
    cell.videoImageView.tag = indexPath.row + 100;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XLVideoItem *item = self.videoArray[indexPath.row];
    VideoDetailViewController *videoDetailViewController = [[VideoDetailViewController alloc] init];
    videoDetailViewController.videoTitle = item.title;
    videoDetailViewController.mp4_url = item.mp4_url;
    [self.navigationController pushViewController:videoDetailViewController animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.exampleTableView]) {
        
        [_player playerScrollIsSupportSmallWindowPlay:NO];
    }
}

@end
