//
//  IconsShortcutRenamerViewController.m
//  Houdini
//
//  Created by Abraham Masri on 11/22/17.
//  Copyright © 2017 cheesecakeufo. All rights reserved.
//


#include "task_ports.h"
#include "triple_fetch_remote_call.h"
#include "apps_control.h"
#include "utilities.h"
#include "display.h"

#include <sys/param.h>
#include <sys/mount.h>
#import <UIKit/UIKit.h>


@interface IconsShortcutRenamerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *renameTypeSegment;
@property (weak, nonatomic) IBOutlet UITextField *iconsNameTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;


@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property (assign) BOOL shouldRespring;
@property (assign) NSString *rename_type;

@end

@implementation IconsShortcutRenamerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rename_type = @"original";
}


- (void)showRunning {
    
    [self.dismissButton setHidden:YES];
    [self.activityIndicator setHidden:NO];
    [self.renameTypeSegment setHidden:YES];
    [self.iconsNameTextField setHidden:YES];
    [self.dismissButton setHidden:YES];
    [self.activityIndicator startAnimating];
    [self.actionButton setEnabled:NO];
    [self.actionButton setBackgroundColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0]];
    
}


- (void)hideInstalling {
    
    [self.dismissButton setHidden:NO];
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
    [self.actionButton setBackgroundColor: [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:0.21]];
    
    [self.actionButton setTitle:@"respring" forState:UIControlStateNormal];
    [self.actionButton setEnabled:YES];
    _shouldRespring = true;
    kill_springboard(SIGCONT);
}

- (IBAction)renameTypeChanged:(id)sender {
    
    if (self.renameTypeSegment.selectedSegmentIndex == 0) {
        self.rename_type = @"original";
    } else if (self.renameTypeSegment.selectedSegmentIndex == 2) { // Custom Label
        [self.iconsNameTextField setHidden:NO];
        [self.iconsNameTextField setText:@""];
        self.rename_type = @"custom";
    } else { // otherwise, we hide the field
        [self.iconsNameTextField setHidden:YES];
        [self.iconsNameTextField setText:@" "];
        self.rename_type = @"hidden";
    }
    
}

- (IBAction)applyTapped:(id)sender {
    
    if (_shouldRespring) {
        
        
        [self.actionButton setTitle:@"respringing.." forState:UIControlStateNormal];
        [self showRunning];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            // similar to 'uicache'
            uicache();
            
        });
        
        return;
    }
    
    [self.actionButton setTitle:@"renaming.." forState:UIControlStateNormal];
    [self showRunning];
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        // stop Springboard (to stop user from exiting)
        kill_springboard(SIGSTOP);
        
        if(rename_all_3d_touch_shortcuts([self.iconsNameTextField.text UTF8String], strdup([self.rename_type UTF8String])) != KERN_SUCCESS) {
            
        }
        
        [self hideInstalling];
        
    });
}


- (IBAction)dismissTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.iconsNameTextField resignFirstResponder];
    }
}
@end

