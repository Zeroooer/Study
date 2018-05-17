//
//  ContactListViewController.m
//  KVCDemo
//
//  Created by Hisen on 10/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "ContactListViewController.h"
#import "Contact.h"
#import "ContactCell.h"
#import "DetialViewController.h"

@interface ContactListViewController ()

@property (nonatomic, strong) NSArray<Contact *> *contacts;

@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateVisibleCells];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - config
- (void)configDataSource {
    NSMutableArray *dataSource = [NSMutableArray new];
    for (int i = 1; i<=20; i++) {
        [dataSource addObject:[Contact contactWithRancomName]];
    }
    self.contacts = [dataSource copy];
}

- (void)updateVisibleCells {
    for (ContactCell *cell in self.tableView.visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [cell configWithContact: [self.contacts objectAtIndex:indexPath.row]];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_contacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [cell configWithContact: [self.contacts objectAtIndex:indexPath.row]];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        DetialViewController *detailVC = segue.destinationViewController;
        detailVC.contact = [self.contacts objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    } else {
        NSAssert(NO, @"Unknown segue");
    }
}


@end
