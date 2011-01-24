/*
 Copyright (C) 2009  Patrik Weiskircher
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, 
 MA 02110-1301, USA.
 */

#if !defined(TARGET_OS_IPHONE) || !TARGET_OS_IPHONE 
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#endif

@class PWServiceDiscovery, SLServer;

@protocol PWServiceDiscoveryDelegateProtocol
- (void) serviceDiscovery:(PWServiceDiscovery *)aServiceDiscovery discoveredSqueezeServer:(SLServer *)aServer;
- (void) serviceDiscoveryFinished:(PWServiceDiscovery *)aServiceDiscovery;
- (void) serviceDiscovery:(PWServiceDiscovery *)aServiceDiscovery timeouted:(BOOL *)retry; 
- (void) serviceDiscovery:(PWServiceDiscovery *)aServiceDiscovery encounteredUnrecoverableError:(NSString *)error;
@end

@interface PWServiceDiscovery : NSObject {
	id _delegate;
	NSTimeInterval _timeout;
	NSTimer *_discoveryTimer;
	NSTimer *_startTimer;
	
	BOOL _receivedReplies;
	NSMutableDictionary *_tmpReceivedServer;
	
	NSArray *_sockets;
}
- (id) initWithDelegate:(id)aDelegate andTimeout:(NSTimeInterval)aTimeout;

- (void) setDelegate:(id)aDelegate;
- (id) delegate;

- (void) setTimeout:(NSTimeInterval)aTimeout;
- (NSTimeInterval) timeout;

- (void) startDiscoveryWithDelay:(NSTimeInterval)aDelay;
- (void) startDiscovery;
- (void) stopDiscovery;
- (BOOL) isDiscovering;
@end