//
//  MediaPlaryerViewController.h
//  StreamingMedia
//
//  Created by SunLu on 2018/10/11.
//  Copyright © 2018年 Sl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaPlayer.h>

@interface MediaPlaryerViewController : UIViewController
@property(nonatomic,retain) id <IJKMediaPlayback> player;
@property(nonatomic,strong) NSString *videoPath;
@end
