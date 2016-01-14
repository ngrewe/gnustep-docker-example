/* main.m: Entry point for the example server
 *
 * Copyright (C) 2016 Niels Grewe
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

#include <signal.h>
#include <unistd.h>
#include <stdio.h>

#import "Handler.h"

/*
 * We use a static variable that we can set from the signal handler. It is
 * volatile to prevent the compiler from optimising it from out of loops etc.
 */
static volatile sig_atomic_t _sigterm_recv = 0;

/**
 * Signal handler for SIGTERM
 */
static void _on_sigterm(int signum)
{
	_sigterm_recv = 1;
}

int main (int argc, char *argv[])
{
	/*
	 * First thing to do is to set up the exit handler.
	 */
  struct sigaction termAction;
  memset(&termAction, 0, sizeof(struct sigaction));
  termAction.sa_handler = _on_sigterm;
  sigaction(SIGTERM, &termAction, NULL);

  @autoreleasepool
  {
		/*
		 * Now we set up the handler, which sets up the web server for us.
		 */
		Handler *handler = [Handler new];
		if (handler == nil)
		{
			GSPrintf(stderr, @"Could not create web-server\n");
			return 2;
		}
		/*
		 * And run the runloop until done.
		 */
		NSDate *d = nil;
		NSDate *quittingSince = [NSDate distantFuture];
		NSRunLoop *rl = [NSRunLoop currentRunLoop];
		/*
		 * done will be set internally on unrecoverable errors or after explicit
		 * shutdown was successful.
		 */
		while (![handler isDone])
		{
			d = [NSDate dateWithTimeIntervalSinceNow: 0.01f];
			[rl runUntilDate: d];
			if ((_sigterm_recv > 0) && ![handler isQuitting])
			{
				/* We have received SIGTERM, and should quit now */
				[handler quit];
				GSPrintf(stdout, @"Shutting down server.\n");
				quittingSince = [NSDate date];
			}
			if ([handler isQuitting] && [quittingSince timeIntervalSinceNow] < -30.0f)
			  {
					// If shutting down existing connections took more than 30 seconds,
					// force things.
					break;
				}
		}

		/*
		 * Report any error conditions the server had.
		 */
		NSError *error = [handler error];
		if (error != nil)
		{
			NSString *desc =
			  [[error userInfo] objectForKey: NSLocalizedDescriptionKey];
			if (desc == nil)
			{
				desc = [NSString stringWithFormat: @"%@(%"PRIdPTR")",
				  [error domain], [error code]];
			}
			GSPrintf(stderr, @"Error running webserver: %@\n", desc);
			return [error code];
		}
  }
	/* Or exit gracefully */
  return 0;
}
