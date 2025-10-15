//
//  CNLivePublishContentController.m
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/10.
//

#import "CNLivePublishContentController.h"
//Views
#import "CNLiveShareView.h"
#import "CNLivePublishContentLayout.h"
#import "CNLivePublishContentTagCell.h"
#import "TZTestCell.h"
#import "CNLivePublishToolBar.h"
//Models
#import "CNLiveWitnessModel.h"
//Controllers
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "TZLocationManager.h"
#import "TZVideoPlayerController.h"
#import "CNImagePickerController.h"
#import "CNImagePickerManager.h"
//Others
#import "UIColor+CNLiveExtension.h"
#import <CNLiveStat/CNLiveStat.h>
#import "CNLiveRDMediaEditorTools.h"
#import "CNLiveDrafModelCacheTool.h"
#import "PHAsset+CNLiveAdd.h"
#import "QMUIKit.h"
#import "CNLiveLocationManager.h"
#import "Masonry.h"
#import "CNLiveDefinesHeader.h"
#import "CNLiveConst.h"
#import "CNLiveTimeTools.h"
#import "CNLiveQQEmotionManager.h"
#import "NSString+CNLiveExtension.h"
#import "XFCameraController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "CNLiveNetworking.h"
#import "CNLiveEnvironmentConfiguration.h"
#import "CNUserInfoManager.h"
#import "YYKit.h"
#import "CNLiveCommonCategory.h"
//#import "CNLiveUploadManager.h"
// 弱引用
#define PublishEmotionViewHeight 232
#define PublishToolBarHeight 95
#define PublishToolEmotionHeight 50
static NSString * uuid;
@interface CNLivePublishContentController ()<CellSelectDelegate,TextViewDidChanegDelegate,TZImagePickerControllerDelegate>
{
    NSString *_shareTitle;
    id        _shareImage;
    NSString *_shareDes;
    NSString *_shareUrl;
}
@property (nonatomic, strong) QMUIButton *cancelBtn;
@property (nonatomic, strong) QMUIButton *publishBtn;
@property (nonatomic, copy)NSString *currentCity; //当前城市
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray *picArr;
@property (nonatomic, assign) NSInteger tagId;
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, copy) NSString *timeStr;
//ToolBar
@property (nonatomic, strong) CNLivePublishToolBar *toolBar;
/** 表情视图 */
@property (nonatomic, strong) QMUIEmotionView *emotionView;
@property (nonatomic, assign) BOOL isClickBtn;//是否选择定位城市
@property (nonatomic, copy) NSString *localIdentifier;// 获取资源Id的路径
@property (nonatomic, assign) BOOL isSelectOriginalPhoto; //是否是原图
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) NSString *outputPath;//视频导出到本地路径
@property (nonatomic, copy) NSString *fileName;//短视频相对路径
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIView *navView;
@property (nonatomic, assign) NSInteger showTagId;//传给视讯云的tagId
@property (nonatomic, assign) BOOL isStop; //音频是否在播放
@end

@implementation CNLivePublishContentController
-(instancetype)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        [self didInitializeWithStyle:UITableViewStyleGrouped];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self hideEmotionAndToolBar];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self hideEmotionAndToolBar];
}
-(void)dealloc {
    NSLog(@"发布页面释放掉了吗");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _selectedAssets = [NSMutableArray array];
    _selectedPhotos = [NSMutableArray array];
    self.isStop = NO;
    [self setUpNav];
    [self getBottomCell].publishType = self.publishType;
    [self startLocation];
    if ([self.publishType isEqualToString:@"witness"]) {
        _titleLabel.text = @"目击者";
        [CNLiveLocationManager stop];
        _toolBar.locationBtn.hidden = YES;
        _toolBar.seleLocationBtn.hidden = YES;
        _toolBar.line.hidden = YES;
        _toolBar.height = PublishToolEmotionHeight;
        [_toolBar.indicator stopAnimating];
    }else if ([self.publishType isEqualToString:@"moment"]){
        _titleLabel.text = @"生活圈";
        [self startLocation];
        _toolBar.locationBtn.hidden = NO;
        _toolBar.seleLocationBtn.hidden = NO;
        [_toolBar.indicator startAnimating];
        _toolBar.line.hidden = NO;
        _toolBar.height = PublishToolBarHeight;
    }else {
        _titleLabel.text = @"发布";
    }
    [self networkParamAction];
}
- (void)networkParamAction
{
    NSMutableDictionary * mDict = [[NSMutableDictionary alloc] init];
    [mDict setValue:CNUserShareModel.uid forKey:@"loginSid"];
    [mDict setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] forKey:@"platform_id"];
    [mDict setValue:[self appUUIDString] forKey:@"uuid"];
    [mDict setValue:@"i" forKey:@"plat"];
    [mDict setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"ver"];
    [mDict setObject:AppId forKey:@"appId"];
    [CNLiveNetworking setupDefaultParam:mDict];
    [CNLiveNetworking setupShowResult:NO];
    [CNLiveNetworking setupSignKey:APPKey];
    [CNLiveNetworking setAllowRequestDefaultArgument:YES];
    [CNLiveNetworking setResponseSerializerType:CNLiveResponseSerializerJSON];
}
- (NSString *)appUUIDString
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uuid = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    });
    return uuid;
}

//状态栏不隐藏
- (BOOL)prefersStatusBarHidden {
    return NO;
}
#pragma mark -编辑页面过来
- (void)setWitnessModel:(CNLiveWitnessModel *)witnessModel {
    _witnessModel = witnessModel;
     [CNLiveLocationManager stop];
    self.tagName = witnessModel.tagName;
    self.tagId = witnessModel.tagId;
    self.showTagId = witnessModel.showTagId;
    self.publishType = witnessModel.videoType;
    _titleLabel.text = @"目击者";
    self.multipleCategory = witnessModel.mutileCategory;
    self.path = witnessModel.path;
    [self getBottomCell].publishType = self.publishType;
    [self getBottomCell].witnessModel = _witnessModel;
    if (witnessModel.isEdit) {
        [self publishBtnEnable];
        if (witnessModel.tagName.length > 0 && witnessModel.tagId > 0) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:witnessModel.tagName ? witnessModel.tagName :@""  forKey:@"tagName"];
            [dict setValue:[NSString stringWithFormat:@"%ld",witnessModel.showTagId] ? [NSString stringWithFormat:@"%ld",witnessModel.showTagId]:@"" forKey:@"tagId"];
            _tagArray = [NSArray arrayWithObject:dict];
        }else {
            _tagArray = @[];
        }
        self.timeStr = witnessModel.timeStr;
        _selectedPhotos = [NSMutableArray arrayWithArray:@[witnessModel.videoimage]];
        [self getBottomCell].selectedPhotos = _selectedPhotos;
        [[self getBottomCell].collectionView reloadData];
        
    }else {
        PHAsset * assetes;
        if (_witnessModel.localIdentifier) {
            PHFetchResult * assetArray =  [PHAsset fetchAssetsWithLocalIdentifiers:@[witnessModel.localIdentifier] options:nil];
            assetes = assetArray.firstObject;
        }
        
        if (assetes == nil) {
            if (_selectedPhotos.count == 0 && _selectedAssets.count == 0) {
                [self publiahBtnNoEnable];
            }else{
                [self publishBtnEnable];
            }
            _tagArray= [NSArray arrayWithArray:witnessModel.tagArray];
            return;
        }else {
            [self publishBtnEnable];
            _selectedAssets = [NSMutableArray arrayWithArray:@[assetes]];
            _selectedPhotos= [NSMutableArray arrayWithArray:@[witnessModel.videoimage]];
            [self getBottomCell].selectedPhotos = _selectedPhotos;
            [self getBottomCell].selectedAssets = _selectedAssets;
            [[self getBottomCell] updateCollectionViewWithAssets:_selectedAssets isSelectOriginalPhoto:NO];
            _tagArray= [NSArray arrayWithArray:witnessModel.tagArray];
        }
    }
    [self getMiddleTextView].text = _witnessModel.text;
    [self.tableView reloadData];
}
#pragma mark --分享页面
-(void)setShareTitle:(NSString *)shareTitle image:(id)image des:(NSString*)des shreUrl:(NSString *)shareUrl{
    [self startLocation];
    _shareTitle = shareTitle ? shareTitle : @"";
    _shareDes = des ? des : @"";
    _shareUrl = shareUrl ? shareUrl  : @"";
    _shareImage = image ? image : UIImageMake(@"ewm_lcon");
    [[self getBottomCell].shareView setTitle:shareTitle image:image des:des shareUrl:shareUrl];
    [self getBottomCell].publishContentType =  CNLivePublishWitnessContentTypeShare;
    [self getBottomCell].shareView.tapShareClick = ^{
//        [weakSelf tapLink];
    };
    [self getMiddleTextView].placeholder = @"这一刻的想法...";
    [self publishBtnEnable];
}
#pragma mark - Notification
- (void)heightChangeAction:(NSNotification *)noti
{
    NSNumber *num = noti.object;
    CGFloat number = num.floatValue;
    _footerHeight = number + 80;
}

-(void)setUpNav {
    _navView = [[UIView alloc] initWithFrame:CGRectMake(0, kStatusHeight, KScreenWidth, kNavigationBarHeight - kStatusHeight)];
    _navView.backgroundColor = kWhiteColor;
    _navView.tag = 102;
    [self.view addSubview:_navView];
    
    _line = [[UIView alloc] initWithFrame:CGRectMake(0, _navView.bottom-1, KScreenWidth, 0.5)];
    _line.backgroundColor =  CNLiveColorWithHexString(@"#EBEBEB");
    [self.view addSubview:_line];
    _titleLabel = [[QMUILabel alloc]init];
    _titleLabel.text = @"生活圈";
    _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];;
    _titleLabel.textColor = UIColorMake(40, 40, 40);
    [_navView addSubview:_titleLabel];
    self.cancelBtn = [[QMUIButton alloc] init];
    [self.cancelBtn setTitleColor:UIColorMake(40, 40, 40) forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelActions) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:self.cancelBtn];
    self.cancelBtn.qmui_outsideEdge = UIEdgeInsetsMake(0, 0, 0, -40);
    
    self.publishBtn = [[QMUIButton alloc] init];
    [self.publishBtn setTitleColor:[UIColor qmui_colorWithHexString:@"#9C9C9C"] forState:UIControlStateNormal];
    self.publishBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.publishBtn setTitle:@"发布" forState:UIControlStateNormal];
    self.publishBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.publishBtn.cs_acceptEventInterval = 1.0;
    self.publishBtn.enabled = NO;
    self.publishBtn.backgroundColor = [UIColor qmui_colorWithHexString:@"#F0F0F0"];
    self.publishBtn.layer.cornerRadius = 15;
    self.publishBtn.tag = 202;
    [self.publishBtn addTarget:self action:@selector(publishAction) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:self.publishBtn];
    [self setUplayoutFrame];
}
- (void)initSubviews
{
    __weak typeof(self) weakSelf = self;
    [super initSubviews];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heightChangeAction:) name:@"heightChange" object:nil];
    CGFloat height;
    
    if ([self.publishType isEqualToString:@"witness"]) {
        UIView *view = [[UIView alloc]init];
        self.tableView.tableFooterView = view;
        height = PublishToolEmotionHeight;
    }else {
        self.tableView.tableFooterView = nil;
        height = PublishToolBarHeight;
    }
    _toolBar = [[CNLivePublishToolBar alloc] initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, height)];
    _toolBar.publishType = self.publishType;
    [self.view addSubview:_toolBar];
    
    [self getMiddleTextView].qmui_keyboardWillChangeFrameNotificationBlock = ^(QMUIKeyboardUserInfo *keyboardUserInfo) {
        
        if (keyboardUserInfo)
        {//键盘
            [QMUIKeyboardManager handleKeyboardNotificationWithUserInfo:keyboardUserInfo showBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
                [weakSelf showToolBarWithKeyboardUserInfo:keyboardUserInfo];
            } hideBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
                [weakSelf hideToolbarViewWithKeyboardUserInfo:keyboardUserInfo];
            }];
        }else
        {//表情
            [weakSelf showToolBarWithKeyboardUserInfo:nil];
        }
    };
    _toolBar.toolBarClick = ^(QMUIButton *btn, NSInteger index) {
        
        switch (index) {
            case 0:
            {//emotion
                if (btn.selected)
                {//表情
                    weakSelf.emotionView.hidden = NO;
                    [weakSelf emotionView];
                    [[weakSelf getMiddleTextView] resignFirstResponder];
                }else
                {//键盘
                    weakSelf.emotionView.hidden = YES;
                    [weakSelf emotionView];
                    [[weakSelf getMiddleTextView] becomeFirstResponder];
                }
            }
                break;
            case 1:
            {//seleLocation
                if (btn.selected)
                {//开启定位
                    [weakSelf startLocation];
                    [weakSelf publiahBtnNoEnable];
                    [weakSelf.toolBar.indicator startAnimating];
                    weakSelf.isClickBtn = YES;
                }else
                {//关闭定位
                    weakSelf.currentCity = @"";
                    [weakSelf.toolBar.locationBtn setTitle:@"当前位置" forState:UIControlStateNormal];
                    [CNLiveLocationManager stop];
                    [weakSelf.toolBar.indicator stopAnimating];
                    weakSelf.isClickBtn = NO;
                }
            }
                break;
            default:
                break;
        }
    };
    [self.view addSubview:self.emotionView];
    _emotionView.hidden = YES;
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _navView.top = kStatusHeight;
    _navView.height = kNavigationBarHeight - kStatusHeight;
    _line.top = _navView.bottom - 1;
    self.tableView.top = kNavigationBarHeight ;
    self.tableView.height = KScreenHeight - kNavigationBarHeight;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
}
-(void)setUplayoutFrame {
    __weak typeof(self) weakSelf = self;
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.navView.mas_left);
        make.top.mas_equalTo(weakSelf.navView.mas_top);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(kNavigationBarHeight - kStatusHeight);
    }];
    [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.navView.mas_right).offset(-12);
        make.width.mas_equalTo(80);
        make.bottom.mas_equalTo(weakSelf.navView.mas_bottom).offset(-6);
        make.height.mas_equalTo(30);
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.navView.mas_centerX);
        make.height.mas_equalTo(kNavigationBarHeight - kStatusHeight);
        make.top.mas_equalTo(weakSelf.navView.mas_top);
    }];
}
#pragma mark - TargetAction
-(void)cancelActions {
    
    [self hideEmotionAndToolBar];
    _toolBar.top = KScreenHeight;
    _emotionView.top = KScreenHeight;
    
    if ((CNLiveStringIsEmpty([self getMidddleTextViewText] ) &&_selectedPhotos.count == 0 && _selectedAssets.count == 0) || self.isShare ) {
        [self isEditCancelAction];
        return;
    }
    PHAsset *asset = _selectedAssets.firstObject;
    self.localIdentifier = asset.localIdentifier;
    
    if (_witnessModel.localIdentifier && _selectedAssets.count > 0) {
        
        if (([[NSString convertNull:_witnessModel.text] isEqualToString:[self getMidddleTextViewText]])&& ([_witnessModel.localIdentifier isEqualToString:self.localIdentifier]) && [_witnessModel.videoType isEqualToString:self.publishType]) {
            [self isEditCancelAction];
            return;
        }
    }
    if (_witnessModel.isEdit) {
        [self isEditCancelAction];
    }else {
        if ([self.publishType isEqualToString:@"moment"]) {
            [self momentCancelAction];
        }else if ([self.publishType isEqualToString:@"witness"]){
            [self witnessCancelAction];
        }else {
            [self otherCancelAction];
        }
    }
}
-(void)quitPublish {
    [self hideEmotionAndToolBar];
//    [[AppDelegate sharedAppDelegate] dismissViewController:self animated:YES completion:NULL];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -目击者时取消
-(void)witnessCancelAction {
    __weak typeof(self) weakSelf = self;
    CNLiveWitnessModel *witnessDrafModel = [[CNLiveWitnessModel alloc]init];
    if (_witnessModel) {
        if (_selectedAssets.count > 0 && _selectedPhotos.count > 0) {
            PHAsset *asset = _selectedAssets.firstObject;
            self.localIdentifier = asset.localIdentifier;
            TZAssetModelMediaType type = [CNImagePickerManager getAssetType:asset];
            if (type == TZAssetModelMediaTypeVideo){
                [self.view  createAlertViewTitleArray:@[@"存入到草稿箱",@"删除视频",@"不保存"] subTitleArr:@[@"",@"",@""] textColor:UIColorMake(11, 190, 0) subTitleColor:[UIColor whiteColor] firstFont:UIFontMake(18.0f) font:UIFontMake(18.0f) subFont:UIFontMake(18.0f) cancelTitle:@"取消" cancelFont:UIFontMake(18.0f) cancelTitleColor:UIColorMake(102, 102, 102) actionBlock:^(UIButton *button, NSInteger didRow) {
                    switch (didRow) {
                        case 0: {
                            [weakSelf saveToDraftBoxs:witnessDrafModel asset:asset];
                        }
                            break;
                        case 1:{
                            
                            [[[CNLiveDrafModelCacheTool sharedCNLiveDrafModelCacheTool] selectYYCache] objectForKey:@"witness" withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
                                NSArray * array = (NSArray *)object;
                                __block NSMutableArray * tempArray = [[NSMutableArray alloc] initWithArray:array];
                                [array enumerateObjectsUsingBlock:^(CNLiveWitnessModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    if ([obj.timeStr isEqualToString:weakSelf.witnessModel.timeStr]) {
                                        [tempArray removeObject:obj];
                                        [[[CNLiveDrafModelCacheTool sharedCNLiveDrafModelCacheTool] selectYYCache] setObject:tempArray forKey:@"witness" withBlock:^{
                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                [weakSelf quitPublish];
                                            });
                                        }];
                                        *stop = YES;
                                    }
                                }];
                            }];
                        }
                            break;
                        case 2:{
                            [weakSelf  quitPublish];
                        }
                            break;
                        default:
                            break;
                    }
                }];
            }
            
        }else {
            [QMUITips showWithText:@"目击者只能保存视频" inView:self.view hideAfterDelay:1.5f];
            return;
        }
        
    }else {
        if (_selectedPhotos.count > 0 && _selectedAssets.count > 0) {
            PHAsset *asset = _selectedAssets.firstObject;
            self.localIdentifier = asset.localIdentifier;
            TZAssetModelMediaType type = [CNImagePickerManager getAssetType:asset];
            if (type == TZAssetModelMediaTypeVideo) {
                [self.view createAlertViewTitleArray:@[@"存入到草稿箱",@"删除视频"] subTitleArr:@[@"",@""] textColor:UIColorMake(11, 190, 0) subTitleColor:[UIColor whiteColor] firstFont:UIFontMake(18.0f) font:UIFontMake(18.0f) subFont:UIFontMake(18.0f) cancelTitle:@"取消" cancelFont:UIFontMake(18.0f) cancelTitleColor:UIColorMake(102, 102, 102) actionBlock:^(UIButton *button, NSInteger didRow) {
                    switch (didRow) {
                        case 0:{
                            [weakSelf saveToDraftBoxs:witnessDrafModel asset:asset];
                        }
                            break;
                        case 1:{
                            [weakSelf quitPublish];
                        }
                            break;
                        default:
                            break;
                    }
                }];
            }else if (type == TZAssetModelMediaTypePhoto || type == TZAssetModelMediaTypePhotoGif) {
                [QMUITips showWithText:@"目击者只能保存视频" inView:self.view hideAfterDelay:1.5f];
                return;
            }
        }else {
            //        [self quitPublish];
            [self isEditCancelAction];
        }
    }
}
#pragma mark -保存到草稿箱
-(void)saveToDraftBoxs:(CNLiveWitnessModel *)witnessDrafModel asset:(PHAsset*)asset {
    NSLog(@"保存");
    __weak typeof(self) weakSelf = self;
    witnessDrafModel.timeStr = [NSString stringWithFormat:@"video_%ld",[CNLiveTimeTools getNow13NumTimestamp]];
    witnessDrafModel.videoType = self.publishType;
    if (!CNLiveStringIsEmpty([self getMidddleTextViewText])) {
        if ([self getMidddleTextViewText].length > 140) {
            [QMUITips showError:@"目击者标题最多只能输入140字符" inView:self.view hideAfterDelay:2.0];
            return ;
        }else {
            witnessDrafModel.text = [self getMidddleTextViewText];
        }
    }
    witnessDrafModel.tagName = self.tagName.length > 0 ? self.tagName: @"";
    witnessDrafModel.tagId = self.tagId > 0 ? self.tagId : 0;
    witnessDrafModel.showTagId = self.showTagId > 0 ? self.showTagId : 0;
    witnessDrafModel.path = self.path;
    witnessDrafModel.tagArray = self.tagArray;
    witnessDrafModel.videoimage = _selectedPhotos[0];
    witnessDrafModel.dateString = [CNLiveTimeTools getNowTimeYYMMdd];
    witnessDrafModel.timeLength= [PHAsset getVideoTime:asset];
    witnessDrafModel.localIdentifier = self.localIdentifier;
    witnessDrafModel.mutileCategory = self.multipleCategory;
    [[[CNLiveDrafModelCacheTool sharedCNLiveDrafModelCacheTool] selectYYCache] objectForKey:@"witness" withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
        NSArray *array = (NSArray *)object;
        __block NSMutableArray *cacheArray = [NSMutableArray arrayWithArray:array];
        [cacheArray insertObject:witnessDrafModel
                         atIndex:0];
        if (cacheArray.count > 10) {
            [cacheArray removeLastObject];
        }
        
        [[[CNLiveDrafModelCacheTool sharedCNLiveDrafModelCacheTool]selectYYCache] setObject:cacheArray forKey:@"witness" withBlock:^{
            NSLog(@"数据存储成功了");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMUITips showSucceed:@"存入草稿箱成功" inView:self.view hideAfterDelay:1.5];
                [weakSelf quitPublish];
            });
            
        }];
    }];
    
}
-(void)momentCancelAction {
    [self isEditCancelAction];
}
-(void)otherCancelAction {
    [self isEditCancelAction];
}
#pragma mark -退出此次编辑
-(void)isEditCancelAction {
    __weak typeof(self) weakSelf = self;
    [self.view createAlertViewTitleArray:@[@"退出此次编辑"] subTitleArr:@[@""] textColor:UIColorMake(11, 190, 0) subTitleColor:[UIColor whiteColor] firstFont:UIFontMake(18.0f) font:UIFontMake(18.0f) subFont:UIFontMake(18.0f) cancelTitle:@"取消" cancelFont:UIFontMake(18.0f) cancelTitleColor:UIColorMake(102, 102, 102) actionBlock:^(UIButton *button, NSInteger didRow) {
        switch (didRow) {
            case 0:{
                [weakSelf quitPublish];
            }
                break;
            default:
                break;
        }
    }];
}
#pragma mark - 分享点击
-(void)tapLink
{
//    
//    NSString * hostName = [NSURL URLWithString:[_shareUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]].host;
//    if ([WjjH5_Host containsString:hostName] && ![_shareUrl containsString:@"cnlive.com/video"]) return;
//    [CNDSShopActionViewModel checkWithFunctionForShareURL:_shareUrl];
    
}
#pragma mark -发布按钮
-(void)publishAction {
    
    if (_witnessModel.isEdit) {
        [self isEditPublishAction];
    }else {
        [self normalPublishAction];
    }
}
#pragma mark -正常的发送按钮
-(void)normalPublishAction {
    
    _toolBar.top = KScreenHeight;
    _emotionView.top = KScreenHeight;
    [self hideEmotionAndToolBar];
    [self publiahBtnNoEnable];
    [self startPublishTextAndShare];
//    if (_selectedPhotos.count > 0 && _selectedAssets.count > 0) {
//        id ass = _selectedAssets[0];
//        TZAssetModelMediaType type = [CNImagePickerManager getAssetType:ass];
//        if (type == TZAssetModelMediaTypeVideo) {
////            [self QiNiuUploadVideo];//视频
//        }else {
//
//            if ([self.publishType isEqualToString:@"moment"]) {
////                [self QnStartUploadImage];//图片
//            }else {
////                [self startUploadImageForServes];
//            }
//        }
//    } else {
////        [self startPublishTextAndShare];
//    }
    
}
#pragma mark -编辑进来发布
-(void)isEditPublishAction {
    __weak typeof(self) weakSelf = self;
    [self publiahBtnNoEnable];
    NSDictionary *param = [NSDictionary dictionary];
    param = @{
              @"sid":CNUserShareModel.uid,
              @"reviewStatus": @"0",
              @"witContentId": self.timeStr,
              @"text":[self getMidddleTextViewText],
              @"type":@"update"
              };
    NSLog(@"打印这个VideoParam%@",param);
    [QMUITips showLoading:@"正在上传" inView:self.view];
    [CNLiveNetworking setAllowRequestDefaultArgument:YES];
    [CNLiveNetworking requestNetworkWithMethod:CNLiveRequestMethodPOST URLString:CNDeleteOrUpdateWitnessURL Param:param CacheType:CNLiveNetworkCacheTypeNetworkOnly CompletionBlock:^(NSURLSessionTask *requestTask, id responseObject, NSError *error) {
        NSLog(@"打印这个返回是什么啊%@",responseObject);
        [QMUITips hideAllToastInView:self.view animated:YES];
        if (error) {
            [weakSelf publishBtnEnable];
            [QMUITips showError:error.localizedDescription inView:self.view hideAfterDelay:1.5];//@"上传失败"
            return;
        }
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSString *errorCode = [responseObject objectForKey:@"errorCode"];
        NSString *errorMessage = [responseObject objectForKey:@"errorMessage"];
        if ([errorCode integerValue] == 0) {
            [weakSelf publishBtnEnable];
            [QMUITips showSucceed:@"上传发布成功" inView:self.view hideAfterDelay:1.5];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //                [[AppDelegate sharedAppDelegate] dismissViewController:weakSelf animated:YES completion:NULL];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            });
        }else {
            [weakSelf publishBtnEnable];
            [QMUITips showError:errorMessage inView:self.view hideAfterDelay:1.5];//@"上传失败"
            return;
        }
        
    }];
}
#pragma mark --分享和文字
-(void)startPublishTextAndShare {
    self.path = CNPublishFriendsCircleUrl ;
    NSString *content = [[self getMidddleTextViewText] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    if (CNLiveStringIsEmpty(content) && !self.isShare) {
        [QMUITips showError:@"不能发布空内容" inView:self.view hideAfterDelay:1.5f];
        return;
    }
    NSString *urlEncodeStr = [content urlEncode];//_titleTextView.text
    NSDictionary *param = [NSDictionary dictionary];
    if (self.isShare) {
        //        [QMUITips showLoading:@"正在上传" inView:AppKeyWindow];
        NSString *urlTitleEncodeStr = [_shareTitle stringByURLEncode];
        NSString *urlDescEncodeStr = [_shareDes stringByURLEncode];
        param = @{
                  @"appid":AppId,
                  @"sid":CNUserShareModel.uid,
                  @"text":[self getMidddleTextViewText]?urlEncodeStr:@"",
                  @"type":@"3",
                  @"address":_currentCity?_currentCity:@"",
                  @"title":urlTitleEncodeStr ? urlTitleEncodeStr:@"",
                  @"icon":_shareImage,
                  @"url":_shareUrl,
                  @"desc":urlDescEncodeStr ? urlDescEncodeStr:@"",
                  @"shareType":@"3"
                  };
        NSLog(@"打印分享这个字典%@",param);
    }else {
        if (_selectedPhotos.count == 0 && _selectedAssets.count == 0) {
            param = @{              @"appId":AppId,
                                    @"plat":@"i",
//                                    @"sid":CNUserShareModel.uid,
                                    @"sid":@"10511059",
                                    @"type":@"0",
                                    @"text":[self getMidddleTextViewText]?urlEncodeStr:@"",
                                    @"address":_currentCity?_currentCity:@""
                                    };
            NSLog(@"纯文本 params:%@",param);
        }
    }
    [QMUITips showLoading:@"正在上传" inView:self.view];
    [CNLiveNetworking setAllowRequestDefaultArgument:YES];
    [CNLiveNetworking requestNetworkWithMethod:CNLiveRequestMethodPOST URLString:self.path Param:param CacheType:CNLiveNetworkCacheTypeNetworkOnly CompletionBlock:^(NSURLSessionTask *requestTask, id responseObject, NSError *error) {
        NSLog(@"打印这个链接地址%@", responseObject);
        [QMUITips hideAllToastInView:self.view animated:YES];
        if (error) {
            [self publishBtnEnable];
            
            [QMUITips showError:error.localizedDescription inView:self.view hideAfterDelay:1.5];//@"上传失败"
            return;
        }
        [self publishBtnEnable];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kIMAMSG_FriendCircleSendNotification object:nil userInfo:@{@"type":@"30000"}];
        [QMUITips showSucceed:@"上传发布成功" inView:self.view hideAfterDelay:1.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [[AppDelegate sharedAppDelegate] dismissViewController:self animated:YES completion:NULL];
//            [self addScores];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        });
    }];
}
#pragma mark -上传图片到朋友圈
-(void)stratPublishPictureFormoment {
    __weak typeof(self) weakSelf = self;
    NSString *content = [[self getMidddleTextViewText] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    NSString *urlEncodeStr = [content urlEncode];
    NSArray *picArray = [NSArray arrayWithArray:self.picArr];
    NSString *picString = [self objectToJson:self.picArr];
    picString = [picString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    NSDictionary *param = @{@"appId":AppId,
//                            @"sid":CNUserShareModel.uid,
                            @"sid":@"10511059",
                            @"text":[self getMidddleTextViewText]?urlEncodeStr:@"",
                            @"type":@"1",
                            @"picArray":picArray.count> 0?picString:@"",
                            @"address":_currentCity?_currentCity:@""};
    NSLog(@"打印这个param%@---url%@", param,self.path);
    
    [CNLiveNetworking setAllowRequestDefaultArgument:YES];
    [CNLiveNetworking requestNetworkWithMethod:CNLiveRequestMethodPOST URLString:self.path Param:param CacheType:CNLiveNetworkCacheTypeNetworkOnly CompletionBlock:^(NSURLSessionTask *requestTask, id responseObject, NSError *error) {
        
        if (error) {
            [self publishBtnEnable];
            [QMUITips hideAllToastInView:self.view animated:YES];
            NSLog(@"打印这个errorcode%ld",error.code);
            
            [QMUITips showError:error.localizedDescription inView:self.view hideAfterDelay:1.5];//@"上传失败"
            return;
            
        }
        
        NSLog(@"打印data%@", responseObject);
        [weakSelf.selectedPhotos removeAllObjects];
        [weakSelf.selectedAssets removeAllObjects];
        [weakSelf publishBtnEnable];
        [QMUITips hideAllToastInView:self.view animated:YES];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kIMAMSG_FriendCircleSendNotification object:nil userInfo:@{@"type":@"30000"}];
        //                        [weakSelf.KVOController unobserveAll];
        [QMUITips showSucceed:@"上传发布成功" inView:self.view hideAfterDelay:1.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [[AppDelegate sharedAppDelegate] dismissViewController:weakSelf animated:YES completion:NULL];
            [self dismissViewControllerAnimated:YES completion:nil];
//            [self addScores];
            
        });
        
    }];
}
#pragma mark -上传图片到七牛
/*
-(void)QnStartUploadImage {
    NSDictionary *param = @{@"appId":AppId,
                            @"verb":@"POST",
                            @"storageType":@"2",
                            @"bucket":API_BucketName
                            };
    
    self.picArr = [NSMutableArray array];
    [QMUITips showLoading:@"正在上传" inView:self.view];
    
    [CNLiveUploadManager uploadRequestType:CNLiveUploadTypeQN url:CNUploadAuthForApp dic:param  imageArray:_selectedPhotos assetArray:_selectedAssets isOriginal:NO limitType:AppPhototLimitTypeFriendsCircle progress:^(float progress) {
        
        NSLog(@"上传进度测试:%f.2",progress);
        
    } success:^(NSMutableArray *fileArray) {
        NSLog(@"输出结果测试:%@",fileArray);
        //        if (fileArray.count != _selectedPhotos.count) {
        //            return ;
        //        }
        [fileArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *picDict = [NSMutableDictionary dictionary];
            CNLiveUploadModel *model = fileArray[idx];
            if ([model.code isEqualToString:@"200"]) {
                NSLog(@"打印这个model%@---%lf---%lf---%@",model.imageUrl,model.image.size.width, model.image.size.height,model.code);
                [picDict setValue:model.imageUrl forKey:@"imageUrl"];
                [picDict setValue:[NSString stringWithFormat:@"%.0f",model.image.size.width] forKey:@"imageWidth"];
                [picDict setValue:[NSString stringWithFormat:@"%.0f",model.image.size.height] forKey:@"imageHeight"];
                [self.picArr addObject:picDict];
                
            }else {
                [QMUITips hideAllToastInView:AppKeyWindow animated:YES];
                [QMUITips showError:@"上传失败,请重新上传" inView:AppKeyWindow hideAfterDelay:1.5];
            }
            
        }];
        [self stratPublishPictureFormoment];
        
    } failure:^(NSMutableArray *errorArray, NSError *error) {
        
        [QMUITips hideAllToastInView:AppKeyWindow animated:YES];
        NSLog(@"输出结果测试:%@,错误:%@---%ld",errorArray,error,error.code);
        [self publishBtnEnable];
        if (error.code == 0) {
            [QMUITips showError:@"上传失败\n不支持系统设置里修改时间地点内容" inView:AppKeyWindow hideAfterDelay:1.5f];
        }else {
            [QMUITips showError:error.localizedDescription inView:AppKeyWindow hideAfterDelay:1.5];
        }
    }];
    
}
 */
#pragma mark -- 七牛上传视频:
/*
-(void)QiNiuUploadVideo {
    MJWeakSelf;
    MBCNLiveUploadProgressHUD *hud= [MBCNLiveUploadProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = @"正在上传...";
    hud.detailsLabel.text = @"0.00 %";
    hud.animationType = MBProgressHUDAnimationZoomIn;
    hud.hidden = YES;
    [QMUITips showLoadingInView:AppKeyWindow];
    //    [QMUITips hideAllToastInView:AppKeyWindow animated:YES];
    id ass = _selectedAssets[0];
    NSString *timeStamp = [NSString stringWithFormat:@"%zd",[CNLiveTimeTools getNowTimestamp]];
    NSDictionary *param = @{@"appId":AppId,
                            @"storageType":@"2",
                            @"state":@"1",
                            @"contentType":@"1",
                            @"timestamp":timeStamp,
                            };
    
    [CNLiveUploadManager uploadRequestWhithPLShortVideoType:CNLiveUploadTypeQN conversationId:nil url:CNUploadAuthForApp dic:param asset:ass limitType:AppPhototLimitTypeFriendsCircle transcode:^(float progress, BOOL isSuccess) {
        
        NSLog(@"打印压缩进度和是否成功%lf---%d",progress,isSuccess);
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.hidden = NO;
                [QMUITips hideAllToastInView:AppKeyWindow animated:NO];
            });
        }
    } progress:^(float progress) {
        NSLog(@"上传进度测试:%f.2",progress);
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.hidden = NO;
            hud.progress = progress;
            hud.detailsLabel.text = [NSString stringWithFormat:@"%.2f %%",(progress * 100)];
        });
        
    } success:^(CNLiveUploadModel *uploadModel) {
        hud.hidden = YES;
        if ([uploadModel.code isEqualToString:@"200"]) {
            NSLog(@"输出结果测试:%@",uploadModel.imageUrl);
            weakSelf.outputPath = uploadModel.file;
            weakSelf.fileName = uploadModel.key;
            [weakSelf publishVideo];
        }else {
            [QMUITips hideAllToastInView:AppKeyWindow animated:YES];
            [QMUITips showError:@"上传失败,请重新上传" inView:AppKeyWindow hideAfterDelay:1.5];
        }
        
    } failure:^(CNLiveUploadModel *uploadModel, NSError *error) {
        hud.hidden = YES;
        [weakSelf publishBtnEnable];
        [QMUITips hideAllToastInView:AppKeyWindow animated:YES];
        NSLog(@"打印这个error%@",error);
        NSLog(@"打印这个视频 error%@---%ld",error,error.code);
        
        if (error.code == 0) {
            [QMUITips showError:@"上传失败\n不支持系统设置里修改时间地点内容" inView:AppKeyWindow hideAfterDelay:1.5f];
        }else {
            if (error.code == -5) {
                [QMUITips showError:@"您似乎断开与互联网的连接" inView:AppKeyWindow hideAfterDelay:1.5];
            }else {
                [QMUITips showError:error.localizedDescription inView:AppKeyWindow hideAfterDelay:1.5];
            }
        }
    }];
}
#pragma mark -- 视讯云回调
-(void)publishVideo{
    MJWeakSelf;
    //统计SDK 包的 网++短视频SDK探针
    [QMUITips showLoadingInView:AppKeyWindow];
    [CNLiveStat registerApp:AppId appKey:APPKey isTestEnvironment:CNAppDelegate.isTestEnvironment version:@"1010" eventId:@"2200"];
    NSLog(@"最后走到这里");
    //内容入库
    NSString *videoMd5 = [CNLiveRDMediaEditorTools rd_getFileMD5WithPath:_outputPath ? _outputPath:@""];  //获取文件MD5
    NSString *content = [[self getMidddleTextViewText] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    NSString *urlEncodeStr = [content urlEncode];
    
    NSMutableDictionary *extensionsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:AppId, @"appId",@"i",@"plat",CNLiveStringgetLocalAppBuildVersion,@"ver",CNUserShareModel.uid,@"userId", [self getMidddleTextViewText].length > 0 ?urlEncodeStr:@"", @"text", self.publishType, @"type",_currentCity.length > 0?_currentCity:@"",@"address",self.showTagId ? [NSString stringWithFormat:@"%ld",self.showTagId]: @"" ,@"tagId",self.tagName.length > 0 ? self.tagName: @"",@"tagName",nil];
    NSString *extensionsJSON = [extensionsDic mj_JSONString];
    [CNLiveRDMediaEditorTools getRealTimeString:^(NSString *timeString, NSDate *date) {
        NSString *yearTime = [CNLiveTimeTools getyyMMddLine];//@"2018_02_02";
        NSString *timestampStr = [CNLiveTimeTools get13tsRandTimeStr];
        NSString *spid = [CNLiveBusinessTools getSpid];
        NSString *VideoName = [NSString stringWithFormat:@"%@_%@_%@_%@_%@",spid,self.publishType,CNUserShareModel.uid,yearTime,timestampStr];
        NSDictionary *params = @{@"appId":AppId,
                                 @"plat":@"i",
                                 @"md5":videoMd5,
                                 @"videoKey":weakSelf.fileName,
                                 @"isHorizontalScreen":@"0",
                                 @"userId":CNUserShareModel.uid,
                                 @"name":VideoName,
                                 @"userName":CNUserShareModel.nickname ? CNUserShareModel.nickname : @"",
                                 @"callBackUrl":CNStockDarenVideoCallBackUrl,
                                 @"platform_id":[NSBundle mainBundle].bundleIdentifier,
                                 @"timestamp":timeString,
                                 @"storageType":@"2",
                                 @"multipleCategory":self.multipleCategory?[NSString stringWithFormat:@"%ld",self.multipleCategory]:@"",
                                 @"extensions":extensionsJSON?extensionsJSON:@""
                                 };
        NSLog(@"video params:%@",params);
        
        
        [CNLiveNetworking setAllowRequestDefaultArgument:YES];
        [CNLiveNetworking requestNetworkWithMethod:CNLiveRequestMethodPOST URLString:CNPublishVideoUrl Param:params CacheType:CNLiveNetworkCacheTypeNetworkOnly CompletionBlock:^(NSURLSessionTask *requestTask, id responseObject, NSError *error) {
            NSLog(@"打印一下啊啊啊啊啊啊啊%@",responseObject);
            NSDictionary *data = responseObject[@"data"];
            [QMUITips hideAllToastInView:AppKeyWindow animated:YES];
            NSLog(@"打印这个data%@",data);
            if (error) {
                [weakSelf publishBtnEnable];
                [QMUITips hideAllToastInView:AppKeyWindow animated:YES];
                
                [QMUITips showError:error.localizedDescription inView:AppKeyWindow hideAfterDelay:1.5];//@"上传失败"
                return;
            }
            [weakSelf publishBtnEnable];
            [weakSelf.selectedPhotos removeAllObjects];
            [weakSelf.selectedAssets removeAllObjects];
            //上传发布成功
            if ([self.publishType isEqualToString:@"moment"]) {
                NSString *videoIdStr = [data objectForKey:@"videoId"];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:weakSelf.outputPath ? weakSelf.outputPath:@"" forKey:videoIdStr];
                [defaults synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"videoUpdate" object:nil userInfo:@{@"videoId":@"4000"}];
                NSLog(@"打印outhPath%@",weakSelf.outputPath);
            }
            if (self.isWitnessH5) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(setRefreshWitnessData)]) {
                    [self.delegate setRefreshWitnessData];
                }
            }
            [QMUITips hideAllToastInView:AppKeyWindow animated:YES];
            [QMUITips showSucceed:@"上传发布成功" inView:AppKeyWindow hideAfterDelay:1.5];
            
            [[[CNVideoAndImageTool sharedCNVideoAndImageTool] selectYYCache] objectForKey:@"witness" withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
                NSArray * array = (NSArray *)object;
                __block NSMutableArray * tempArray = [[NSMutableArray alloc] initWithArray:array];
                [array enumerateObjectsUsingBlock:^(CNWitnessModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.timeStr isEqualToString:weakSelf.witnessModel.timeStr]) {
                        [tempArray removeObject:obj];
                        [[[CNVideoAndImageTool sharedCNVideoAndImageTool] selectYYCache] setObject:tempArray forKey:@"witness" withBlock:^{
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            });
                        }];
                        *stop = YES;
                    }
                }];
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[AppDelegate sharedAppDelegate] dismissViewController:self animated:YES completion:NULL];
                [self addScores];// 发布生活圈和目击者视频
            });
        }];
    }];
}
*/
#pragma mark -隐藏ToolBar
- (void)hideEmotionAndToolBar
{
    __weak typeof(self) weakSelf = self;
    if ([[self getMiddleTextView] isFirstResponder]) {
        [[self getMiddleTextView] resignFirstResponder];
    }
    if (_toolBar.emotionBtn.selected) {
        _toolBar.emotionBtn.selected = NO;
    }
    [UIView animateWithDuration:0 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
        weakSelf.emotionView.top = KScreenHeight;
        weakSelf.toolBar.top = KScreenHeight;
    } completion:NULL];
}
#pragma mark - Toolbar Show
- (void)showToolBarWithKeyboardUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    __weak typeof(self) weakSelf = self;
    if (keyboardUserInfo) {
        // 相对于键盘
        [QMUIKeyboardManager animateWithAnimated:NO keyboardUserInfo:keyboardUserInfo animations:^{
            CGFloat distanceFromBottom = [QMUIKeyboardManager distanceFromMinYToBottomInView:weakSelf.view keyboardRect:keyboardUserInfo.endFrame];
            weakSelf.keyboardHeight = fabs(distanceFromBottom);
            if (distanceFromBottom == 0)return;//过滤键盘高度为0的情况
            
            weakSelf.toolBar.top = KScreenHeight - weakSelf.keyboardHeight - weakSelf.toolBar.height;
            if (weakSelf.toolBar.emotionBtn.selected) {
                weakSelf.emotionView.top = KScreenHeight - PublishEmotionViewHeight;
                weakSelf.toolBar.top = KScreenHeight - PublishEmotionViewHeight - weakSelf.toolBar.height;
            }else{
                weakSelf.emotionView.top = KScreenHeight;
            }
        } completion:NULL];
    } else {
        // 相对于表情面板
        [UIView animateWithDuration:0.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            weakSelf.emotionView.layer.transform = CATransform3DMakeTranslation(0, -weakSelf.emotionView.height, 0);
        } completion:NULL];
    }
}
#pragma mark - Toolbar Hiddden
- (void)hideToolbarViewWithKeyboardUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    __weak typeof(self) weakSelf = self;
    if (keyboardUserInfo) {
        //相对于键盘
        if (_toolBar.emotionBtn.isSelected)
        {
            [UIView animateWithDuration:0.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
                weakSelf.emotionView.top = KScreenHeight - PublishEmotionViewHeight;
                weakSelf.toolBar.bottom = weakSelf.emotionView.top;
            } completion:NULL];
        }else
        {
            [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:keyboardUserInfo animations:^{
                weakSelf.emotionView.top = KScreenHeight;
                weakSelf.toolBar.top = KScreenHeight;
            } completion:NULL];
        }
    } else {
        //相对于表情
        [UIView animateWithDuration:0.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            weakSelf.emotionView.layer.transform = CATransform3DIdentity;
        } completion:NULL];
    }
}

#pragma mark - 表情键盘
- (void)onInputSystemFace:(NSInteger)index  emotion:(QMUIEmotion *)emotion {
    
    //去除 空格 \n 后
    NSInteger s = [self getMiddleTextView].maximumTextLength -  [[self getMidddleTextViewText] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length;
    if (s > emotion.displayName.length) {
        [[self getMiddleTextView] insertText:emotion.displayName];
    }else{
        [QMUITips showError:@"您无法再输入表情啦!" inView:[UIApplication sharedApplication].delegate.window hideAfterDelay:1.5];
        return;
    }
    if (self.isShare || _witnessModel.isEdit) {
        [self publishBtnEnable];
    }else {
        if (_selectedAssets.count > 0 && _selectedPhotos.count > 0) {
            id ass = _selectedAssets[0];
            TZAssetModelMediaType type = [CNImagePickerManager getAssetType:ass];
            if (type == TZAssetModelMediaTypeVideo) {
                [self publishBtnEnable];
            }else{
                if ([self.publishType isEqualToString:@"witness"]) {
                    [self publiahBtnNoEnable];
                }else{
                    [self publishBtnEnable];
                }
            }
        }else {
            if (CNLiveStringIsEmpty( [[self getMidddleTextViewText] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
                [self publiahBtnNoEnable];
            }else{
                if ([self.publishType isEqualToString:@"witness"]) {
                    [self publiahBtnNoEnable];
                }else{
                    [self publishBtnEnable];
                }
            }
        }
        
    }
}
#pragma mark 删除表情
- (void)deleteEmotionDisplayNameAtCurrentTextView:(UITextView *)textView {
    
    NSRange selectedRange = NSMakeRange(textView.text.length, 0);
    NSString *text = textView.text;
    
    // 没有文字或者光标位置前面没文字
    if (!text.length || NSMaxRange(selectedRange) == 0) {
        return;
    }
    
    NSArray *rightArr = [text componentsSeparatedByString:@"["];
    if (rightArr.count > 0) {
        NSString *emjStr = [NSString stringWithFormat:@"[%@",[rightArr lastObject]];
        NSArray<QMUIEmotion *> *arr = [CNLiveQQEmotionManager emotionsForQQ];
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (QMUIEmotion *emotion in arr) {
            [list addObject:emotion.displayName];
        }
        if (![list containsObject:emjStr]) {//除了自定义表情都删除一下
            [textView deleteBackward];
            return;
        }
    }
    //删除属于 [微笑]  的自定义表情
    NSInteger emotionDisplayNameMinimumLength = 3;// QQ表情里的最短displayName的长度
    NSInteger lengthForStringBeforeSelectedRange = selectedRange.location;
    NSString *lastCharacterBeforeSelectedRange = [text substringWithRange:NSMakeRange(selectedRange.location - 1, 1)];
    
    if ([lastCharacterBeforeSelectedRange isEqualToString:@"]"] && lengthForStringBeforeSelectedRange >= emotionDisplayNameMinimumLength) {
        NSInteger beginIndex = lengthForStringBeforeSelectedRange - (emotionDisplayNameMinimumLength - 1);// 从"]"之前的第n个字符开始查找
        NSInteger endIndex = MAX(0, lengthForStringBeforeSelectedRange - 5);// 直到"]"之前的第n个字符结束查找，这里写5只是简单的限定，这个数字只要比所有QQ表情的displayName长度长就行了
        
        for (NSInteger i = beginIndex; i >= endIndex; i --) {
            NSString *checkingCharacter = [text substringWithRange:NSMakeRange(i, 1)];
            if ([checkingCharacter isEqualToString:@"]"]) {
                // 查找过程中还没遇到"["就已经遇到"]"了，说明是非法的表情字符串，所以直接终止
                break;
            }
            
            if ([checkingCharacter isEqualToString:@"["]) {
                NSRange deletingDisplayNameRange = NSMakeRange(i, lengthForStringBeforeSelectedRange - i);
                textView.text = [text stringByReplacingCharactersInRange:deletingDisplayNameRange withString:@""];
                break;
            }
        }
    }
}


#pragma mark --tableView代理实现
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.publishType isEqualToString:@"witness"]) {
        return 2;
    }else {
        return 1;
    }
}
-(QMUITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        static NSString *cellId = @"normoalCell";
        CNLivePublishContentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[CNLivePublishContentCell alloc]initForTableView:self.tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.cellSelectDelegate = self;
            cell.delegate = self;
        }else{
            cell.cellSelectDelegate = self;
            cell.delegate = self;
        }
        
        return cell;
    }else if (indexPath.row == 1) {
        static NSString *witnessCell = @"witnessCell";
        CNLivePublishContentTagCell *tagCell = [tableView dequeueReusableCellWithIdentifier:witnessCell];
        if (tagCell == nil) {
            tagCell = [[CNLivePublishContentTagCell alloc]initForTableView:self.tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:witnessCell];
        }
        tagCell.tagArray = self.tagArray;
        tagCell.tagId = self.tagId;
        tagCell.witnessModel = self.witnessModel;
        tagCell.showTagId = self.showTagId;
        if (self.tagId > 0) {
            [tagCell setSelectedBtn:self.tagId - 1];
        }
        tagCell.tagBtnBlock = ^(NSString * _Nonnull tagName, NSInteger tagId, NSArray * _Nonnull tagArray,NSInteger showTagId) {
            weakSelf.tagName = tagName;
            weakSelf.tagId = tagId;
            weakSelf.tagArray = tagArray;
            weakSelf.showTagId = showTagId;
        };
        return tagCell;
    }else {
        return nil;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSInteger isSelectVideo = 1;
        if (_selectedPhotos.count > 0 && _selectedAssets.count > 0) {
            id ass = _selectedAssets[0];
            TZAssetModelMediaType type = [CNImagePickerManager getAssetType:ass];
            if (type == TZAssetModelMediaTypeVideo) {
                isSelectVideo = 0 ;// 如果是视频,隐藏z选择图片按钮
            }else {
                if (_selectedPhotos.count == 9) {
                    isSelectVideo = 0;
                }else {
                    isSelectVideo = 1;
                }
            }
        }else {
            isSelectVideo = 1;
        }
        NSInteger rowHeight = 0;
        CNLivePublishContentLayout *layout = [[CNLivePublishContentLayout alloc]init];
        rowHeight = [layout conllectionViewHeight:_selectedPhotos assetArray:_selectedAssets isSelectedVideo:isSelectVideo];
        if (self.isShare) {
            return (190+ZXShareHeight)*RATIO;
        }else {
            return rowHeight + 190*RATIO;
        }
    }else {
        return _footerHeight;
    }
    
    
}
#pragma mark - scrollView滑动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.tableView]) {
        if (![scrollView isKindOfClass:[QMUITextView class]]) {
            [self.view endEditing:YES];
            [self hideEmotionAndToolBar];
        }
    }
}
#pragma mark -Delegate
#pragma mark --textViewDelegate
-(void)textViewDidChangeTextView:(UITextView *)textView {
    
    NSString *totalText = textView.text;
    NSString *trimmText = [totalText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去除 空格 \n 后
    
    if (self.isShare || _witnessModel.isEdit) {
        [self publishBtnEnable];
    }else {
        if (_selectedAssets.count > 0 && _selectedPhotos.count > 0) {
            id ass = _selectedAssets[0];
            TZAssetModelMediaType type = [CNImagePickerManager getAssetType:ass];
            if (type == TZAssetModelMediaTypeVideo) {
                [self publishBtnEnable];
            }else{
                if ([self.publishType isEqualToString:@"witness"]) {
                    [self publiahBtnNoEnable];
                }else{
                    [self publishBtnEnable];
                }
            }
        }else {
            if ([trimmText isEqualToString:@""]) {
                [self publiahBtnNoEnable];
            }else{
                if ([self.publishType isEqualToString:@"witness"]) {
                    [self publiahBtnNoEnable];
                }else{
                    [self publishBtnEnable];
                }
            }
        }
        
    }
    
    
}
-(void)shouldBeginEditingTextView:(UITextView *)textView {
    _toolBar.emotionBtn.selected = NO;
}


#pragma mark -collectionView delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemNsIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了collectionViewcell");
    __weak typeof(self) weakSelf = self;
    if ([[self getMiddleTextView] isFirstResponder]) {
        [[self getMiddleTextView] resignFirstResponder];
        _toolBar.top = KScreenHeight;
        _emotionView.top = KScreenHeight;
    }
    if (indexPath.row == _selectedPhotos.count) {
        [self cameraAction];
    }else {
        
        id asset = _selectedAssets[indexPath.row];
        BOOL isVideo = NO;
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = asset;
            isVideo = phAsset.mediaType == PHAssetMediaTypeVideo;
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = asset;
            isVideo = [[alAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo];
        }
        if (isVideo) { // perview video / 预览视频
            TZVideoPlayerController *vc = [[TZVideoPlayerController alloc] init];
            TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypeVideo timeLength:@""];
            vc.isOther = YES;//(LXG)相册外进入
            vc.model = model;
//            vc.videoFinishedAction = ^(TZAssetModel *model, BOOL isOther) {
//#pragma mark - TODO:
//                if (weakSelf.isStop) {
//                    [[CNAudioPlayerManager sharedInstance]resumePlaying];
//                    weakSelf.isStop = NO;
//                }
//            };
            
//            if ([CNAudioOrVideoMananger IsEnter]) {//在房间
//                [QMUITips showWithText:@"音视频通话中..." inView:AppKeyWindow hideAfterDelay:1.5];
//                return;
//            }
//            if ([[CNAudioPlayerManager sharedInstance]isPlaying]) {
//                self.isStop = YES;
//                [[CNAudioPlayerManager sharedInstance]pausePlaying];
//            }
            [self presentViewController:vc animated:YES completion:nil];
        }
        else { // preview photos / 预览照片//lxg
#pragma mark - TODO:预览照片
            
            [CNImagePickerManager ImagePickerWithMaxImagesCount:9 delegate:self selectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.row isSelectOriginalPhoto:_isSelectOriginalPhoto enterType:CNImagePickerEnterTypeFriendsCircle pickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                weakSelf.selectedPhotos = [NSMutableArray arrayWithArray:photos];
                weakSelf.selectedAssets = [NSMutableArray arrayWithArray:assets];
                weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
                [weakSelf getBottomCell].selectedAssets = weakSelf.selectedAssets;
                [weakSelf getBottomCell].selectedPhotos = weakSelf.selectedPhotos;
                [[weakSelf getBottomCell] updateCollectionViewWithAssets:weakSelf.selectedAssets isSelectOriginalPhoto:weakSelf.isSelectOriginalPhoto];
                [weakSelf.tableView reloadData];
            }];
        }
    }
    
}
-(void)deledteBtnClick:(NSMutableArray *)selectedPhotos selectedAssets:(NSMutableArray *)selectedAssets {
    
}
#pragma mark - Target Action
#pragma mark -拍摄

- (void)cameraAction
{
     __weak typeof(self) weakSelf = self;
    [self.view createAlertViewTitleArray:@[@"拍摄",@"从手机相册选择"] subTitleArr:@[@"照片或视频",@""] textColor:UIColorMake(40, 40, 40) subTitleColor:UIColorMake(152, 152, 152) font:UIFontMake(15) subFont:UIFontMake(12) actionBlock:^(UIButton *button, NSInteger didRow) {
        switch (didRow) {
            case 0:
            {
//                if ([CNAudioOrVideoMananger IsEnter]) {//在房间
//                    [QMUITips showWithText:@"音视频通话中..." inView:AppKeyWindow hideAfterDelay:1.5];
//                    return;
//                }
                NSLog(@"拍摄");
                //音视频通话
//                if ([CNAudioOrVideoMananger IsEnter]) {//在房间
//                    [QMUITips showWithText:@"音视频通话中..." inView:AppKeyWindow hideAfterDelay:1.5];
//                    return;
//                }
                [weakSelf takeToXFPhoto];
                
            }
                break;
            case 1:
            {
                NSLog(@"从手机相册选择");
//                if ([[CNAudioPlayerManager sharedInstance]isPlaying]) {
//                    weakSelf.isStop = YES;
//                    [[CNAudioPlayerManager sharedInstance]pausePlaying];
//                }
                [weakSelf pushTZImagePickerController];
            }
                break;
            default:
                break;
        }
    }];
}
#pragma mark - 跳转到自定义相机
-(void)takeToXFPhoto {
    XFCameraController *cameraController = [[XFCameraController alloc]init];
    if (_selectedPhotos.count > 0 && _selectedAssets.count > 0) {
        cameraController.isCanShootVideo = NO;
    }else {
        cameraController.isCanShootVideo = YES;
    }
    if ([self.publishType isEqualToString:@"witness"]) {
        cameraController.isNoCanTakePhoto = YES;
    }else {
        cameraController.isNoCanTakePhoto = NO;
    }
    __weak XFCameraController *weakCameraController = cameraController;
    cameraController.takePhotosCompletionBlock = ^(UIImage *image, NSError *error) {
        if (!error) {
            [self didFinishSelectPhotoWithImage:image];
            if ([self.publishType isEqualToString:@"witness"]) {
                [self publiahBtnNoEnable];
            }else {
                [self publishBtnEnable];
            }
            dispatch_async_on_main_queue(^{
                [weakCameraController dismissViewControllerAnimated:YES completion:nil];
            });
        }
        
    };
    
    //拍摄的是视频
    cameraController.zxshootCompletionBlock = ^(PHAsset *asset, NSURL *videoUrl, CGFloat videoTimeLength, UIImage *thumbnailImage, NSError *error) {
        if (!error) {
            [self didFinishShootVideoWithAsset:asset videoUrl:videoUrl image:thumbnailImage];
            [self publishBtnEnable];
            dispatch_async_on_main_queue(^{
                [weakCameraController dismissViewControllerAnimated:YES completion:nil];
            });
        }
        
    };
    [self presentViewController:cameraController animated:YES completion:nil];
}
#pragma mark - TZImagePickerController 从相册选择图片
-(void)pushTZImagePickerController {
    __weak typeof(self) weakSelf = self;
    CNImagePickerEnterType type ;
    if ([self.publishType isEqualToString:@"witness"]) {
        type = CNImagePickerEnterTypeWitness;
    }else {
        type = CNImagePickerEnterTypeFriendsCircle;
    }
    [CNImagePickerManager ImagePickerWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:YES isSelectOriginalPhoto:_isSelectOriginalPhoto selectedAssets:_selectedAssets enterType:type pickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        //        if (weakSelf.isStop) {
        //            [[CNAudioPlayerManager sharedInstance]resumePlaying];
        //            weakSelf.isStop = NO;
        //        }
        //        NSLog(@"打印啊啊啊啊啊啊啊%@",photos);
        weakSelf.selectedPhotos = [NSMutableArray arrayWithArray:photos];
        weakSelf.selectedAssets = [NSMutableArray arrayWithArray:assets];
        if (weakSelf.selectedPhotos.count > 0 && weakSelf.selectedAssets.count > 0) {
            
            id ass = weakSelf.selectedAssets[0];
            TZAssetModelMediaType type = [CNImagePickerManager getAssetType:ass];
            if ([self.publishType isEqualToString:@"witness"]) {
                if (type == TZAssetModelMediaTypeVideo) {
                    if ([weakSelf getMiddleTextView].text.length > 140) {
                        [QMUITips showError:@"目击者标题只能输入140字符" inView:self.view hideAfterDelay:2.0];
                        [weakSelf publiahBtnNoEnable];
                    }else {
                        [weakSelf publishBtnEnable];
                    }
                }else {
                    [QMUITips showError:@"目击者请选择视频" inView:self.view hideAfterDelay:2.0];
                    [weakSelf publiahBtnNoEnable];
                }
            }else {
                [weakSelf publishBtnEnable];
            }
        }
        
        [weakSelf getBottomCell].selectedAssets = weakSelf.selectedAssets;
        [weakSelf getBottomCell].selectedPhotos = weakSelf.selectedPhotos;
        [[weakSelf getBottomCell] updateCollectionViewWithAssets:assets isSelectOriginalPhoto:weakSelf.isSelectOriginalPhoto];
        [weakSelf.tableView reloadData];
    }];
}
#pragma mark -- 照相选中图片
-(void)didFinishSelectPhotoWithImage:(UIImage *)finalImage {
    
    TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    tzImagePickerVc.sortAscendingByModificationDate = YES;
    [tzImagePickerVc showProgressHUD];
    UIImage *image = finalImage;
    // 保存图片,获取到asset
    CLLocation *location = [[CLLocation alloc]initWithLatitude:self.latitude longitude:self.longitude];
    [[TZImageManager manager] savePhotoWithImage:image location:location completion:^(NSError *error) {
        if (error) {
            [tzImagePickerVc hideProgressHUD];
            NSLog(@"图片保存失败 %@",error);
        } else {
            [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES needFetchAssets:YES completion:^(TZAlbumModel *model) {
                [[TZImageManager manager]getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                    [tzImagePickerVc hideProgressHUD];
                    TZAssetModel *assetModel = [models firstObject];
                    if (tzImagePickerVc.sortAscendingByModificationDate) {
                        assetModel = [models lastObject];
                    }
                    dispatch_async_on_main_queue(^{
                        [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                    });
                    
                }];
            }];
        }
    }];
}
#pragma mark - 选中视频
- (void)didFinishShootVideoWithAsset:(PHAsset *)asset videoUrl:(NSURL *)videoUrl image:(UIImage *)coverImage {
    TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    tzImagePickerVc.sortAscendingByModificationDate = YES;
    [tzImagePickerVc showProgressHUD];
    [self refreshCollectionViewWithAddedAsset:asset image:coverImage];
    [tzImagePickerVc hideProgressHUD];
    
}
#pragma  mark - 刷新collectionView
- (void)refreshCollectionViewWithAddedAsset:(id)asset image:(UIImage *)image {
    
    [_selectedAssets addObject:asset];
    [_selectedPhotos addObject:image];
    [self getBottomCell].selectedAssets = _selectedAssets;
    [self getBottomCell].selectedPhotos = _selectedPhotos;
    [[self getBottomCell] updateCollectionViewWithAssets:_selectedAssets isSelectOriginalPhoto:_isSelectOriginalPhoto];
    [self.tableView reloadData];
}
#pragma mark -TZImagePicker delegate
#pragma mark -取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
//    if (self.isStop) {
//        [[CNAudioPlayerManager sharedInstance]resumePlaying];
//        self.isStop = NO;
//    }
}
//allocMutiSeleVideo 为NO时会走下面的回调,为YES会走didFinishPickingPhotos回调
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
//    if (self.isStop) {
//        [[CNAudioPlayerManager sharedInstance]resumePlaying];
//        self.isStop = NO;
//    }
    [self publishBtnEnable];
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    [self getBottomCell].selectedAssets = _selectedAssets;
    [self getBottomCell].selectedPhotos = _selectedPhotos;
    [[self getBottomCell] updateCollectionViewWithAssets:_selectedAssets isSelectOriginalPhoto:_isSelectOriginalPhoto];
    [self.tableView reloadData];
}

// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
//    if (self.isStop) {
//        [[CNAudioPlayerManager sharedInstance]resumePlaying];
//        self.isStop = NO;
//    }
    [self publishBtnEnable];
    _selectedPhotos = [NSMutableArray arrayWithArray:@[animatedImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    [self getBottomCell].selectedAssets = _selectedAssets;
    [self getBottomCell].selectedPhotos = _selectedPhotos;
    [[self getBottomCell] updateCollectionViewWithAssets:_selectedAssets isSelectOriginalPhoto:_isSelectOriginalPhoto];
    [self.tableView reloadData];
}

// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    return YES;
}
// 决定asset显示与否
- (BOOL)isAssetCanSelect:(id)asset {
    if (iOS8Later) {
        PHAsset *phAsset = asset;
        switch (phAsset.mediaType) {
            case PHAssetMediaTypeVideo: {
                return YES;
            } break;
            case PHAssetMediaTypeImage: {
                return YES;
            } break;
            case PHAssetMediaTypeAudio:
                return NO;
                break;
            case PHAssetMediaTypeUnknown:
                return NO;
                break;
            default: break;
        }
    } else {
        ALAsset *alAsset = asset;
        NSString *alAssetType = [[alAsset valueForProperty:ALAssetPropertyType] stringValue];
        if ([alAssetType isEqualToString:ALAssetTypeVideo]) {
            // 视频时长
            
            ALAssetRepresentation *represent = [alAsset defaultRepresentation];
            NSUInteger size = [represent size];
            int fileSize = (int)size;
            if (fileSize < 20 * 1024 * 1024)
            {//小于20M & < 15s
                NSTimeInterval duration = [[alAsset valueForProperty:ALAssetPropertyDuration] doubleValue];
                
                if (duration > 15) {
                    return NO;
                }
                return YES;
            }
        } else if ([alAssetType isEqualToString:ALAssetTypePhoto]) {
            // 图片大小 <10M
            long long imgDataSize = alAsset.defaultRepresentation.size;
            if (imgDataSize > 10 * 1024 * 1024) {
                return NO;
            }
            return YES;
        } else if ([alAssetType isEqualToString:ALAssetTypeUnknown]) {
            return NO;
        }
    }
    return YES;
}

// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
}

/** 从相册选完照片(选图片时isSelectOriginalPhoto值有用,视频没用)或者视频 */
// 在选完图片的时候,会调用这个方法
- (void)photoFinishselectedPhotos:(NSMutableArray *)selectedPhotos selectedAssets:(NSMutableArray *)selectedAssets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    [self publishBtnEnable];
    [_selectedAssets addObjectsFromArray:selectedAssets];
    [_selectedPhotos addObjectsFromArray:selectedPhotos];
    [self getBottomCell].selectedAssets = _selectedAssets;
    [self getBottomCell].selectedPhotos = _selectedPhotos;
    [[self getBottomCell] updateCollectionViewWithAssets:_selectedAssets isSelectOriginalPhoto:_isSelectOriginalPhoto];
    [self.tableView reloadData];
}
#pragma mark - 定位
-(void)startLocation {
    
    __weak typeof(self) weakSelf = self;
    [CNLiveLocationManager  getLocation:^(CLLocationDegrees latitude, CLLocationDegrees longitude) {
        
        NSLog(@"纬度显示%f,%f",latitude,longitude);
        self.latitude = latitude;
        self.longitude = longitude;
        [self getcity];
        
    } failure:^(id error) {
        
        weakSelf.currentCity = @"";
        [weakSelf.toolBar.locationBtn setTitle:@"当前位置" forState:UIControlStateNormal];
        if (weakSelf.isShare) {
            [weakSelf publishBtnEnable];
        }else {
            if ((weakSelf.selectedAssets.count > 0 && weakSelf.selectedPhotos.count > 0) ) {
                [weakSelf publishBtnEnable];
            }else{
                NSString *totalText = [self getMidddleTextViewText];
                NSString *trimmText = [totalText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去除 空格 \n 后
                if ([trimmText isEqualToString:@""]) {
                    [weakSelf publiahBtnNoEnable];
                }else {
                    [weakSelf publishBtnEnable];
                }
            }
        }
        [weakSelf.toolBar.indicator stopAnimating];
        NSLog(@"定位失败11, 错误: %ld",[(NSError *)error code]);
        switch([(NSError *)error code]) {
            case kCLErrorDenied: { // 用户禁止了定位权限
                if (weakSelf.isClickBtn) {
                    [weakSelf showLocationAlert];
                }else
                {
                    return;
                }
                
            } break;
            default: break;
        }
        
    }];
}
-(void)getcity {
    
    CLLocationCoordinate2D  locationCoordinate2D = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    __weak typeof(self) weakSelf = self;
    [CNLiveLocationManager getLocationWithCoordinate2D:locationCoordinate2D PlacemarkBlock:^(CNLivePlacemark *placemark) {
        weakSelf.currentCity = placemark.city;
        NSLog(@"打印当前位置%@",weakSelf.currentCity);
        NSLog(@"结果%@-%@-%@-%@-%@",placemark.country,placemark.province,placemark.city,placemark.county,placemark.address);
        if (!weakSelf.currentCity) {
            weakSelf.currentCity = @"";
            [weakSelf.toolBar.locationBtn setTitle:@"当前位置" forState:UIControlStateNormal];
            [weakSelf.toolBar.indicator stopAnimating];
        }else{
            
            [weakSelf.toolBar.locationBtn setTitle:weakSelf.currentCity forState:UIControlStateNormal];
            [weakSelf.toolBar.indicator stopAnimating];
            if (weakSelf.isShare) {
                [weakSelf publishBtnEnable];
            }else {
                if (weakSelf.selectedAssets.count > 0 && weakSelf.selectedPhotos.count > 0) {
                    [weakSelf publishBtnEnable];
                }else{
                    NSString *totalText = [weakSelf getMidddleTextViewText];
                    NSString *trimmText = [totalText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去除 空格 \n 后
                    if ([trimmText isEqualToString:@""]) {
                        [weakSelf publiahBtnNoEnable];
                    }else {
                        [weakSelf publishBtnEnable];
                    }
                }
            }
        }
        
    } failure:^(id error) {
        NSLog(@"打印这个error%@",error);
        weakSelf.currentCity = @"";
        [weakSelf.toolBar.locationBtn setTitle:@"当前位置" forState:UIControlStateNormal];
        [weakSelf.toolBar.indicator stopAnimating];
        if (weakSelf.isShare) {
            [weakSelf publishBtnEnable];
        }else {
            if (weakSelf.selectedAssets.count > 0 && weakSelf.selectedPhotos.count > 0) {
                [weakSelf publishBtnEnable];
            }else{
                NSString *totalText = [weakSelf getMidddleTextViewText];
                NSString *trimmText = [totalText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去除 空格 \n 后
                if ([trimmText isEqualToString:@""]) {
                    [weakSelf publiahBtnNoEnable];
                }else {
                    [weakSelf publishBtnEnable];
                }
            }
        }
    }];
}
- (void)showLocationAlert
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    if (appName == nil)
    {
        appName = @"APP";
    }
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"无法获取你的位置信息。请在iPhone的“设置-隐私-定位服务”选项中打开定位服务，允许%@使用定位服务。",appName] preferredStyle:UIAlertControllerStyleAlert];//@"允许\"定位\"提示" @"请在设置中打开定位"
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {//取消
        
        
    }];
    [alertVC addAction:cancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}
// 获取第二个cell上面的textView
-(QMUITextView *)getMiddleTextView {
    CNLivePublishContentCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cell.titleTextView;
}
// 获取第二个Cell上面textVie的text
-(NSString *)getMidddleTextViewText {
    CNLivePublishContentCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *textStr;
    
    if (CNLiveStringIsEmpty(cell.titleTextView.text)) {
        textStr = @" ";
    }else{
        textStr  = cell.titleTextView.text ;
    }
    return textStr;
}
// 获取第三个cell
-(CNLivePublishContentCell *)getBottomCell {
    CNLivePublishContentCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cell;
}
-(CNLivePublishContentTagCell *)getTagCell {
    CNLivePublishContentTagCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    return cell;
}
#pragma mark --按钮可点击
-(void)publishBtnEnable {
    _publishBtn.enabled = YES;
    _publishBtn.backgroundColor = [UIColor qmui_colorWithHexString:@"#FF23D41E"];
    //    _publishBtn.backgroundColor = CNLiveColorWithHexString(KGreenColor);
    [_publishBtn setTitleColor:[UIColor qmui_colorWithHexString:@"#FFFFFFFF"] forState:UIControlStateNormal];
}
#pragma mark -按钮不可点击
-(void)publiahBtnNoEnable {
    _publishBtn.enabled = NO;
    _publishBtn.backgroundColor = [UIColor qmui_colorWithHexString:@"#F0F0F0"];
    [_publishBtn setTitleColor:[UIColor qmui_colorWithHexString:@"#9C9C9C"] forState:UIControlStateNormal];
}
- (NSString *)objectToJson:(id)obj{
    if (obj == nil) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:0
                                                         error:&error];
    
    if ([jsonData length] && error == nil){
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }else{
        return nil;
    }
}
-(NSArray *)tagArray{
    if (_tagArray == nil) {
        _tagArray = [NSArray array];
    }
    return _tagArray;
}
- (QMUIEmotionView *)emotionView
{
    if (!_emotionView) {
        CNLiveQQEmotionManager *emoManager = [[CNLiveQQEmotionManager alloc] init];
        emoManager.emotionView.frame = CGRectMake(0, kScreenHeight - PublishEmotionViewHeight, kScreenWidth, PublishEmotionViewHeight);
        _emotionView = emoManager.emotionView;
        _emotionView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.97 alpha:1.00];
        _emotionView.sendButton.hidden = YES;
        _emotionView.qmui_borderPosition = QMUIToastViewPositionTop;
        _emotionView.numberOfRowsPerPage = 3;
        _emotionView.paddingInPage = UIEdgeInsetsMake(18, 18, 50, 18);
        _emotionView.minimumEmotionHorizontalSpacing = 15;
        _emotionView.pageControlMarginBottom = 0;
        emoManager.boundTextView = [self getMiddleTextView];
        weakself
        emoManager.emotionView.didSelectEmotionBlock = ^(NSInteger index, QMUIEmotion *emotion) {
            [weakSelf onInputSystemFace:index emotion:emotion];
        };
        emoManager.emotionView.didSelectDeleteButtonBlock = ^{
            if ([[weakSelf getMidddleTextViewText] isEqualToString:@""]) {
                return;
            }
            [weakSelf deleteEmotionDisplayNameAtCurrentTextView:[weakSelf getMiddleTextView]];
        };
    }
    
    if (_keyboardHeight != (kScreenHeight - _toolBar.height - PublishEmotionViewHeight)) {
        _emotionView.top = kScreenHeight - PublishEmotionViewHeight;
        _emotionView.height = PublishEmotionViewHeight;
    }
    return _emotionView;
}
@end
