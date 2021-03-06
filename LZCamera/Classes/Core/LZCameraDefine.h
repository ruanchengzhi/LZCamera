//
//  LZCameraDefine.h
//  LZCamera
//
//  Created by Dear.Q on 2018/11/21.
//

#ifndef LZCameraDefine_h
#define LZCameraDefine_h

/**
 错误码
 
 - LZCameraErrorFailedToAddInput: 添加输入失败
 - LZCameraErrorFailedToAddOutput: 添加输出失败
 - LZCameraErrorInvalideFileOutputURL: 文件输出路径无效
 - LZCameraErrorDiskFull: 储存空间满
 - LZCameraErrorSessionInterrupted: 被中断，比如：后台、电话、提醒
 - LZCameraErrorAuthorization: 权限
 */
typedef NS_ENUM(NSInteger, LZCameraErrorCode) {
    LZCameraErrorFailedToAddInput = 100001,
    LZCameraErrorFailedToAddOutput,
    LZCameraErrorInvalideFileOutputURL,
    LZCameraErrorDiskFull,
    LZCameraErrorSessionInterrupted,
	LZCameraErrorAuthorization,
};

/**
 资源类型

 - LZCameraAssetTypeMov: mov
 - LZCameraAssetTypeMp4: mp4
 - LZCameraAssetTypeM4A: m4a
 */
typedef NS_ENUM(NSUInteger, LZCameraAssetType) {
	LZCameraAssetTypeMov,
	LZCameraAssetTypeMp4,
	LZCameraAssetTypeM4A,
};

/**
 水印位置

 - LZCameraWatermarkLocationCenter: 中心，默认
 - LZCameraWatermarkLocationLeftTop: 左上
 - LZCameraWatermarkLocationLeftBottom: 左下
 - LZCameraWatermarkLocationRightTop: 右上
 - LZCameraWatermarkLocationRightBottom: 右下
 */
typedef NS_ENUM(NSUInteger, LZCameraWatermarkLocation) {
	LZCameraWatermarkLocationCenter,
	LZCameraWatermarkLocationLeftTop,
	LZCameraWatermarkLocationLeftBottom,
	LZCameraWatermarkLocationRightBottom,
	LZCameraWatermarkLocationRightTop,
};

/** 错误域标识 */
FOUNDATION_EXPORT NSString * _Nullable const LZCameraErrorDomain;
/** 监听完成 */
FOUNDATION_EXPORT NSString * _Nullable const LZCameraObserver_Complete;

/** 捕捉静态图片完成回调 */
typedef void(^LZCameraCaptureStillImageCompletionHandler)(UIImage * _Nonnull stillImage, NSError * _Nullable error);
/** 捕捉视频完成回调 */
typedef void(^LZCameraCaptureVideoCompletionHandler)(NSURL * _Nonnull videoURL, NSError * _Nullable error);
/** 摄像缩放完成回调 */
typedef void(^ _Nullable LZCameraZoomCompletionHandler)(CGFloat zoomValue);
/** 摄像记录时间进度回调 */
typedef void(^LZCameraRecordedDurationProgressHandler)(CMTime duration);
/** 捕捉元数据完成回调 */
typedef void(^LZCameraCaptureMetaDataCompletionHandler)(NSArray<AVMetadataObject *> * _Nullable metadataObjects, NSError * _Nullable error);

/**
 播放声音
 
 @param soundName 声音名称
 @param inBundle Bundle 名称
 */
void lzPlaySound(NSString * _Nullable soundName, NSString * _Nullable inBundle);

#endif /* LZCameraDefine_h */
