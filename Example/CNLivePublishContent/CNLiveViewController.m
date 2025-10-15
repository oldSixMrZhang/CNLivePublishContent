//
//  CNLiveViewController.m
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 02/14/2019.
//  Copyright (c) 2019 殷巧娟. All rights reserved.
//

#import "CNLiveViewController.h"
#import "CNLivePublishContentController.h"
@interface CNLiveViewController ()
@property (nonatomic, strong) UIButton *testButton;
@end

@implementation CNLiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.testButton];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)testButtonClicked {
    CNLivePublishContentController *vc = [[CNLivePublishContentController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}
- (UIButton *)testButton {
    if (!_testButton) {
        _testButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _testButton.frame = CGRectMake(100, 100, 100, 100);
        _testButton.backgroundColor = [UIColor cyanColor];
        [_testButton addTarget:self action:@selector(testButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _testButton;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
