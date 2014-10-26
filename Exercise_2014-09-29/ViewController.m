//
//  ViewController.m
//  Exercise_2014-09-29
//
//  Created by TTC on 9/29/14.
//  Copyright (c) 2014 TTC. All rights reserved.
//

#import "ViewController.h"
#define countDown 13 // 游戏时间

@interface ViewController ()
{
    NSMutableArray *_mutableArray;
    int _lastIndex; // 上一次的随机数
    UIButton *_currentButton;
    float _difficulty; // 难度
    int _score; // 当前分数
    int _highestScore; // 最高分
    UILabel *_scoreContent; //分数内容的Label
    UILabel *_highestScoreContentLabel; // 最高分数内容的Label
    NSTimer *_susliksTimer; // 地鼠的定时器
    NSTimer *_clockTimer; // 游戏时间的定时器
    NSString *_highestScoreContentString; // 最高分数的字符串
    NSString *_highestScoreFilePath; // 最高分数文件保存路径
    UIButton *_startBtn; // "开始游戏"按钮
    UIButton *_pauseBtn; // "暂停游戏"按钮
    UILabel *_countDownContentLabel; // 倒计时内容的Label
    int _countDown; // 游戏时间
    int _random; // 随机数
    int _switch; // 暂停/继续开关 0时为游戏进行状态 1时为暂停游戏状态
}
- (IBAction)preventUsersRepeatedClicks:(id)sender;
- (IBAction)btnPressed:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 装箱倒计时的时间, 显示在界面上
    int time = countDown;
    NSString *timeStr = [NSString stringWithFormat:@"%d", time];
    
    // 进入界面后, 游戏就为进行状态
    _switch = 0;
    
    // 把游戏时间设为60秒
    _countDown = countDown;
    
    // "暂停游戏"按钮
    _pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_pauseBtn setTitle:@"暂停游戏" forState:UIControlStateNormal];
    _pauseBtn.frame = CGRectMake(200, 400, 100, 100);
    [_pauseBtn addTarget:self action:@selector(pauseGame) forControlEvents:UIControlEventTouchUpInside];

    // 第一次进入界面时"暂停游戏"不能按
    [_pauseBtn setEnabled:NO];
    
    [self.view addSubview:_pauseBtn];
    
    // 分数的Label
    UILabel *score = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 70, 50)];
    score.text = @"当前分数";
    [self.view addSubview:score];
    
    // 分数内容的Label
    _scoreContent = [[UILabel alloc] initWithFrame:CGRectMake(105, 30, 20, 50)];
    _scoreContent.text = @"0";
    [self.view addSubview:_scoreContent];
    
    // 最高分的Label
    UILabel *highestScore = [[UILabel alloc] initWithFrame:CGRectMake(130, 30, 70, 50)];
    highestScore.text = @"最高分数";
    [self.view addSubview:highestScore];
    
    // 最高分内容的Label
    _highestScoreContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(205, 30, 20, 50)];
    _highestScoreContentLabel.text = @"";
    [self.view addSubview:_highestScoreContentLabel];
    
    // 倒计时的Label
    UILabel *countDownTimer = [[UILabel alloc] initWithFrame:CGRectMake(240, 30, 70, 50)];
    countDownTimer.text = @"剩余时间";
    [self.view addSubview:countDownTimer];
    
    // 倒计时内容的Label
    _countDownContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(315, 30, 50, 50)];
    _countDownContentLabel.text = timeStr;
    [self.view addSubview:_countDownContentLabel];
    
    // 读取最高分数, 先给一个沙盒路径
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    _highestScoreFilePath = [documentsDirectory stringByAppendingPathComponent:@"highestScoreFile.txt"];
    [self readData];
    
    // 定义 9 个Button作为游戏的"洞"和"地鼠"
    _mutableArray = [[NSMutableArray alloc] initWithCapacity:9];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setTitle:@"" forState:UIControlStateNormal];
            
            // 40是第一个按钮x轴偏移的位置, 100是第一个按钮y轴偏移的位置
            button.frame = CGRectMake(40 + 100 * i, 100 + 100 * j, 100, 100);
            [button setBackgroundImage:[UIImage imageNamed:@"portable_hole_small.jpg"] forState:UIControlStateNormal];
            
            // 勾住, 每点Button后就进行btnPressed方法
            [button addTarget:self action:@selector(preventUsersRepeatedClicks:) forControlEvents:UIControlEventTouchUpInside];
            
            // 往 _mutableArray 数组加
            [_mutableArray addObject:button];
            
            [self.view addSubview:button];
//            [self.view addSubview:_currentButton];
        }
    }
    
    
    // 定义一个变量记录上一次的随机数
    _lastIndex = 0;
    
    // "开始游戏"按钮
    _startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _startBtn.frame = CGRectMake(10, 400, 200, 100);
    [_startBtn setTitle:@"开始游戏" forState:UIControlStateNormal];
    [_startBtn addTarget:self action:@selector(changeDifficulty) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startBtn];
    
    // 打印Xcode 6修改后的沙盒目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"%@", paths);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 开始游戏
- (void)startGame
{
    // 关闭定时器
    [_susliksTimer setFireDate:[NSDate distantFuture]];
    
    // 定义难度为最简单的1秒钟
    _difficulty = 1;
    
    // 开启地鼠定时器
    [self startTimer];
    
   
    NSLog(@"%g", _difficulty);
}

// 开始游戏/改变难度
- (void)changeDifficulty
{
    // 开始游戏后时"暂停游戏"就可以按了
    [_pauseBtn setEnabled:YES];
    
    // 解锁之前的地鼠按钮
    [_mutableArray[_random] setEnabled:YES];
    
    // 提示用户要什么样的难度
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                   message:@"请选择难度"
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"困难", @"中等", @"轻松", nil];
    [alert show];
    
    
    
//    // 关闭定时器
//    [_timer setFireDate:[NSDate distantFuture]];
//    
//    
//    _difficulty -= 0.2;
//    if (_difficulty < 0.2) {
//        _difficulty = 1;
//    }
//    
//    // 开启定时器
//    [self startTimer];
//    
//    NSLog(@"%g", _difficulty);
    [_startBtn setTitle:@"改变难度" forState:UIControlStateNormal];
//    [_pauseBtn setTitle:@"123" forState:UIControlStateNormal];
}

// 地鼠的定时器
- (void)startTimer
{
    _susliksTimer = [[NSTimer alloc] init];
    _susliksTimer = [NSTimer scheduledTimerWithTimeInterval:_difficulty
                                                     target:self
                                                   selector:@selector(handleTimer:)
                                                   userInfo:nil
                                                    repeats:YES];
}

// 倒计时的定时器
- (void)countDownTimer
{
    _clockTimer = [[NSTimer alloc] init];
    _clockTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                   target:self
                                                 selector:@selector(countDownTime:)
                                                 userInfo:nil
                                                  repeats:YES];
}

// 倒计时
- (void)countDownTime:(NSTimer*)timer
{
    
    NSString *countDownContentString = [NSString stringWithFormat:@"%d", _countDown];
    _countDownContentLabel.text = countDownContentString;
    _countDown --;
    
    // 倒计时小于10时, 字号正常
    if (_countDown > 9) {
        _countDownContentLabel.font = [UIFont fontWithName:@"Arial" size:17];
    }
    
    // 倒计时小于10时, 字号变大
    if (_countDown < 9) {
        _countDownContentLabel.font = [UIFont fontWithName:@"Arial" size:46];
    }
    
    if (_countDown == -1){
        // 倒计时为0时, 地鼠的按钮无法按
        [_mutableArray[_random] setEnabled:NO];
        
        // 倒计时为0时, "暂停游戏"不能按
        [_pauseBtn setEnabled:NO];
        
        // 倒计时为0时, 取消地鼠
        [_mutableArray[_random] setBackgroundImage:[UIImage imageNamed:@"portable_hole_small.jpg"] forState:UIControlStateNormal];
        
        // 关闭地鼠定时器
        [_susliksTimer setFireDate:[NSDate distantFuture]];
        
        // 关闭倒计时的定时器
        [_clockTimer setFireDate:[NSDate distantFuture]];
        
    }
}

// 出现地鼠
- (void)handleTimer:(NSTimer*)timer
{
    // 取 0~9 的随机数, 如果随机数与上次的一样, 就进行下一次随机数判断
    _random = 0;
    do{
         _random = arc4random() % 9;
    }
    while (_random == _lastIndex);

    // 记录下按下的Button
    _currentButton = _mutableArray[_random];
    
    // 地鼠的Button变化图片, 上次的地鼠变回正常的图片
    [_mutableArray[_lastIndex] setBackgroundImage:[UIImage imageNamed:@"portable_hole_small.jpg"] forState:UIControlStateNormal];
    [_mutableArray[_random] setBackgroundImage:[UIImage imageNamed:@"WhackAMole1.jpg"] forState:UIControlStateNormal];
    
    // 记录现在的随机数, 以便下一次对比
    _lastIndex = _random;
}


// 判断是否击中以及分数、最高分
- (void)btnPressed:(UIButton*)sender
{
    if( sender == _currentButton){
        _score++;
        [_mutableArray[_random] setBackgroundImage:[UIImage imageNamed:@"portable_hole_small.jpg"] forState:UIControlStateNormal];
//        NSNumber *numberVal = [NSNumber numberWithInteger:_score];
        NSString *scoreContentString = [NSString stringWithFormat:@"%d", _score];
        _scoreContent.text = scoreContentString;
        
        _highestScore = _score > _highestScore ? (_score):(_highestScore);
        _highestScoreContentString = [NSString stringWithFormat:@"%d", _highestScore];
//        _highestScoreContent.text = _highestScoreContentString;
        NSLog(@"击中");
    }
    else{
        NSLog(@"没击中");
    }
    
    // 记录最高分
    [self writeData];
}

// 判断是否已有最高分

// 写入最高分数
- (void)writeData
{
    NSError *error;
    [_highestScoreContentString writeToFile:_highestScoreFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

// 读取最高分数
- (void)readData
{
    NSError *error;
    _highestScoreContentString = [[NSString alloc] initWithContentsOfFile:_highestScoreFilePath encoding:NSUTF8StringEncoding error:&error];
    if (_highestScoreContentString == nil) {
        _highestScoreContentLabel.text = @"0";
    }
    else{
        _highestScoreContentLabel.text = _highestScoreContentString;
    }
}

// 用户选择对应的难度后, 更改定时器
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 0留给了"取消"
    switch (buttonIndex) {
        case 1:
            _difficulty = 0.5;
            _countDown = countDown;
            
            // 关闭定时器
            [_susliksTimer setFireDate:[NSDate distantFuture]];
            
            // 开启定时器
            [self startTimer];
            
            NSLog(@"困难");
            NSLog(@"%g", _difficulty);
            
            // 关闭倒计时的定时器
            [_clockTimer setFireDate:[NSDate distantFuture]];
            
            // 开启倒计时定时器
            [self countDownTimer];
            
            // 重新写入读取一次最高分数
            [self writeData];
            [self readData];
            
            // 当前分数置0
            _scoreContent.text = @"0";
            _score = 0;
            
            break;
        case 2:
            _difficulty = 0.8;
            _countDown = countDown;
            
            // 关闭定时器
            [_susliksTimer setFireDate:[NSDate distantFuture]];
            
            // 开启定时器
            [self startTimer];
            
            NSLog(@"中等");
            NSLog(@"%g", _difficulty);
            
            // 关闭倒计时的定时器
            [_clockTimer setFireDate:[NSDate distantFuture]];
            
            // 开启倒计时定时器
            [self countDownTimer];
            
            // 重新写入读取一次最高分数
            [self writeData];
            [self readData];
            
            // 当前分数置0
            _scoreContent.text = @"0";
            _score = 0;
            
            break;
        case 3:
            _difficulty = 1.1;
            _countDown = countDown;
            
            // 关闭定时器
            [_susliksTimer setFireDate:[NSDate distantFuture]];
            
            // 开启定时器
            [self startTimer];
            
            NSLog(@"轻松");
            NSLog(@"%g", _difficulty);
            
            // 关闭倒计时的定时器
            [_clockTimer setFireDate:[NSDate distantFuture]];
            
            // 开启倒计时定时器
            [self countDownTimer];
            
            // 重新写入读取一次最高分数
            [self writeData];
            [self readData];
            
            // 当前分数置0
            _scoreContent.text = @"0";
            _score = 0;
            
            break;
        default:
            break;
    }
}

// 暂停/继续游戏
- (void)pauseGame
{
    if (_switch == 1) {
        // 地鼠按钮开启
        [_mutableArray[_random] setEnabled:YES];
        
        // 继续定时器
        [_susliksTimer setFireDate:[NSDate distantPast]];
        
        // 继续倒计时的定时器
        [_clockTimer setFireDate:[NSDate distantPast]];
        
        // 把按钮的"继续游戏"改为"暂停游戏"
        [_pauseBtn setTitle:@"暂停游戏" forState:UIControlStateNormal];
        
        
        // 0时为游戏进行状态 1时为暂停游戏状态
        _switch = 0;
    }
    
    else{
        // 关闭定时器
        [_susliksTimer setFireDate:[NSDate distantFuture]];
        
        // 关闭倒计时的定时器
        [_clockTimer setFireDate:[NSDate distantFuture]];
        
        // 把按钮的"暂停游戏"改为"继续游戏"
        [_pauseBtn setTitle:@"继续游戏" forState:UIControlStateNormal];
        
        // 地鼠按钮禁止
        [_mutableArray[_random] setEnabled:NO];
        
        // 0时为游戏进行状态 1时为暂停游戏状态
        _switch = 1;
    }
}

// 防止用户重复点击
- (void)preventUsersRepeatedClicks:(id)sender
{
    // 先将未到时间执行前的任务取消。
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(btnPressed:) object:sender];
    [self performSelector:@selector(btnPressed:) withObject:sender afterDelay:0.0];
    NSLog(@"%g", _difficulty);
}

@end
