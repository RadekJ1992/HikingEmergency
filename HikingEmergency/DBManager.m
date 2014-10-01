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
                    [docsDir stringByAppendingPathComponent: @"letsMeet.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
            //utworzenie tabeli przechowującej lokalizację użytkownika
            char *errMsg;
            const char *sql_stmt_usrloc =
            "create table if not exists userLocationsTable (id integer primary key autoincrement, userLocationLatitude real, userLocationLongitude real, updateDate text";
            if (sqlite3_exec(database, sql_stmt_usrloc, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create events table, %s", errMsg);
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
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
        NSString *insertSQL = [NSString stringWithFormat:@"insert into userLocationsTable values (%f,%f,\"%@\"", coordinates.latitude, coordinates.longitude, dateString];
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
        NSString *querySQL = [NSString stringWithFormat: @"select userLocationLatitude, userLocationLongitude, updateDate from userLocationsTable order by id desc"];
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


-(void) forceCloseDatabase {
    sqlite3_close(database);
};

@end
