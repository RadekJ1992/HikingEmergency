#import "TCPManager.h"

@implementation TCPManager

static TCPManager *sharedInstance = nil;
static NSInputStream *inputStream;
static NSOutputStream *outputStream;
static bool isConnected;
static NSMutableArray *receivedMessages;
static NSString *phoneNumber;

+(TCPManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [super allocWithZone:NULL];
        [sharedInstance startNetworkCommunication];
    }
    return sharedInstance;
}

-(void)startNetworkCommunication {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    //wczytanie ustawień z SettingsBundle
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString * ip = [standardUserDefaults objectForKey:@"serverIP"];
    NSString * port = [standardUserDefaults objectForKey:@"serverPort"];
    
    //utworzenie Socketa
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) ip, [port intValue], &readStream, &writeStream);
    
    //konwersja CFStreamów do NSStreamów używanych w obj-C
    inputStream = (__bridge_transfer NSInputStream *)readStream;
    outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    [inputStream setDelegate:sharedInstance];
    [outputStream setDelegate:sharedInstance];
    
    //uruchomienie pętli obsługujacych strumienie
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
    [sharedInstance sendHello];
    
    isConnected = true;
    
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    switch (streamEvent) {
            
        case NSStreamEventNone:
            NSLog(@"Stream None Event");
            break;
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
        //zdarzenie informujące o przyjściu danych
		case NSStreamEventHasBytesAvailable:
			if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = (int) [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        //wygram konkurs na najbardziej nieczytelny kod!
                        
                        if (nil != output) {
                            NSLog(@"%@", output);
                            
                            // podzielenie tekstu który przyszedł na tablicę NSStringów względem znaku '|'
                            NSArray* splitArray = [output componentsSeparatedByString:@"|"];
                            
                            if ([splitArray[0] isEqual: @"stub"]) {
                            }
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Stream Has Space Available Event");
            break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
            NSLog(@"Stream End Encountered Event");
			break;
            
		default:
			NSLog(@"Unknown event");
	}
}

- (void)sendPacketWithMessage: (NSString*) msg {
	NSData *data = [[NSData alloc] initWithData:[msg dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}

-(void) sendHello {
    [sharedInstance sendPacketWithMessage: [NSString stringWithFormat: @"HELLO"]];
}

@end
