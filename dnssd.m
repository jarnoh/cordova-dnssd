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


- (void)browse:(NSArray*)arguments withDict:(NSDictionary*)options
{
    [self.netServiceBrowser stop];
    [self.netServiceBrowser release];
    self.netServiceBrowser=nil;
    
    NSUInteger argc = [arguments count];
    NSLog(@"browse argc %d", argc);
    
	if (argc < 2) {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus: CDVCommandStatus_OK
                                   ];
        NSString* js = [result toSuccessCallbackString:self.browseCallback];
        [self writeJavascript:js];    
		return;	
	}
    
    self.browseCallback = [arguments objectAtIndex:0];
    NSString *regType = [arguments objectAtIndex:1];
    NSString *domain = [arguments objectAtIndex:2];
    self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    self.netServiceBrowser.delegate = self;
    
    [self.netServiceBrowser searchForServicesOfType:regType inDomain:domain];
}

- (void)resolve:(NSArray*)arguments withDict:(NSDictionary*)options
{
    [self.currentResolve stop];
    [self.currentResolve release];
    self.currentResolve = nil;
    
    NSUInteger argc = [arguments count];
    NSLog(@"resolve argc %d", argc);
    
	if (argc < 4) {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus: CDVCommandStatus_OK
                                   ];
        NSString* js = [result toSuccessCallbackString:self.resolveCallback];
        [self writeJavascript:js];    
        
		return;	
	}
    
    self.resolveCallback = [arguments objectAtIndex:0];
    NSString *serviceName = [arguments objectAtIndex:1];
    NSString *regType = [arguments objectAtIndex:2];
    NSString *domain = [arguments objectAtIndex:3];
    
    self.currentResolve = [[NSNetService alloc] initWithDomain:domain type:regType name:serviceName];    
    [self.currentResolve setDelegate:self];
    [self.currentResolve resolveWithTimeout:0.0];
}

// 

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing {
    NSLog(@"didRemoveService");
    
    NSMutableDictionary* resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    [resultDict setObject:[NSNumber numberWithBool:TRUE] forKey:@"serviceLost"];
    [resultDict setObject:service.name forKey:@"serviceName"];
    [resultDict setObject:service.type forKey:@"regType"];
    [resultDict setObject:service.domain forKey:@"domain"];
    [resultDict setObject:[NSNumber numberWithBool:moreComing] forKey:@"moreComing"];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsDictionary: resultDict
                               ];
    [result setKeepCallbackAsBool:TRUE];
    NSString* js = [result toSuccessCallbackString:self.browseCallback];
    [self writeJavascript:js];    
    
    //    [self.services removeObject:service];
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing {
    NSLog(@"didFindService name %@", service.name);
    
    NSMutableDictionary* resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    [resultDict setObject:[NSNumber numberWithBool:TRUE] forKey:@"serviceFound"];
    [resultDict setObject:service.name forKey:@"serviceName"];
    [resultDict setObject:service.type forKey:@"regType"];
    [resultDict setObject:service.domain forKey:@"domain"];
    [resultDict setObject:[NSNumber numberWithBool:moreComing] forKey:@"moreComing"];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsDictionary: resultDict
                               ];
    [result setKeepCallbackAsBool:TRUE];
    NSString* js = [result toSuccessCallbackString:self.browseCallback];
    [self writeJavascript:js];    
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"didNotResolve");
    // TODO not used (timeout 0)
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    NSLog(@"netServiceDidResolveAddress");
    
    
    NSMutableDictionary* resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    
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
    NSString* js = [result toSuccessCallbackString:self.resolveCallback];
    [self writeJavascript:js];    
    
    [self.currentResolve stop];
    [self.currentResolve release];
    self.currentResolve = nil;
    
}

@end
