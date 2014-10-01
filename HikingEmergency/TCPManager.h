#import <Foundation/Foundation.h>
#import "DBManager.h"
#import "Event.h"
/**
 Singleton obsługujący połączenie TCP z serwerem
 */
@interface TCPManager : NSObject <NSStreamDelegate> 

+(TCPManager*)getSharedInstance;

//rozpoczęcie komunikacji, nawiązanie połączenia
- (void)startNetworkCommunication;

//wysłanie pakietu z podaną zawartością
- (void)sendPacketWithMessage: (NSString*) msg;

//metoda obsługująca zdarzenia generowane przez strumień
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent;

//wysłanie powitania na serwer
-(void) sendHello;

@end
