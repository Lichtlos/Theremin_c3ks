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

#import "PWServiceDiscoveryReply.h"


@implementation PWServiceDiscoveryReply
+ (PWServiceDiscoveryReplyMode) modeForReply:(NSData *)aReply {
	NSRange identifierRange;
	uint8_t identifier;
	
	identifierRange.location = 0;
	identifierRange.length = sizeof(identifier);

	NSRange modeRange;
	NSString *mode;
	
	modeRange.location = 1;
	modeRange.length = sizeof(mode);
	
	@try {
		[aReply getBytes:&identifier range:identifierRange];
		
		mode = [NSString stringWithCString:[[aReply subdataWithRange:modeRange] bytes] length:modeRange.length];
	}
	@catch (NSException * e) {
		return PWServiceDiscoveryModeUnknown;
	}
	
	if (identifier != 'E')
		return PWServiceDiscoveryModeUnknown;
	
	if ([mode isEqualToString:@"NAME"])
		return PWServiceDiscoveryModeReplyName;
	else if ([mode isEqualToString:@"CLIP"])
		return PWServiceDiscoveryModeReplyCliPort;
	return PWServiceDiscoveryModeUnknown;
}

+ (NSString *) stringForTLVReply:(NSData *)aReply {
	NSRange lengthRange;
	
	uint8_t length;
	lengthRange.location = 5;
	lengthRange.length = 1;
	
	@try {
		[aReply getBytes:&length range:lengthRange];
	}
	@catch (NSException * e) {
		return nil;
	}

	NSRange nameRange;
	
	nameRange.location = 6;
	nameRange.length = length;

	NSData *string;
	
	@try {
		string = [aReply subdataWithRange:nameRange];
	}
	@catch (NSException *e) {
		return nil;
	}
	
	if (string == nil)
		return nil;
	
	return [NSString stringWithCString:[string bytes] length:length];
}

+ (int) portForPortReply:(NSData *)aReply {
	return [[self stringForTLVReply:aReply] intValue];
}

+ (NSString *) addressForNameReply:(NSData *)aReply {
	return [self stringForTLVReply:aReply];	
}
@end
