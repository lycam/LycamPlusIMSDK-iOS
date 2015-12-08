//
//  LycamPlusIM.h
//  Pods
//
//  Created by xman on 15/12/7.
//
//

#import <Foundation/Foundation.h>

typedef void (^LCPResultBlock)(BOOL succ, NSError *error);
typedef void (^LCPBlock)(LCPResultBlock callback);
// notifications
extern NSString * const kLCPConnectionStatusChangedNotification;
extern NSString * const kLCPDidReceiveMessageNotification;
extern NSString * const kLCPDidReceivePresenceNotification;
// qos level
typedef NS_ENUM(UInt8, YBQosLevel) {
    kYBQosLevel0 = 0,
    kYBQosLevel1 = 1,
    kYBQosLevel2 = 2,
};
@interface LCPPublishOption : NSObject
@property (nonatomic, assign) UInt8 qosLevel;                   // qos level
@property (nonatomic, assign) BOOL retained;                    // is retained
+ (instancetype)optionWithQos:(YBQosLevel)qosLevel retained:(BOOL)retained;
@end

@interface LycamPlusIM : NSObject

@property (nonatomic,readonly) BOOL isConnected;
@property (nonatomic,copy) NSString* appKey;

+ (BOOL)initWithAppkey:(NSString *)appkey;
+ (BOOL)close;
+ (void)subscribe:(NSString *)topic qos:(UInt8)qosLevel resultBlock:(LCPResultBlock)resultBlock;
+ (void)unsubscribe:(NSString *)topic resultBlock:(LCPResultBlock)resultBlock;
+ (void)publish:(NSString *)topic msg:(NSString *) msg option:(LCPPublishOption *)option resultBlock:(LCPResultBlock)resultBlock;

@end
