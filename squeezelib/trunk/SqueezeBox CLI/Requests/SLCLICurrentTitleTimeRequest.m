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
#import "SLCLICurrentTitleTimeRequest.h"

@interface SLCLICurrentTitleTimeRequest (PrivateMethods)
- (NSString *) _command;
@end

@implementation SLCLICurrentTitleTimeRequest

+ (id) timeGetRequestForPlayer:(SLPlayer *)aPlayer {
	return [[[SLCLICurrentTitleTimeRequest alloc] initWithPlayer:aPlayer andMode:eCLIRequestModeGet andTime:0] autorelease];
}

+ (id) timeSetRequestForPlayer:(SLPlayer *)aPlayer andTime:(int)aTime {
	return [[[SLCLICurrentTitleTimeRequest alloc] initWithPlayer:aPlayer andMode:eCLIRequestModeSet andTime:aTime] autorelease];
}

- (id) initWithPlayer:(SLPlayer *)aPlayer andMode:(SLCLIRequestMode)aMode andTime:(int)aTime  {
	self = [super initWithPlayer:aPlayer andCommand:@""];
	if (self != nil) {
		_mode = aMode;
		_time = aTime;
		
		[self setPlayerCommand:[self _command]];
	}
	return self;
}

- (NSString *) _command {
	NSMutableString *cmd = [NSMutableString stringWithString:@"time "];
	
	switch (_mode) {
		case eCLIRequestModeGet:
			[cmd appendString:@" ?"];
			break;
		case eCLIRequestModeSet:
			[cmd appendFormat:@" %d", _time];
			break;
	}
	
	return cmd;
}

- (id) cloneRequest {
	return [[[SLCLICurrentTitleTimeRequest alloc] initWithPlayer:[self player] andMode:_mode andTime:_time] autorelease];
}

- (SLCLIRequestFinishedAction) finishedWithResponse:(NSString *)response {
	[super finishedWithResponse:response];
	
	if (_mode != eCLIRequestModeGet)
		return eFinished;
	
	NSArray *splittedResponse = [self splittedAndUnescapedResponse];
	if ([splittedResponse count] < 3) [NSException raise:NSInternalInconsistencyException format:@"time response is too short."];
	
	_result = [[splittedResponse objectAtIndex:2] intValue];
	return eFinished;
}

- (int) fetchedTime {
	return _result;
}

- (SLCLIRequestMode) mode {
	return _mode;
}
@end
