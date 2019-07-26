//
//  LZCameraVideoEditMusicViewController.m
//  LZCamera
//
//  Created by Dear.Q on 2019/7/25.
//

#import "LZCameraVideoEditMusicViewController.h"
#import "LZCameraEditorVideoMusicContainerView.h"
#import "LZCameraToolkit.h"

/** 背景音音量 */
static CGFloat BGMVolume = 0.5;
@interface LZCameraVideoEditMusicViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *previewImgView;
@property (weak, nonatomic) IBOutlet LZCameraEditorVideoMusicContainerView *musicView;

/** 预览层 */
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
/** 计时器 */
@property (strong, nonatomic) NSTimer *timer;
/** 背景音乐播放器 */
@property (strong, nonatomic) AVAudioPlayer *BGMPlayer;
/** 背景音乐 */
@property (strong, nonatomic) LZCameraEditorMusicModel *musicModel;

@end

@implementation LZCameraVideoEditMusicViewController

// AMRK: - Initialization
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupUI];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self stopTimer];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	self.playerLayer.frame = self.previewImgView.layer.frame;
}

- (void)dealloc {
	LZCameraLog();
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: - Public
+ (instancetype)instance {
	
	NSBundle *bundle = LZCameraNSBundle(@"LZCameraEditor");
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LZCameraVideoEditMusicViewController"
														 bundle:bundle];
	return storyboard.instantiateInitialViewController;
}

// MARK: - UI Action
- (void)popDidClick {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneDidClick {
	
	[self stopTimer];
	[LZCameraToolkit mixAudioForAsset:self.videoURL
							timeRange:self.timeRange
						 audioPathURL:[self fetchBGMURL]
						originalAudio:YES
					   originalVolume:1.0
						  audioVolume:BGMVolume
						   presetName:AVAssetExportPresetMediumQuality
					completionHandler:^(NSURL * _Nullable outputFileURL, BOOL success) {
						if (success) {
							if (self.VideoEditCallback) {
								
								UIImage *previewImage = [LZCameraToolkit thumbnailAtFirstFrameForVideoAtURL:outputFileURL];
								self.VideoEditCallback(outputFileURL, previewImage);
							}
							[self.navigationController dismissViewControllerAnimated:YES completion:nil];
						}
					}];
}

// MARK: - Private
- (void)setupUI {
	
	self.title = @"加音乐";
	
	[self buildPlayer];
	[self startTimer];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(appResignActive)
	 name:UIApplicationWillResignActiveNotification
	 object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(appBecomeActive)
	 name:UIApplicationDidBecomeActiveNotification
	 object:nil];
	
	__weak typeof(self) weakSelf = self;
	self.musicView.TapOriginalMusicCallback = ^{
		
		typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf.BGMPlayer pause];
		strongSelf.BGMPlayer = nil;
		[strongSelf startTimer];
	};
	self.musicView.TapMusicCallback = ^(LZCameraEditorMusicModel * _Nonnull musicModel) {
		
		typeof(weakSelf) strongSelf = weakSelf;
		strongSelf.musicModel = musicModel;
		[strongSelf stopTimer];
		[strongSelf cutBGMusic];
	};
	
	self.navigationItem.leftBarButtonItem =
	[[UIBarButtonItem alloc] initWithTitle:@"返回"
									 style:UIBarButtonItemStylePlain
									target:self
									action:@selector(popDidClick)];
	self.navigationItem.rightBarButtonItem =
	[[UIBarButtonItem alloc] initWithTitle:@"完成"
									 style:UIBarButtonItemStylePlain
									target:self
									action:@selector(doneDidClick)];
}

- (void)cutBGMusic {
	
	CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, self.timeRange.duration);
	NSURL *musicURL = [self fetchBGMURL];
	[LZCameraToolkit cutAsset:musicURL
						 type:LZCameraAssetTypeM4A
					 timeRane:timeRange
			completionHandler:^(NSURL * _Nullable outputFileURL, BOOL success) {
				if (success) {
					
					NSError *error;
					self.BGMPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:outputFileURL error:&error];
					if (error == nil) {
						
						self.BGMPlayer.numberOfLoops = -1;
						self.BGMPlayer.volume = BGMVolume;
						[self.BGMPlayer prepareToPlay];
						[self startTimer];
					}
				}
	}];
}

- (NSURL *)fetchBGMURL {
	
	NSBundle *bundle = LZCameraNSBundle(@"LZCameraEditor");
	NSString *musicPath = [bundle pathForResource:self.musicModel.thumbnail ofType:@"mp3"];
	NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
	return musicURL;
}

- (void)buildPlayer {
	
	if (self.playerLayer) {
		
		[self.playerLayer.player pause];
		[self.playerLayer removeFromSuperlayer];
	}
	AVAsset *asset = [AVAsset assetWithURL:self.videoURL];
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
	AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
	self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
	self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
	self.playerLayer.frame = self.previewImgView.layer.frame;
	[self.view.layer insertSublayer:self.playerLayer above:self.previewImgView.layer];
}

- (void)startTimer {
	
	[self stopTimer];
	CGFloat duration = CMTimeGetSeconds(self.timeRange.duration);
	self.timer =
	[NSTimer scheduledTimerWithTimeInterval:duration
									 target:self
								   selector:@selector(playPartVideo:)
								   userInfo:nil
									repeats:YES];
	[self.timer fire];
	[self.BGMPlayer play];
}

- (void)stopTimer {
	
	[self.timer invalidate];
	self.timer = nil;
	[self.playerLayer.player pause];
	[self.BGMPlayer pause];
}

- (void)playPartVideo:(NSTimer *)timer {
	
	[self.playerLayer.player play];
	[self.playerLayer.player seekToTime:[self getStartTime]
						toleranceBefore:kCMTimeZero
						 toleranceAfter:kCMTimeZero];
}

- (CMTime)getStartTime {
	
	CMTime time = self.timeRange.start;
	if (NO == CMTIME_IS_VALID(time)) {
		time = kCMTimeZero;
	}
	return time;
}

// MARK: - Obasever
- (void)appResignActive {
	[self stopTimer];
}

- (void)appBecomeActive {
	[self startTimer];
}

@end