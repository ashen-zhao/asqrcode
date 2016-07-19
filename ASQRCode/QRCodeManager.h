//
//  QRCodeManager.h
//  QRCodeReader
//
//  Created by ashen on 16/7/15.
//  Copyright © 2016年 <http://www.devashen.com>. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol QRCodeManagerDelegate <NSObject>

- (void)qrCodeResult:(NSString *)result;

@end



@interface QRCodeManager : NSObject

@property (nonatomic, weak) id<QRCodeManagerDelegate> delegate;
//捕捉会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
//展示layer
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

- (void)configureManager:(UIView *)viewPreview;

@end
