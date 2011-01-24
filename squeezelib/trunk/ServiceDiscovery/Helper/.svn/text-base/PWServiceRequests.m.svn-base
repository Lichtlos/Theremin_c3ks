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

#import "PWServiceRequests.h"

@implementation PWServiceRequests
+ (NSData *) nameRequest {
	NSMutableData *data = [NSMutableData data];
	
	// extensible request
	uint8_t extensible = 'e';
	[data appendBytes:&extensible length:sizeof(extensible)];
	
	// hostname
	const char *method = "NAME";
	[data appendBytes:method length:strlen(method)];
	
	uint8_t length = 0;
	[data appendBytes:&length length:sizeof(length)];
	
	return [NSData dataWithData:data];
}

+ (NSData *) cliPortRequest {
	NSMutableData *data = [NSMutableData data];
	
	// extensible request
	uint8_t extensible = 'e';
	[data appendBytes:&extensible length:sizeof(extensible)];
	
	// hostname
	const char *method = "CLIP";
	[data appendBytes:method length:strlen(method)];
	
	uint8_t length = 0;
	[data appendBytes:&length length:sizeof(length)];
	
	return [NSData dataWithData:data];
}
@end
