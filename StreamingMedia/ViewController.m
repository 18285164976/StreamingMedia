//
//  ViewController.m
//  StreamingMedia
//
//  Created by SunLu on 2018/10/10.
//  Copyright © 2018年 Sl. All rights reserved.
//

#import "ViewController.h"
#import <LFLiveSession.h>
#import <Masonry.h>
#import "MediaPlaryerViewController.h"

typedef NS_ENUM(NSUInteger, NetworkStates) {
    NetworkStatesNone, // 没有网络
    NetworkStates2G, // 2G
    NetworkStates3G, // 3G
    NetworkStates4G, // 4G
    NetworkStatesWIFI // WIFI
};

@interface ViewController ()<LFLiveSessionDelegate>
@property(nonatomic,strong) LFLiveSession *liveSession;
@property(nonatomic,strong) LFLiveStreamInfo *liveStreamInfo;

@end

@implementation ViewController
- (LFLiveSession*)liveSession {
    if (!_liveSession) {
        _liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
        _liveSession.preView = self.view;
        _liveSession.delegate = self;
        _liveSession.muted = NO;
        _liveSession.beautyFace = YES;
        _liveSession.running = YES;
        _liveSession.beautyLevel = 1.0;
        _liveSession.brightLevel = 0.5;
    }
    return _liveSession;
}
-(void)dealloc
{
    [self stopLive];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    
    UIButton *startLiveBtn = [[UIButton alloc] init];
    [self.view addSubview:startLiveBtn];
    [startLiveBtn setTitle:@"开始推流" forState:UIControlStateNormal];
    //[startLiveBtn setBackgroundColor:[UIColor greenColor]];
    [startLiveBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [startLiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 50));
        make.center.equalTo(self.view);
    }];
    [startLiveBtn addTarget:self action:@selector(startLive) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *startPlayBtn = [[UIButton alloc] init];
    [self.view addSubview:startPlayBtn];
    [startPlayBtn setTitle:@"开始拉流" forState:UIControlStateNormal];
    //[startPlayBtn setBackgroundColor:[UIColor greenColor]];
    [startPlayBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [startPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 50));
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(startLiveBtn.mas_bottom).offset(20);
    }];
    [startPlayBtn addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)startPlay
{
    NSString *videoPath = @"http://flv-live-ws.xingyan.panda.tv/panda-xingyan/0583a5a8f23b75b354d605ba7ba22f94.flv?0.9217768129892647";
    MediaPlaryerViewController *vc = [[MediaPlaryerViewController alloc] init];
    vc.videoPath = videoPath;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)startLive {
    
    if ([self getNetworkStates] != NetworkStatesNone) {
        self.liveStreamInfo = [LFLiveStreamInfo new];
        self.liveStreamInfo.url = @"rtmp://192.168.1.169:1935/rtmplive/room";
        [self.liveSession startLive:self.liveStreamInfo];
    }
}

- (void)stopLive {
    [self.liveSession stopLive];
}

- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange: (LFLiveState)state
{
    switch (state) {
        case LFLiveReady:
            NSLog(@"准备中...");
            break;
        case LFLivePending:
            NSLog(@"连接中...");
            break;
        case LFLiveStart:
            NSLog(@"已连接");
            break;
        case LFLiveStop:
            NSLog(@"已断开");
            break;
        case LFLiveError:
            NSLog(@"连接出错");
            break;
        case LFLiveRefresh:
            NSLog(@"正在刷新...");
            break;
        default:
            break;
    }
}
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug*)debugInfo
{
    
}
- (void)liveSession:(nullable LFLiveSession*)session errorCode:(LFLiveSocketErrorCode)errorCode
{
//    LFLiveSocketError_PreView = 201,              ///< 预览失败
//    LFLiveSocketError_GetStreamInfo = 202,        ///< 获取流媒体信息失败
//    LFLiveSocketError_ConnectSocket = 203,        ///< 连接socket失败
//    LFLiveSocketError_Verification = 204,         ///< 验证服务器失败
//    LFLiveSocketError_ReConnectTimeOut = 205      ///< 重新连接服务器超时
    switch (errorCode) {
        case LFLiveSocketError_PreView:
            NSLog(@"预览失败");
            break;
        case LFLiveSocketError_GetStreamInfo:
            NSLog(@"获取流媒体信息失败");
            break;
        case LFLiveSocketError_ConnectSocket:
            NSLog(@"连接socket失败");
            break;
        case LFLiveSocketError_Verification:
            NSLog(@"验证服务器失败");
            break;
        case LFLiveSocketError_ReConnectTimeOut:
            NSLog(@"重新连接服务器超时");
            break;
        default:
            break;
    }
    
}



// 判断网络类型
- (NetworkStates)getNetworkStates
{
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    // 保存网络状态
    NetworkStates states = NetworkStatesNone;
    for (id child in subviews) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏码
            int networkType = [[child valueForKeyPath:@"dataNetworkType"] intValue];
            switch (networkType) {
                case 0:
                    //无网模式
                    states = NetworkStatesNone;
                    break;
                case 1:
                    states = NetworkStates2G;
                    break;
                case 2:
                    states = NetworkStates3G;
                    break;
                case 3:
                    states = NetworkStates4G;
                    break;
                case 5:
                {
                    states = NetworkStatesWIFI;
                }
                    break;
                default:
                    break;
            }
        }
    }
    //根据状态选择
    return states;
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
