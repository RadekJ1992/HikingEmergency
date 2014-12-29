//
//  RoutesListViewController.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 11.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "RoutesListViewController.h"
#import "AppDelegate.h"
#import "NavigateViewController.h"
#import "LocationsController.h"
@interface RoutesListViewController ()

@end

@implementation RoutesListViewController

@synthesize routeTable;
@synthesize routeNames;
@synthesize route;
/**
 obsługa przekazywania obiektów między viewControllerami
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"routeToShow"]) {
        if (route) {
            NavigateViewController *nVC = [segue destinationViewController];
            nVC.route = route;
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //załaduj dane z bazy
    self.routeTable.dataSource = self;
    self.routeTable.delegate = self;
    self.routeTable.allowsMultipleSelectionDuringEditing = NO;
    routeNames = [[DBManager getSharedInstance] getAllRoutesNames];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [routeNames count];
}

//utworzenie komórki w tabeli
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *unifiedID = @"aCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:unifiedID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:unifiedID];
        
    }
    
    cell.textLabel.text = [routeNames objectAtIndex:[indexPath row]];
    return cell;
    
}
//zaznaczenie komórki w tabelu i wywołanie jej viewControllera
- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    
    UITableViewCell* cell = (UITableViewCell *)[[self routeTable] cellForRowAtIndexPath:indexPath];
    NSString* routeName = cell.textLabel.text;
    route = [[DBManager getSharedInstance] getRouteWithName:routeName];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier: @"routeToShow" sender: nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}
//usunięcie trasy z bazy danych przez przesunięcie jego komórki w tabeli w lewo i zaznaczenie "usuń"
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UITableViewCell* cell = (UITableViewCell *)[[self routeTable] cellForRowAtIndexPath:indexPath];
        NSString* routeName = cell.textLabel.text;
        [[DBManager getSharedInstance] deleteRouteWithName:routeName];
        dispatch_async(dispatch_get_main_queue(), ^{
            routeNames = [[DBManager getSharedInstance] getAllRoutesNames];
            [routeTable reloadData];
        });
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
