//
//  RoutesListViewController.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 11.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
/**
 ViewController pokazujący listę dostępnych wydarzeń. Implementuje protokoły UITableViewDelegate i UITableViewDataSource w celu obsługi tabeli wydarzeń
 */
@interface RoutesListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
/**
 tabela z wydarzeniami
 */
@property (weak, nonatomic) IBOutlet UITableView *routeTable;
/**
 tablica z nazwami wydarzeń pobrana z bazy danych
 */
@property (strong, nonatomic) NSMutableArray *routeNames;
/**
 wybrane wydarzenie
 */
@property (strong, nonatomic) Route* route;

@end
