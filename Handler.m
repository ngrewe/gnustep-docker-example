/* Handler.m: An example Objective-C web server
 *
 * Copyright (C) 2016 Niels Grewe
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */
#import "Handler.h"

#import <WebServer/WebServer.h>
#import <Foundation/NSLocale.h>

#include <dispatch/dispatch.h>

static NSString* kWSHandlerDomain = @"WebServerHandlerDomain";

static NSDateFormatter *_formatter;

#define STR_DATE(x) [_formatter stringFromDate: x]
#define STR_NOW STR_DATE([NSDate date])

@interface Handler (WebServerDelegate) <WebServerDelegate>
@end


@implementation Handler
{
  WebServer* server;
  BOOL _done;
}
@dynamic done;

+ (void)initialize
{
  if (self == [Handler class])
    {
      _formatter = [[NSDateFormatter alloc] init];
      NSLocale *posix =
        [[NSLocale alloc] initWithLocaleIdentifier: @"en_US_POSIX"];
      [_formatter setLocale: posix];
      [_formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    }
}

- (BOOL)isDone
{
  if (_done)
    {
      return YES;
    }
  if (_quitting)
    {
      if ([[server connections] count] > 0)
        {
          return NO;
        }
      _done = YES;
      _quitting = NO;
      return YES;
    }
  return _done;
}


- (void)_failWithErrorCode: (NSInteger)code
               description: (NSString*)desc
{
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
    desc, NSLocalizedDescriptionKey, nil];
  _error = [NSError errorWithDomain: kWSHandlerDomain
                               code: code
                           userInfo: dict];
  _done = YES;
}

- (id)init
{
  if (nil == (self = [super init]))
    {
	    return nil;
    }

  server = [WebServer new];
  /*
   * We read the configuration parameters from the user defaults, which include
   * command line parameters.
   */
  NSUserDefaults *dflts = [NSUserDefaults standardUserDefaults];
  NSString *port = [dflts stringForKey: @"Port"];
  if (([port integerValue] <= 0) || ([port integerValue] > 65535))
    {
      [self _failWithErrorCode: 3
                   description:
        [NSString stringWithFormat: @"Invalid port (%@)", port]];
      return self;
    }
  if (NO == [server setPort: port secure: nil])
    {
      [self _failWithErrorCode: 4
                   description:
        [NSString stringWithFormat: @"Could not listen on port %@", port]];
      return self;
    }
  [server setVerbose: [dflts boolForKey: @"Debug"]];
  [server setDelegate: self];
  return self;
}
- (void)quit
{
  /*
   * Removing the connection parameters causes the server to no longer accept
   * new connections.
   */
  [server setAddress: nil port: nil secure: nil];
  _quitting = YES;
  GSPrintf(stdout, @"Stopped listening. Will quit now\n");
}

- (BOOL) processRequest: (WebServerRequest*)request
	             response: (WebServerResponse*)response
		                for: (WebServer*)http
{
  /* This is the actual workhorse method. If we do all our processing here,
   * we can just return YES and effectively handle the request synchronously.
   * But that is terribly boring. So we put the processing onto a dispatch
   * queue and return NO to indicate that it's being done asynchronously.
   */
  dispatch_queue_t queue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    GSRegisterCurrentThread();
    NSString *method = [[request headerNamed: @"x-http-method"] value];
    if ([method caseInsensitiveCompare: @"GET"] == NSOrderedSame)
      {
        [response setContent: @"Hello world!"
                        type: @"text/plain"];
        [response setHeader: @"http"
                      value: @"HTTP/1.1 200 OK"
                 parameters: nil];

      }
    else
      {
        [response setContent: @"Method not allowed"
                        type: @"text/plain"];
        [response setHeader: @"http"
                      value: @"HTTP/1.0 405 Method Not Allowed"
                 parameters: nil];
      }
    // After we are done processing the request, hand it back to the server
    [http completedWithResponse: response];
    GSUnregisterCurrentThread();
  });
  /* Return value no indicates that we are processing asynchronously */
  return NO;
}

- (void) webAlert: (NSString*)message for: (WebServer*)http
{
  GSPrintf(stderr, @"%@: %@\n", STR_NOW, message);
}

- (void) webAudit: (NSString*)message for: (WebServer*)http
{
  GSPrintf(stdout, @"%@\n", message);
}

- (void) webLog: (NSString*)message for: (WebServer*)http
{
  GSPrintf(stdout, @"%@: %@\n", STR_NOW, message);
}
@end
