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

#import "PWServiceDiscoveryEntity.h"
#import "SLServer.h"

@implementation PWServiceDiscoveryEntity

- (id) initWithIp:(NSString *)aIp {
	self = [super init];
	if (self != nil) {
		_port = -1;
		self.ip = aIp;
	}
	return self;
}

 - (void) dealloc
{
	 [_hostname release];
	 [_ip release];
	 [super dealloc];
}

- (void) setHostname:(NSString *)aHostname {
	[_hostname release];
	_hostname = [aHostname retain];
}
- (NSString *) hostname {
	return [[_hostname retain] autorelease];
}

- (void) setIp:(NSString *)aIp {
	[_ip release];
	_ip = [aIp retain];
}
- (NSString *) ip {
	return [[_ip retain] autorelease];
}

- (void) setPort:(int)aPort {
	_port = aPort;
}

- (int) port {
	return _port;
}

- (BOOL) valid {
	if (_hostname != nil && _port != -1 && _ip != nil)
		return YES;
	return NO;
}

- (SLServer *) server {
	SLServer *server = [[[SLServer alloc] init] autorelease];
	[server setPort:_port];
	[server setServer:_hostname];
	
	return server;
}

@end
