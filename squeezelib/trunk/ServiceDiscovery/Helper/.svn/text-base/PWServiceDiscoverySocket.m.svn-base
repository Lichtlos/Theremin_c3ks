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

#import "PWServiceDiscoverySocket.h"
#include <sys/types.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <arpa/inet.h>
#include <unistd.h>

#import "PWServiceRequests.h"

const short squeezeServerUDPPort = 3483;

@interface PWServiceDiscoverySocket (PrivateMethods)
- (void) setupPort:(int)aPort onSockAddr:(struct sockaddr *)aSockAddr;
- (void) cleanupSockets;
- (void) receivedReply:(NSData *)aReply fromAddress:(NSData *)aSockAddr;
- (NSString *) ipFromSockAddr:(NSData *)aSockAddr;
@end

void ServiceDiscoveryReadCallback (CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
	PWServiceDiscoverySocket *socket = (PWServiceDiscoverySocket *)info;	
	[socket receivedReply:((NSData *)data) fromAddress:((NSData *)address)];
}

@implementation PWServiceDiscoverySocket
+ (NSArray *) serviceDiscoverySocketsWithDelegate:(id)aDelegate {
	struct ifaddrs *interfaceAddresses;
	struct ifaddrs *originalInterfaceAddresses;
	
	int status = getifaddrs(&originalInterfaceAddresses);
	if (status != 0) {
		NSLog(@"Couldn't get interface addresses: %s\n", strerror(errno));
		return nil;
	}
	
	interfaceAddresses = originalInterfaceAddresses;
	
	NSMutableArray *serviceDiscoverySockets = [NSMutableArray array];
	for (; interfaceAddresses->ifa_next != NULL; interfaceAddresses = interfaceAddresses->ifa_next) {
		if (interfaceAddresses->ifa_flags & IFF_BROADCAST && 
			(interfaceAddresses->ifa_addr->sa_family == AF_INET || interfaceAddresses->ifa_addr->sa_family == AF_INET6)) {
			[serviceDiscoverySockets addObject:[[[PWServiceDiscoverySocket alloc] initWithBroadcastAddress:interfaceAddresses->ifa_dstaddr andInterfaceAddress:interfaceAddresses->ifa_addr andDelegate:aDelegate] autorelease]];
		}
	}
	freeifaddrs(originalInterfaceAddresses);
	
	return serviceDiscoverySockets;
}

- (id) initWithBroadcastAddress:(struct sockaddr *)aSockAddr andInterfaceAddress:(struct sockaddr*)aInterfaceAddress andDelegate:(PWServiceDiscovery *)aDelegate {
	self = [super init];
	if (self != nil) {
		NSAssert(aInterfaceAddress->sa_family == aSockAddr->sa_family, @"Broadcast and Interface address are different families.");
		
		if (aSockAddr->sa_family == AF_INET)
			_sockAddrLen = sizeof(struct sockaddr_in);
		else if (aSockAddr->sa_family == AF_INET6)
			_sockAddrLen = sizeof(struct sockaddr_in6);
		else
			[NSException raise:NSInternalInconsistencyException format:@"Invalid sockaddr supplied. Must be family AF_INET or AF_INET6."];
		
		_broadcastAddress = malloc(_sockAddrLen);
		memcpy(_broadcastAddress, aSockAddr, _sockAddrLen);
		
		_interfaceAddress = malloc(_sockAddrLen);
		memcpy(_interfaceAddress, aInterfaceAddress, _sockAddrLen);
		
		_delegate = aDelegate;
		
		_cfSocket = NULL;
		_cfRunLoopSourceRef = NULL;
	}
	return self;
}

- (void) dealloc
{
	[self cleanupSockets];
	free(_broadcastAddress);
	free(_interfaceAddress);
	[super dealloc];
}

- (BOOL) sendDiscoveryRequestAndListenForReply {
	[self setupPort:squeezeServerUDPPort onSockAddr:_broadcastAddress];
	[self setupPort:0 onSockAddr:_interfaceAddress];
	
	int udpSocket = socket(_broadcastAddress->sa_family, SOCK_DGRAM, IPPROTO_UDP);
	if (udpSocket == -1) {
		NSLog(@"Error on creating socket: %s", strerror(errno));
		return NO;
	}
	
	int enable = 1;
	if (setsockopt(udpSocket, SOL_SOCKET, SO_BROADCAST, &enable, sizeof(enable)) != 0) {
		NSLog(@"Error on setting SO_BROADCAST: %s", strerror(errno));
		close(udpSocket);
		return NO;
	}
	
	if (bind(udpSocket, _interfaceAddress, _sockAddrLen) != 0) {
		NSLog(@"Error on binding socket: %s", strerror(errno));
		close(udpSocket);
		return NO;
	}
	
	CFSocketContext context = { 0, self, NULL, NULL, NULL };
	_cfSocket = CFSocketCreateWithNative(NULL, udpSocket,  kCFSocketDataCallBack, ServiceDiscoveryReadCallback, &context);
	if (_cfSocket == NULL) {
		NSLog(@"Error on CFSocketCreateWithNative.");
		[self cleanupSockets];
		return NO;
	}
	
	_cfRunLoopSourceRef = CFSocketCreateRunLoopSource(NULL, _cfSocket, 0);
	if (_cfRunLoopSourceRef == NULL) {
		NSLog(@"Error on CFSocketCreateRunLoopSource.");
		[self cleanupSockets];
		return NO;
	}
	
	CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop], _cfRunLoopSourceRef, kCFRunLoopDefaultMode);
	
	NSData *discoveryRequest = [PWServiceRequests nameRequest];
	sendto(udpSocket, [discoveryRequest bytes], [discoveryRequest length], 0, _broadcastAddress, _sockAddrLen);
	
	discoveryRequest = [PWServiceRequests cliPortRequest];
	sendto(udpSocket, [discoveryRequest bytes], [discoveryRequest length], 0, _broadcastAddress, _sockAddrLen);
	
	return YES;
}

- (void) stopListening {
	[self cleanupSockets];
}

@end

@implementation PWServiceDiscoverySocket (PrivateMethods)
- (void) setupPort:(int)aPort onSockAddr:(struct sockaddr *)aSockAddr {
	if (aSockAddr->sa_family == AF_INET) {
		((struct sockaddr_in *)aSockAddr)->sin_port = htons(aPort);
	} else if (_broadcastAddress->sa_family == AF_INET6) {
		((struct sockaddr_in6 *)aSockAddr)->sin6_port = htons(aPort);
	} else {
		[NSException raise:NSInternalInconsistencyException format:@"Wrong sa_family in _sockAddr."];
	}
}

- (void) cleanupSockets {
	if (_cfRunLoopSourceRef != NULL) {
		CFRunLoopRemoveSource([[NSRunLoop currentRunLoop] getCFRunLoop], _cfRunLoopSourceRef, kCFRunLoopDefaultMode);
		CFRelease(_cfRunLoopSourceRef);
		_cfRunLoopSourceRef = NULL;
	}
	
	if (_cfSocket != NULL) {
		CFRelease(_cfSocket);
		_cfSocket = NULL;
	}	
}

- (NSString *) ipFromSockAddr:(NSData *)aSockAddr {
	char buffer[256];
	if (_interfaceAddress->sa_family == AF_INET) {
		struct sockaddr_in *sa_in = (struct sockaddr_in *)[aSockAddr bytes];
		return [NSString stringWithCString:inet_ntop(AF_INET, (void *)&sa_in->sin_addr, buffer, sizeof(buffer))];
	} else if (_interfaceAddress->sa_family == AF_INET6) {
		struct sockaddr_in6 *sa_in6 = (struct sockaddr_in6 *)[aSockAddr bytes];
		return [NSString stringWithCString:inet_ntop(AF_INET6, (void *)&sa_in6->sin6_addr, buffer, sizeof(buffer))];
	}
	[NSException raise:NSInternalInconsistencyException format:@"Wrong sa_family in _sockAddr."];
	return nil;
}

- (void) receivedReply:(NSData *)aReply fromAddress:(NSData *)aSockAddr {
	[_delegate serviceDiscoverySocket:self receivedReply:aReply fromIp:[self ipFromSockAddr:aSockAddr]];
}

@end