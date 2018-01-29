
#import "SCHomeViewController.h"
#import "SCPost.h"
#import "SCHomeTableViewCell.h"
#import "SCSignInViewController.h"
#import "SCUserManager.h"
#import "SCPostManager.h"
#import "SCCreatePostViewController.h"
#import "SCLocationManager.h"

static NSString * const SCHomeCellIdentifier = @"homeCellIdentifier";

@interface SCHomeViewController () <UITableViewDataSource, UITableViewDelegate, SCSignInViewControllerDelegate, SCCreatePostViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<SCPost *> *posts;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) BOOL resultMode;
@end

@implementation SCHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // show post list for SCExploreViewController
    if (self.resultMode) {
        [self setupTableView];
        return;
    }
    
    // load data
    [self loadPosts];
    
    // load UI
    [self setupUI];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPosts) name:SCLocationUpdateNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // check user login or not
    [self userLoginIfRequire];
}

#pragma mark -- public
- (void)loadResultPageWithPosts:(NSArray <SCPost *>*)posts
{
    self.posts = posts;
    self.resultMode = YES;
    [self.tableView reloadData];
}

#pragma mark -- private
- (void)userLoginIfRequire
{
    if (![[SCUserManager sharedUserManager] isUserLogin]) {
        SCSignInViewController *signInViewController = [[SCSignInViewController alloc] initWithNibName:NSStringFromClass([SCSignInViewController class]) bundle:nil];
        signInViewController.delegate = self;
        
        [self presentViewController:signInViewController animated:YES completion:nil];
    }
}

#pragma mark - SCSignInViewControllerDelegate
- (void)loginSuccess
{
    [self loadPosts];
}


#pragma mark - UI
- (void)setupUI
{
    [self setupTableView];
    [self setupNavigationBarUI];
    [self setupRefreshControlUI];
}

- (void)setupTableView
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SCHomeTableViewCell class]) bundle:nil] forCellReuseIdentifier:SCHomeCellIdentifier];
}

- (void)setupNavigationBarUI
{
    self.title = NSLocalizedString(@"Home", nil);
    self.navigationController.navigationBar.tintColor = [UIColor darkTextColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PostEvent"] style:UIBarButtonItemStyleDone target:self action:@selector(showCreatePostPage)];
}

- (void)setupRefreshControlUI
{
    self.refreshControl = [UIRefreshControl new];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(loadPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}



#pragma mark - action
- (void)showCreatePostPage
{
    SCCreatePostViewController *createPostViewController = [[SCCreatePostViewController alloc] initWithNibName:NSStringFromClass([SCCreatePostViewController class]) bundle:nil];
    createPostViewController.delegate = self;
    [self.navigationController pushViewController:createPostViewController animated:YES];
}

#pragma mark - SCCreatePostViewControllerDelegate
- (void)didCreatePost
{
    [self loadPosts];
}

#pragma mark - API
- (void)loadPosts
{
    if (self.resultMode) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    CLLocation *location = [[SCLocationManager sharedManager] getUserCurrentLocation];
    NSInteger range = 300000;
    [SCPostManager getPostsWithLocation:location range:range andCompletion:^(NSArray<SCPost *> *posts, NSError *error) {
        if (posts) {
            weakSelf.posts = posts;
            [weakSelf.tableView reloadData];
            NSLog(@"get posts count:%ld", (long)posts.count);
        }
        else {
            NSLog(@"error: %@", error);
        }
    }];
    [self.refreshControl endRefreshing];
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCHomeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SCHomeCellIdentifier];
    if (self.posts.count > indexPath.row) {
        [cell loadCellWithPost:self.posts[indexPath.row]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SCHomeTableViewCell cellHeight];
}


@end
