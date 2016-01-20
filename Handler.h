/* Handler.h: External interface for the example webserver
 *
 * Copyright (C) 2016 Niels Grewe
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

#import <Foundation/Foundation.h>
@class WebServer;
@interface Handler : NSObject
@property (nonatomic,readonly,getter=isQuitting) BOOL quitting;
@property (nonatomic,readonly,getter=isDone) BOOL done;
@property (nonatomic,readonly) NSError *error;
/**
 * Go into shutdown, closing currently active connections.
 */
- (void)quit;

/**
 * Logging method.
 */
- (void)webLog: (NSString*)msg for: (WebServer*)server;
@end
