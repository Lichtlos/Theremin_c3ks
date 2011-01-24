/*
 Copyright (C) 2008  Patrik Weiskircher
 
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
#import "SLCLIVolumeRequest.h"

@interface SLCLIVolumeRequest (PrivateMethods)
- (NSString *) _command;
@end

@implementation SLCLIVolumeRequest
+ (id) volumeGetRequestForPlayer:(SLPlayer *)aPlayer {
	return [[[SLCLIVolumeRequest alloc] initWithPlayer:aPlayer andMode:eCLIRequestModeGet andVolume:0] autorelease];
}

+ (id) volumeSetRequestForPlayer:(SLPlayer *)aPlayer andVolume:(int)aVolume {
	return [[[SLCLIVolumeRequest alloc] initWithPlayer:aPlayer andMode:eCLIRequestModeSet andVolume:aVolume] autorelease];
}

- (id) initWithPlayer:(SLPlayer *)aPlayer andMode:(SLCLIRequestMode)aMode andVolume:(int)aVolume {
	self = [super initWithPlayer:aPlayer andCommand:@""];
	if (self != nil) {
		_mode = aMode;
		_volume = aVolume;
		
		[self setPlayerCommand:[self _command]];
	}
	return self;
}

- (NSString *) _command {
	NSMutableString *cmd = [NSMutableString stringWithString:@"mixer volume"];
	
	switch (_mode) {
		case eCLIRequestModeGet:
			[cmd appendString:@" ?"];
			break;
		case eCLIRequestModeSet:
			[cmd appendFormat:@" %d", _volume];
			break;
	}
	
	return cmd;
}

- (id) cloneRequest {
	return [[[SLCLIVolumeRequest alloc] initWithPlayer:[self player] andMode:_mode andVolume:_volume] autorelease];
}

- (SLCLIRequestFinishedAction) finishedWithResponse:(NSString *)response {
	[super finishedWithResponse:response];
	
	if (_mode != eCLIRequestModeGet)
		return eFinished;
	
	NSArray *splittedResponse = [self splittedAndUnescapedResponse];
	if ([splittedResponse count] < 4) [NSException raise:NSInternalInconsistencyException format:@"Volume response is too short."];
	
	_result = [[splittedResponse objectAtIndex:3] intValue];
	return eFinished;
}

- (int) fetchedVolume {
	return _result;
}
@end
