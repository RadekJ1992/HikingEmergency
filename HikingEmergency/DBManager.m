//
//  DBManager.m
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 06.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "DBManager.h"
static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBManager

+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"hikingEmergency.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            //włączenie kluczy obcych, domyślnie są wyłączone w celu zapewnienia kompatybilności wstecz z poprzednimi wersjami sqlite
            char *errMsg0;
            const char *sql_pragma_stmt = "PRAGMA foreign_keys=ON";
            if (sqlite3_exec(database, sql_pragma_stmt, NULL, NULL, &errMsg0)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to execute pragma query, %s", errMsg0);
            }
            //utworzenie tabeli przechowującej lokalizację użytkownika
            char *errMsg1;
            const char *sql_stmt_usrloc =
            "create table if not exists userLocationsTable (id integer primary key autoincrement, userLocationLatitude real, userLocationLongitude real, updateDate text)";
            if (sqlite3_exec(database, sql_stmt_usrloc, NULL, NULL, &errMsg1)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create locations table, %s", errMsg1);
            }
            //utworzenie tabeli przechowującej punkty tras
            char *errMsg2;
            const char *sql_stmt_routepoints =
            "create table if not exists routePointsTable (routeName text, routeIndex number, locationLatitude real, locationLongitude real, primary key (routeName, routeIndex))";
            if (sqlite3_exec(database, sql_stmt_routepoints, NULL, NULL, &errMsg2)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create route points table, %s", errMsg2);
            }

            sqlite3_close(database);
            return  isSuccess;
        }
    }
    else {
        isSuccess = NO;
        NSLog(@"Database Exists");
    }
    return isSuccess;
}


-(BOOL) insertUserLocation:(CLLocationCoordinate2D)coordinates {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into userLocationsTable (userLocationLatitude, userLocationLongitude, updateDate) values (%f,%f,'%@')", coordinates.latitude, coordinates.longitude, dateString];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        int i = sqlite3_step(statement);
        if (i== SQLITE_DONE)
        {
            sqlite3_reset(statement);
            sqlite3_close(database);
            return YES;
        }
        else {
            sqlite3_reset(statement);
            sqlite3_close(database);
            return NO;
        }
    }
    return NO;

}

-(NSMutableArray*) getUserLocations {
    NSMutableArray* result = [[NSMutableArray alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select userLocationLatitude, userLocationLongitude, updateDate from userLocationsTable where rowid < 30 order by id desc"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSNumber *lat = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement, 0)];
                NSNumber *lng = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement, 1)];
                NSString *dateString = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSDate* date = [dateFormatter dateFromString:dateString];
                MapPin* pin = [[MapPin alloc] init];
                pin.coordinate = coord;
                pin.date = date;
                [result addObject:pin];
            }
            sqlite3_reset(statement);
        }
        sqlite3_close(database);
    }
    return result;
}

-(MapPin*) getLastUserLocation {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select userLocationLatitude, userLocationLongitude, updateDate from userLocationsTable where rownum < 2 order by id desc"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSNumber *lat = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement, 0)];
                NSNumber *lng = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement, 1)];
                NSString *dateString = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSDate* date = [dateFormatter dateFromString:dateString];
                MapPin* pin = [[MapPin alloc] init];
                pin.coordinate = coord;
                pin.date = date;
                sqlite3_reset(statement);
                sqlite3_close(database);
                return pin;
            } else {
                sqlite3_reset(statement);
                sqlite3_close(database);
                NSLog(@"No Locations Found!");
                return nil;
            }
        }
    }
    return nil;
}

-(BOOL) createNewRoute:(Route*) route {
    int index = 0;
    for (id object in [route getRoutePoints]) {
        if ([object isMemberOfClass:[MapPin class]]) {
            MapPin *pin = object;
            [self addRoutePointForRouteName:[route getRouteName] withIndex:index andCoordinates:[pin coordinate]];
            index++;
        }
    }
    return YES;
}

-(BOOL) addRoutePointForRouteName:(NSString*) name withIndex:(int) index andCoordinates:(CLLocationCoordinate2D) location {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into routePointsTable values (\"%@\", \"%d\", \"%f\",\"%f\")", name, index, location.latitude, location.longitude];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        int i = sqlite3_step(statement);
        if (i== SQLITE_DONE)
        {
            NSLog(@"ok");
            NSLog(@"%@", [NSString stringWithCString:insert_stmt encoding:NSASCIIStringEncoding]);
            sqlite3_reset(statement);
            sqlite3_close(database);
            return YES;
        }
        else {
            NSLog(@"no ok");
            NSLog(@"%@", [NSString stringWithCString:insert_stmt encoding:NSASCIIStringEncoding]);
            sqlite3_reset(statement);
            sqlite3_close(database);
            return NO;
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return NO;
}


-(Route*) getRouteWithName:(NSString*) name {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select locationLatitude, locationLongitude, routeIndex from routePointsTable where routeName like \"%@\" order by routeIndex asc", name];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSNumber *lat = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement, 0)];
                NSNumber *lng = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement, 1)];
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
                MapPin* pin = [[MapPin alloc] init];
                pin.coordinate = coord;
                [points addObject:pin];
            }
            sqlite3_reset(statement);
            sqlite3_close(database);
            return [[Route alloc] initWithRouteName:name andRoutePoints:points];
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return nil;
}

-(NSMutableArray*) getAllRoutesNames {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select distinct(routeName) from routePointsTable"];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *result = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                [result addObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]];
            }
            sqlite3_reset(statement);
            sqlite3_close(database);
            return result;
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return nil;
}

-(BOOL) deleteRouteWithName:(NSString*) name {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        NSString *querySQL = [NSString stringWithFormat:@"delete from routePointsTable where routeName=\"%@\"", name];
        const char *sql_stmt = [querySQL UTF8String];
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)!= SQLITE_OK)
        {
            NSLog(@"Failed to delete route, %s", errMsg);
            sqlite3_close(database);
            return NO;
        }
        else {
            sqlite3_close(database);
            return YES;
        }
    }
    sqlite3_close(database);
    return NO;
}

-(void) forceCloseDatabase {
    sqlite3_close(database);
};

@end
