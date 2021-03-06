//
//  VoicePlayer.h
//  VoiceEncoder
//
//  Created by godliu on 14-10-24.
//  Copyright (c) 2014年 godliu. All rights reserved.
//
#if !(TARGET_IPHONE_SIMULATOR)
#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, VEAudioPlayerType2)
{
    VE2_WavPlayer
    , VE2_SoundPlayer
};

@interface VoicePlayer2 : NSObject
{
    void *player;
}

- (id) init;
- (BOOL) isStopped;
- (void) setFreqs:(int *)_freqs freqCount:(int)_freqCount;
- (void) setVolume:(double)_volume;
- (void) play:(NSString *)_text playCount:(long)_playCount muteInterval:(int)_muteInterval;
- (void) stop;
- (void) playString:(NSString *)_text playCount:(long)_playCount muteInterval:(int)_muteInterval;
- (void) playWiFi:(char *)_mac macLen:(int)_macLen pwd:(NSString *)_pwd playCount:(long)_playCount muteInterval:(int)_muteInterval;
- (void) playSSIDWiFi:(NSString *)_ssid pwd:(NSString *)_pwd playCount:(long)_playCount muteInterval:(int)_muteInterval;
- (void) playPhone:(NSString *)_imei phoneName:(NSString *)_phoneName playCount:(long)_playCount muteInterval:(int)_muteInterval;
//zs
- (void) playZSSSIDWiFi:(NSString *)_ssid pwd:(NSString *)_pwd phone:(NSString *)_phone playCount:(long)_playCount muteInterval:(int)_muteInterval;

- (void) setPlayerType:(VEAudioPlayerType2)_type;
- (void) setWavPlayer:(NSString *)_fileName;
- (void) mixWav:(NSString *)_wavFileName volume:(float)_volume muteInterval:(int)_muteInterval;

- (void) onPlayStart;
- (void) onPlayEnd;

- (void) string2Bytes:(NSString *)_s rbytes:(char *)_rbytes rbytesLen:(int *)_rbytesLen;




@end
#endif
