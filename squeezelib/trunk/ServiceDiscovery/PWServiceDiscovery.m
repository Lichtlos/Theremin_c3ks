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

#import "PWServiceDiscovery.h"
#import "PWServiceDiscoverySocket.h"
#import "PWServiceDiscoveryReply.h"
#import "PWServiceDiscoveryEntity.h"

@interface PWServiceDiscovery (PrivateMethods)
- (PWServiceDiscoveryEntity *) discoveryEntityForIp:(NSString *)aIp;
@end

@implementation PWServiceDiscovery
- (id) initWithDelegate:(id)aDelegate andTimeout:(NSTimeInterval)aTimeout {
	self = [super init];
	if (self != nil) {
		[self setDelegate:aDelegate];
		[self setTimeout:aTimeout];
	}
	return self;
}

- (void) dealloc
{
	[_discoveryTimer invalidate];
	[_discoveryTimer release];	
	
	[_startTimer invalidate];
	[_startTimer release];
	
	[_tmpReceivedServer release];
	
	[_sockets release];
	_delegate = nil;
	[super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	_delegate = aDelegate;
}

- (id) delegate {
	return _delegate;
}

- (void) setTimeout:(NSTimeInterval)aTimeout {
	_timeout = aTimeout;
}

- (NSTimeInterval) timeout {
	return _timeout;
}

- (void) startDiscoveryWithDelay:(NSTimeInterval)aDelay {
	_startTimer = [[NSTimer scheduledTimerWithTimeInterval:aDelay target:self selector:@selector(startDiscoveryTriggered:) userInfo:nil repeats:NO] retain];
}

- (void) startDiscoveryTriggered:(NSTimer *)aTimer {
	// startDiscovery takes care of the timer release.
	[self startDiscovery];
}

- (void) startDiscovery {
	[_startTimer invalidate];
	[_startTimer release];
	_startTimer = nil;
	
	[self stopDiscovery];
	
	@try {
		_tmpReceivedServer = [[NSMutableDictionary dictionary] retain];
		
		_sockets = [[PWServiceDiscoverySocket serviceDiscoverySocketsWithDelegate:self] retain];
		
		if ([_sockets count] == 0) {
			[_delegate serviceDiscovery:self encounteredUnrecoverableError:@"Couldn't initialize or send service discovery requests."];
			[self stopDiscovery];
			[_delegate serviceDiscoveryFinished:self];
			return;
		}
		
		for (int i = 0; i < [_sockets count]; i++) {
			PWServiceDiscoverySocket *socket = [_sockets objectAtIndex:i];
			[socket sendDiscoveryRequestAndListenForReply];
		}
		
		[_discoveryTimer release];
		_discoveryTimer = [[NSTimer scheduledTimerWithTimeInterval:_timeout 
															target:self
														  selector:@selector(discoveryTimeout:)
														  userInfo:nil repeats:NO] retain];
	}
	@catch (NSException * e) {
		[_delegate serviceDiscovery:self encounteredUnrecoverableError:@"Couldn't initialize or send service discovery requests."];
		[self stopDiscovery];
		[_delegate serviceDiscoveryFinished:self];
	}
}

- (void) stopDiscovery {
	[_discoveryTimer invalidate];
	[_discoveryTimer release];
	_discoveryTimer = nil;
	
	[_sockets release];
	_sockets = nil;
	_receivedReplies = NO;
	
	[_tmpReceivedServer release];
	_tmpReceivedServer = nil;
}

- (BOOL) isDiscovering {
	return [_sockets count] > 0 && _discoveryTimer != nil;
}

- (void) serviceDiscoverySocket:(PWServiceDiscoverySocket *)aSocket receivedReply:(NSData *)aReply fromIp:(NSString *)aIp {
	PWServiceDiscoveryEntity *entity = [self discoveryEntityForIp:aIp];
	
	switch ([PWServiceDiscoveryReply modeForReply:aReply]) {
		case PWServiceDiscoveryModeReplyName:
			[entity setHostname:[PWServiceDiscoveryReply addressForNameReply:aReply]];
			break;
			
		case PWServiceDiscoveryModeReplyCliPort:
			[entity setPort:[PWServiceDiscoveryReply portForPortReply:aReply]];
			break;
			
		case PWServiceDiscoveryModeUnknown:
			break;
	}
	
	if ([entity valid]) {
		_receivedReplies = YES;
		
		[_delegate serviceDiscovery:self discoveredSqueezeServer:[entity server]];
	}
}

@end

@implementation PWServiceDiscovery (PrivateMethods)
- (void) discoveryTimeout:(NSTimer *)aTimer {
	[_discoveryTimer release], _discoveryTimer = nil;
	
	if (_receivedReplies == NO) {
		BOOL retry = NO;
		[_delegate serviceDiscovery:self timeouted:&retry];
		
		if (retry == YES)
			[self startDiscovery];	
		else
			[_delegate serviceDiscoveryFinished:self];
	} else {
		[_delegate serviceDiscoveryFinished:self];
	}
}

- (PWServiceDiscoveryEntity *) discoveryEntityForIp:(NSString *)aIp {
	PWServiceDiscoveryEntity *entity = [_tmpReceivedServer objectForKey:aIp];
	if (entity == nil) {
		entity = [[[PWServiceDiscoveryEntity alloc] initWithIp:aIp] autorelease];
		[_tmpReceivedServer setObject:entity forKey:aIp];
	}
	return entity;
}

@end

