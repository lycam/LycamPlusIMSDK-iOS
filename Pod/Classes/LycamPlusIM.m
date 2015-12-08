//
//  LycamPlusIM.m
//  Pods
//
//  Created by xman on 15/12/7.
//
//

#import "LycamPlusIM.h"
#import <SIOSocket/SIOSocket.h>

NSString * const kLCPConnectionStatusChangedNotification = @"LCPConnectionStatusChangedNotificationKey";
NSString * const kLCPDidReceiveMessageNotification= @"LCPDidReceiveMessageNotificationKey";
NSString * const kLCPDidReceivePresenceNotification= @"LCPDidReceivePresenceNotificationLey";
@interface LycamPlusIM()
@property (nonatomic,readonly) SIOSocket* socket;
@end

static LycamPlusIM *_lycamplusIM = nil;
NSString * const kServiceURL = @"https://im.lycam.tv";
//NSString * const kServiceURL = @"http://sock.yunba.io:3000";
@implementation LycamPlusIM

-(id) init{
    if(self = [super init]){
        _isConnected = NO;
    }
    return self;
}


+ (LycamPlusIM*) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lycamplusIM = [[LycamPlusIM alloc] init];

    });
    return _lycamplusIM;
}
+ (BOOL) close{
    LycamPlusIM * im = [LycamPlusIM sharedInstance];
    if(im.isConnected){
        [im.socket close];
        return YES;
    }
    else{
        return NO;
    }
}

-(void) connect:(LCPResultBlock) callback{
    if(_socket==nil || self.isConnected==NO) {
        [SIOSocket socketWithHost: kServiceURL response: ^(SIOSocket *socket) {
            _socket = socket;
            _isConnected = YES;
            [_socket on:@"connect" callback:^(SIOParameterArray *data ) {
                NSLog(@"socket connected");
                
                [self.socket on:@"message" callback:^(SIOParameterArray *data ) {
                    NSLog(@"%@",data);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLCPDidReceiveMessageNotification object:data];
                }];
                NSDictionary * body = @{@"appkey": self.appKey};
                [self.socket on:@"connack" callback:^(SIOParameterArray *data ) {
                    NSLog(@"%@",data);
                    callback(YES,nil);
                    return ;
                }];
                [self.socket emit:@"connect_v2" args:@[body]];
                
                return ;
            }];
        }];
        
        
    }
    else{
        callback(YES,nil);
        return ;

    }
    

}

-(void) connectAndDoingWithBlock:(LCPBlock)block callback:(LCPResultBlock) callback{
    [self connect:^(BOOL succ, NSError *error) {
        if(succ==NO){
            callback(succ,error);
            return;
        }
        block(callback);
    }];
}


+ (BOOL)initWithAppkey:(NSString *)appkey{
//    [[self sharedInstance] connect];
    [self sharedInstance].appKey =appkey;
    return YES;
}


#define GEN_MESSAGE_ID [NSString stringWithFormat:@"%d%d%d",rand(),rand(),rand()]
//#define CONNECT_AND_DOING(callback)    \
//    [self connect:^(BOOL succ, NSError *error) { \
//        if(succ==NO){ \
//            callback(succ,error); \
//            return; \
//        }\



+(void)subscribe:(NSString *)topic qos:(UInt8)qosLevel resultBlock:(LCPResultBlock)resultBlock{
    LycamPlusIM * im = [LycamPlusIM sharedInstance];

    NSString *msgId =  GEN_MESSAGE_ID;

    NSDictionary * body = @{@"topic": topic, @"qos": @(qosLevel), @"messageId": msgId};
    
    LCPBlock block = ^(LCPResultBlock cb){
        
        [im.socket on:@"suback" callback:^(SIOParameterArray *data) {
            NSLog(@"%@",data);
            if(resultBlock){
                cb(YES,nil);
                return ;
            }
        }];
        
        [im.socket emit:@"subscribe" args:@[body]];
    };

    [im connectAndDoingWithBlock:block callback:resultBlock];

}

+ (void)unsubscribe:(NSString *)topic resultBlock:(LCPResultBlock)resultBlock{
    LycamPlusIM * im = [LycamPlusIM sharedInstance];

    NSString *msgId =  GEN_MESSAGE_ID;
    NSDictionary * body = @{@"topic": topic,@"messageId": msgId};
    
    
    LCPBlock block = ^(LCPResultBlock cb){
        
        [im.socket on:@"unsuback" callback:^(SIOParameterArray *data) {
            NSLog(@"%@",data);
            if(resultBlock){
                cb(YES,nil);
                return ;
            }
        }];
        
        [im.socket emit:@"unsubscribe" args:@[body]];
    };
    
    [im connectAndDoingWithBlock:block callback:resultBlock];
}

+ (void)publish:(NSString *)topic msg:(NSString *) msg option:(LCPPublishOption *)option resultBlock:(LCPResultBlock)resultBlock{
    LycamPlusIM * im = [LycamPlusIM sharedInstance];

    NSString *msgId =  GEN_MESSAGE_ID;
    
    NSDictionary * body = @{@"topic": topic, @"qos": @(kYBQosLevel1), @"msg":msg,@"messageId": msgId};
    
    LCPBlock block = ^(LCPResultBlock cb){
        
        [im.socket on:@"puback" callback:^(SIOParameterArray *data) {
            NSLog(@"%@",data);
            if(resultBlock){
                resultBlock(YES,nil);
                return ;
            }
        }];
        
        [im.socket emit:@"publish" args:@[body]];
    };
    
    [im connectAndDoingWithBlock:block callback:resultBlock];
    
    
    

}




@end
