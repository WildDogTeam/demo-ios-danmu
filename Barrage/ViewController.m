//
//  ViewController.m
//  Barrage
//
//  Created by junpengwang on 15/7/24.
//  Copyright (c) 2015年 junpengwang. All rights reserved.
//

#import "ViewController.h"
#import <Wilddog/Wilddog.h>
#define kWilddogUrl @"https://danmu.wilddogio.com/message"

@interface ViewController ()
{
    CGRect _originFrame;
}
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,strong) Wilddog *wilddog;

@property (nonatomic,strong) NSMutableArray *snaps;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _wilddog = [[Wilddog alloc] initWithUrl:kWilddogUrl];
    
    _snaps = [[NSMutableArray alloc] init];
    _originFrame = self.view.frame;

    [self.wilddog observeEventType:WEventTypeChildAdded withBlock:^(WDataSnapshot *snapshot) {
        
        [self sendLabel:snapshot];
        [self.snaps addObject:snapshot];
        
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(timer) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)timer
{
    if (_snaps.count < 2) {
        return;
    }
    int index = arc4random()%(self.snaps.count-1);
    WDataSnapshot *snapshot = [self.snaps objectAtIndex:index];
    [self sendLabel:snapshot];
}

- (UILabel *)sendLabel:(WDataSnapshot *)snapshot
{
    float top = (arc4random()% (int)self.view.frame.size.height)-100;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width, top, 100, 30)];
    label.textColor = [UIColor colorWithRed:arc4random()%255/255.f green:arc4random()%255/255.f blue:arc4random()%255/255.f alpha:1];
    label.text = snapshot.value;
    [UIView animateWithDuration:7 animations:^{
        label.frame = CGRectMake(-label.frame.size.width, top, 100, 30);
    }completion:^(BOOL finished){
        [label removeFromSuperview];
    }];
    [self.view addSubview:label];
    return label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [aTextField resignFirstResponder];
    
    [[self.wilddog childByAutoId]setValue:_textField.text];
    
    [aTextField setText:@""];
    return NO;
}

#pragma mark - Keyboard handling

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertRect=[self.view convertRect:endRect fromView:nil];
    float duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        
        CGRect frame = self.view.frame;
        frame.origin.y = -  convertRect.size.height;
        self.view.frame = frame;
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    float duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        
        CGRect frame = self.view.frame;
        frame.origin.y = _originFrame.origin.y;
        self.view.frame = frame;
    }];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if ([_textField isFirstResponder]) {
        [_textField resignFirstResponder];
    }
}
@end
