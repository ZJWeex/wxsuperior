//
//  TCMViewController.m
//  TCMLocation
//
//  Created by Dao on 12/20/2017.
//  Copyright (c) 2017 Dao. All rights reserved.
//

#import "TCMViewController.h"

#import <TCMLocation.h>
#import <MJExtension.h>

@interface TCMViewController ()

@end

@implementation TCMViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];

    button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2.0 - 30, [UIScreen mainScreen].bounds.size.height/2.0 - 30, 48, 40);

    button.layer.cornerRadius = 10;
    button.layer.borderWidth = 0.5f;
    [button addTarget:self action:@selector(click) forControlEvents:(UIControlEventTouchUpInside)];
    button.layer.borderColor = [UIColor grayColor].CGColor;

    [self.view addSubview:button];
}

- (void)click{
//    tcm_location_once(^(TCMLocation *location){
//        if (location.rgcData) {
//            NSLog(@"%@ %@", [NSString stringWithCString:[[[location rgcData] mj_keyValues].description cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding], [location rgcData]);
//        }
//    });

//    tcm_location_roll(^(TCMLocation *location){
//        if (location.rgcData) {
//            NSLog(@"%@ %@", [NSString stringWithCString:[[[location rgcData] mj_keyValues].description cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding], [location rgcData]);
//        }
//
//        //stop location
//        //tcm_location_stop();
//    });


    tcm_location_background(^(TCMLocation *location){
        if (location.rgcData) {
            NSLog(@"%@ %@", [NSString stringWithCString:[[[location rgcData] mj_keyValues].description cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding], [location rgcData]);
        }

        //stop location
        //tcm_location_stop();
    }, YES);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
