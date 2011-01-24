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

@class PWServiceDiscovery;

#include <sys/socket.h>

@class PWServiceDiscoverySocket;

@protocol PWServiceDiscoveryProtocol
- (void) serviceDiscoverySocket:(PWServiceDiscoverySocket *)aSocket receivedReply:(NSData *)aReply fromIp:(NSString *)aIp;
@end

@interface PWServiceDiscoverySocket : NSObject {
	struct sockaddr *_broadcastAddress;
	struct sockaddr *_interfaceAddress;
	
	socklen_t _sockAddrLen;
	PWServiceDiscovery *_delegate;
	
	CFSocketRef _cfSocket;
	CFRunLoopSourceRef _cfRunLoopSourceRef;
}
+ (NSArray *) serviceDiscoverySocketsWithDelegate:(id)aDelegate;

- (id) initWithBroadcastAddress:(struct sockaddr *)aSockAddr andInterfaceAddress:(struct sockaddr*)aInterfaceAddress andDelegate:(PWServiceDiscovery *)aDelegate;
- (BOOL) sendDiscoveryRequestAndListenForReply;
- (void) stopListening;
@end