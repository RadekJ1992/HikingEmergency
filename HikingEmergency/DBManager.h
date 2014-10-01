#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MapPin.h"
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

//wymuszenie zamknięcia połączenia (jakby coś się popsuło)
-(void) forceCloseDatabase;

@end
