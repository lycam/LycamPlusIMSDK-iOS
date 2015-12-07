//
//  LycamPlusIM.m
//  Pods
//
//  Created by xman on 15/12/7.
//
//

#import "LycamPlusIM.h"

#import <Socket_IO_Client_Swift/Socket_IO_Client_Swift-Swift.h>
NSString * const kLCPConnectionStatusChangedNotification = @"LCPConnectionStatusChangedNotificationKey";
NSString * const kLCPDidReceiveMessageNotification= @"LCPDidReceiveMessageNotificationKey";
NSString * const kLCPDidReceivePresenceNotification= @"LCPDidReceivePresenceNotificationLey";
@interface LycamPlusIM()
@property (nonatomic,readonly) SocketIOClient* socket;
@end

static LycamPlusIM *_lycamplusIM = nil;
NSString * const kServiceURL = @"mqtt.lycam.tv:3000";
@implementation LycamPlusIM
{
    SocketIOClient* _socket;
}

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
    if(_socket==nil)
        _socket = [[SocketIOClient alloc] initWithSocketURL:kServiceURL options:@{@"log": @YES, @"forcePolling": @YES}];
    if(self.isConnected==NO){
        [_socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"socket connected");
            _isConnected = YES;
            [self.socket on:@"message" callback:^(NSArray* data, SocketAckEmitter* ack) {
                NSLog(@"%@",data);
                [[NSNotificationCenter defaultCenter] postNotificationName:kLCPDidReceiveMessageNotification object:nil userInfo:@{@"data":data}];
            }];
            NSDictionary * body = @{@"appkey": self.appKey};
            [self.socket on:@"connack" callback:^(NSArray* data, SocketAckEmitter* ack) {
                NSLog(@"%@",data);
                callback(YES,nil);
                return ;
            }];
            [self.socket emit:@"connect_v2" withItems:@[body]];
            
            return ;
        }];
        
        [_socket connect];
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


#define GEN_MESSAGE_ID [NSString stringWithFormat:@"%d%D",rand(),rand()]
//#define CONNECT_AND_DOING(callback)    \
//    [self connect:^(BOOL succ, NSError *error) { \
//        if(succ==NO){ \
//            callback(succ,error); \
//            return; \
//        }\



-(void)subscribe:(NSString *)topic qos:(NSInteger)qosLevel resultBlock:(LCPResultBlock)resultBlock{

    NSString *msgId =  GEN_MESSAGE_ID;

    NSDictionary * body = @{@"topic": topic, @"qos": @(qosLevel), @"messageId": msgId};
    
    LCPBlock block = ^(LCPResultBlock cb){
        
        [self.socket on:@"suback" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"%@",data);
            if(resultBlock){
                cb(YES,nil);
                return ;
            }
        }];
        
        [self.socket emitWithAck:@"subscribe" withItems:@[body]];
    };

    [self connectAndDoingWithBlock:block callback:resultBlock];

}

+ (void)unsubscribe:(NSString *)topic resultBlock:(LCPResultBlock)resultBlock{
    LycamPlusIM * im = [LycamPlusIM sharedInstance];

    NSString *msgId =  GEN_MESSAGE_ID;
    NSDictionary * body = @{@"topic": topic,@"messageId": msgId};
    
    
    LCPBlock block = ^(LCPResultBlock cb){
        
        [im.socket on:@"unsuback" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"%@",data);
            if(resultBlock){
                cb(YES,nil);
                return ;
            }
        }];
        
        [im.socket emitWithAck:@"unsubscribe" withItems:@[body]];
    };
    
    [im connectAndDoingWithBlock:block callback:resultBlock];
}

- (void)publish:(NSString *)topic msg:(NSString *) msg option:(YBPublishOption *)option resultBlock:(LCPResultBlock)resultBlock{
    
    NSString *msgId =  GEN_MESSAGE_ID;
    
    NSDictionary * body = @{@"topic": topic, @"qos": @(kYBQosLevel1), @"msg":msg,@"messageId": msgId};
    
    LCPBlock block = ^(LCPResultBlock cb){
        
        [self.socket on:@"puback" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"%@",data);
            if(resultBlock){
                resultBlock(YES,nil);
                return ;
            }
        }];
        
        [self.socket emitWithAck:@"publish" withItems:@[body]];
    };
    
    [self connectAndDoingWithBlock:block callback:resultBlock];
    
    
    

}
+ (void)publish:(NSString *)topic msg:(NSString *) msg option:(YBPublishOption *)option resultBlock:(LCPResultBlock)resultBlock{
    [[self sharedInstance] publish:topic msg:msg option:option resultBlock:resultBlock];
}


+(void)subscribe:(NSString *)topic qos:(NSInteger)qosLevel resultBlock:(LCPResultBlock)resultBlock{
    [[self sharedInstance] subscribe:topic qos:qosLevel resultBlock:resultBlock];
}



@end
