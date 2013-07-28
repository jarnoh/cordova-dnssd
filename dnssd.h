/*
 * Bonjour DNS-SD plugin for Cordova.
 * Allows browsing and resolving of local ad-hoc services
 *
 * jarnoh@komplex.org - March 2012
 *
 */

#import <Foundation/Foundation.h>
#import <Foundation/NSNetServices.h>

#import <Cordova/CDVPlugin.h>

@interface CDVBonjour : CDVPlugin <NSNetServiceBrowserDelegate, NSNetServiceDelegate> 
{
    NSString* browseCallback;
    NSString* resolveCallback;

    NSNetServiceBrowser* netServiceBrowser;
    NSNetService* currentResolve;

}

@property (nonatomic, copy) NSString* browseCallback;
@property (nonatomic, copy) NSString* resolveCallback;

@property (nonatomic, retain, readwrite) NSNetServiceBrowser* netServiceBrowser;
@property (nonatomic, retain, readwrite) NSNetService* currentResolve;


- (void)browse:(CDVInvokedUrlCommand*)command;
- (void)resolve:(CDVInvokedUrlCommand*)command;


@end
