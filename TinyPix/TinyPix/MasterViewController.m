//
//  MasterViewController.m
//  TinyPix
//
//  Created by shoron on 15/12/9.
//  Copyright © 2015年 com. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "TinyPixDocument.h"
#import "TinyPixUtils.h"
#import "SRConstants.h"

@interface MasterViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISegmentedControl *colorControl;
@property (strong, nonatomic) NSArray *documentFileNames;
@property (strong, nonatomic) TinyPixDocument *chosenDocument;

@end

@implementation MasterViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedColorIndex = [userDefaults integerForKey:kUserDefaultsKeySelectedColorIndex];
    [self setTintColorForIndex:selectedColorIndex];
    [self.colorControl setSelectedSegmentIndex:selectedColorIndex];
    [self reloadFiles];
}

#pragma mark

- (NSURL *)urlForFileName:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory
                                        inDomains:NSUserDomainMask];
    return [urls[0] URLByAppendingPathComponent:fileName];
}

- (void)reloadFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *dirError;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:paths[0] error:&dirError];
    if (!files) {
        NSLog(@"failure listing files in directory %@: %@",paths[0],dirError);
    } else {
        NSLog(@"found files success %@",files);
    }
    
    files = [files sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *attribute1 = [fileManager attributesOfItemAtPath:[paths[0] stringByAppendingPathComponent:obj1]
                                                                 error:nil];
        NSDictionary *attribute2 = [fileManager attributesOfItemAtPath:[paths[0] stringByAppendingPathComponent:obj2]
                                                                 error:nil];
        return [attribute2[NSFileCreationDate] compare:attribute1[NSFileCreationDate]];
        
    }];
    self.documentFileNames = files;
    [self.tableView reloadData];
}

#pragma mark - UIButtonHandler

- (IBAction)chooseColor:(id)sender {
    NSInteger selectedColorIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
    [self setTintColorForIndex:selectedColorIndex];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:selectedColorIndex forKey:kUserDefaultsKeySelectedColorIndex];
    [userDefaults synchronize];
}

- (void)insertNewObject {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose File Name"
                                                                             message:@"Enter a name for you new TinyPix document"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = (UITextField *)alertController.textFields[0];
        [self createFile:textField.text];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:createAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setTintColorForIndex:(NSInteger)selectedColorIndex {
    self.colorControl.tintColor = [TinyPixUtils getTintColorForIndex:selectedColorIndex];
}

- (void)createFile:(NSString *)fileName {
    NSString *trimedFileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimedFileName.length > 0) {
        NSString * targetName = [NSString stringWithFormat:@"%@.tinypix",trimedFileName];
        NSURL *saveUrl = [self urlForFileName:targetName];
        self.chosenDocument = [[TinyPixDocument alloc] initWithFileURL:saveUrl];
        [self.chosenDocument saveToURL:saveUrl forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            // 这个代码块在主线程中调用
            if (success) {
                NSLog(@"save success ");
                [self reloadFiles];
                [self performSegueWithIdentifier:@"masterToDetail" sender:self];
            } else {
                NSLog(@"save failure ");
            }
        }];
    }
}

#pragma mark - Switch ViewContrller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *destination = (UINavigationController *)segue.destinationViewController;
    DetailViewController *detailViewController = (DetailViewController *)destination.topViewController;
    if (sender == self) {
        // 此时说明刚刚创建好了一个新文档，并且Property chosenDocument已经被设置好了。
        detailViewController.detailItem = self.chosenDocument;
    } else {
        // 查找表视图中的文档
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *fileName = self.documentFileNames[indexPath.row];
        NSURL *documentUrl = [self urlForFileName:fileName];
        self.chosenDocument = [[TinyPixDocument alloc] initWithFileURL:documentUrl];
        [self.chosenDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"load success ");
                detailViewController.detailItem = self.chosenDocument;
            } else {
                NSLog(@"load failure ");
            }
        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.documentFileNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell" forIndexPath:indexPath];
    NSString *path = self.documentFileNames[indexPath.row];
    cell.textLabel.text = path.lastPathComponent.stringByDeletingPathExtension;
    return cell;
}

@end
