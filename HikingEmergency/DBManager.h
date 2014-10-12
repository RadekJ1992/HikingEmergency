//
//  DBManager.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 06.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MapPin.h"
#import "Route.h"
/**
 Singleton obsługujący połączenie z bazą danych
 W bazie danych jest tabela przechowująca historię lokalizacji użytkownika
 
 */
@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;

//utworzenie bazy danych
-(BOOL)createDB;

//wprowadzenie lokalizacji użytkownika do bazy
-(BOOL) insertUserLocation:(CLLocationCoordinate2D) coordinates;

//pobranie lokalizacji użytkownika
-(NSMutableArray*) getUserLocations;

//pobranie ostatniej lokalizacji użytkownika
-(MapPin*) getLastUserLocation;

//Wprowadzenie nowej trasy do bazy
-(BOOL) createNewRoute:(Route*) route;

//Wstawienie nowej trasy do bazy
-(Route*) getRouteWithName:(NSString*) name;

//Pobranie wszystkich nazw tras z bazy
-(NSMutableArray*) getAllRoutesNames;

//Usunięcie trasy
-(BOOL) deleteRouteWithName:(NSString*) name;

//wymuszenie zamknięcia połączenia (jakby coś się popsuło)
-(void) forceCloseDatabase;


@end
