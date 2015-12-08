//
//  LCPViewController.m
//  LycamPlusIMSDK
//
//  Created by no777 on 12/09/2015.
//  Copyright (c) 2015 no777. All rights reserved.
//

#import "LCPViewController.h"
#import "LycamPlusIM.h"

@interface LCPViewController ()

@end

@implementation LCPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNotificationHandler];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -- yunba notifications
- (void)addNotificationHandler {
    NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC addObserver:self selector:@selector(onConnectionStateChanged:) name:kLCPConnectionStatusChangedNotification object:nil];
    [defaultNC addObserver:self selector:@selector(onMessageReceived:) name:kLCPDidReceiveMessageNotification object:nil];
    [defaultNC addObserver:self selector:@selector(onPresenceReceived:) name:kLCPDidReceivePresenceNotification object:nil];
}
- (void)onMessageReceived:(NSNotification *)notification {
    NSArray *messages = [notification object];
    
    for(int i=0;i< messages.count;i++){
        NSDictionary * msg =[messages objectAtIndex:i];
        NSString * body =[msg objectForKey:@"msg"];
        NSLog(@"new message: %@", body);
        //        [self addMsgToTextView:body alert:NO];
    }
}

@end
