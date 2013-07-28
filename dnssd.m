/*
 * Bonjour DNS-SD plugin for Cordova.
 * Allows browsing and resolving of local ad-hoc services
 *
 * jarnoh@komplex.org - March 2012
 *
 */

#import "dnssd.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation CDVBonjour

@synthesize browseCallback;
@synthesize resolveCallback;

@synthesize netServiceBrowser;
@synthesize currentResolve;


#if !defined(__has_feature) || !__has_feature(objc_arc)
#error This plugin requires ARC
#endif

//- (void)browse:(NSArray*)arguments withDict:(NSDictionary*)options
- (void)browse:(CDVInvokedUrlCommand*)command
{
    [self.netServiceBrowser stop];
//    [self.netServiceBrowser release];
    self.netServiceBrowser=nil;
    
    NSUInteger argc = [command.arguments count];
    NSLog(@"browse argc %d", (int)argc);
    
	if (argc < 2) {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus: CDVCommandStatus_OK
                                   ];
        [result setKeepCallbackAsBool:NO];
        [self.commandDelegate sendPluginResult:result callbackId:self.browseCallback];
        self.browseCallback=nil;
		return;
	}
    
    self.browseCallback = command.callbackId;
    NSString *regType = [command.arguments objectAtIndex:0];
    NSString *domain = [command.arguments objectAtIndex:1];
    self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    self.netServiceBrowser.delegate = self;
    
    [self.netServiceBrowser searchForServicesOfType:regType inDomain:domain];
}

- (void)resolve:(CDVInvokedUrlCommand*)command
{
    [self.currentResolve stop];
//    [self.currentResolve release];
    self.currentResolve = nil;
    
    NSUInteger argc = [command.arguments count];
    NSLog(@"resolve argc %d", (int)argc);
    
	if (argc < 3) {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus: CDVCommandStatus_OK
                                   ];
        [result setKeepCallbackAsBool:NO];
        [self.commandDelegate sendPluginResult:result callbackId:self.resolveCallback];
        self.resolveCallback=nil;
		return;
	}
    
    self.resolveCallback = command.callbackId;
    NSString *serviceName = [command.arguments objectAtIndex:0];
    NSString *regType = [command.arguments objectAtIndex:1];
    NSString *domain = [command.arguments objectAtIndex:2];
    
    self.currentResolve = [[NSNetService alloc] initWithDomain:domain type:regType name:serviceName];
    
    NSLog(@"currentResolve %@", self.currentResolve);
    [self.currentResolve setDelegate:self];
    [self.currentResolve resolveWithTimeout:0.0];
}

// 

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing {
    NSLog(@"didRemoveService");
    
    NSMutableDictionary* resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setObject:[NSNumber numberWithBool:TRUE] forKey:@"serviceLost"];
    [resultDict setObject:service.name forKey:@"serviceName"];
    [resultDict setObject:service.type forKey:@"regType"];
    [resultDict setObject:service.domain forKey:@"domain"];
    [resultDict setObject:[NSNumber numberWithBool:moreComing] forKey:@"moreComing"];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsDictionary: resultDict
                               ];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:self.browseCallback];
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing {
    NSLog(@"didFindService name %@", service.name);
    
    NSMutableDictionary* resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setObject:[NSNumber numberWithBool:TRUE] forKey:@"serviceFound"];
    [resultDict setObject:service.name forKey:@"serviceName"];
    [resultDict setObject:service.type forKey:@"regType"];
    [resultDict setObject:service.domain forKey:@"domain"];
    [resultDict setObject:[NSNumber numberWithBool:moreComing] forKey:@"moreComing"];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsDictionary: resultDict
                               ];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:self.browseCallback];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"didNotResolve");
    // TODO not used (timeout 0)
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    NSLog(@"netServiceDidResolveAddress");
    
    
    NSMutableDictionary* resultDict = [[NSMutableDictionary alloc] init];
    
    // FIXME ugly hack to pass IP addresses to javascript, the application server does not support ipv6,
    // and my server is resolving names as ipv6 addresses.
    for (NSData* data in [service addresses]) {
        struct sockaddr_in* socketAddress = (struct sockaddr_in*) [data bytes];
        int sockFamily = socketAddress->sin_family;
        
        if (sockFamily == AF_INET) {
            char buf[100];
            const char* addressStr = inet_ntop(sockFamily, &(socketAddress->sin_addr), buf, sizeof(buf));
            NSString *address = [NSString stringWithUTF8String:addressStr];
            [resultDict setObject:address forKey:@"address"];
        }
        if (sockFamily == AF_INET6) {
            char buf[100];
            const char* addressStr = inet_ntop(sockFamily, &(socketAddress->sin_addr), buf, sizeof(buf));
            NSString *address = [NSString stringWithUTF8String:addressStr];
            [resultDict setObject:address forKey:@"address6"];
        }
    }
    
    [resultDict setObject:[NSNumber numberWithBool:TRUE] forKey:@"serviceResolved"];
    [resultDict setObject:service.hostName forKey:@"hostName"];
    [resultDict setObject:[NSNumber numberWithInteger:service.port] forKey:@"port"];
    [resultDict setObject:service.name forKey:@"serviceName"];
    [resultDict setObject:service.type forKey:@"regType"];
    [resultDict setObject:service.domain forKey:@"domain"];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsDictionary: resultDict];
    [result setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:result callbackId:self.resolveCallback];
    
    [self.currentResolve stop];
//    [self.currentResolve release];
    self.currentResolve = nil;
    
}

@end
