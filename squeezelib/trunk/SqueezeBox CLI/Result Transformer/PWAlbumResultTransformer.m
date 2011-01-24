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

#import "PWAlbumResultTransformer.h"
#import "SLAlbum.h"
#import "NSString+CLI.h"

@implementation PWAlbumResultTransformer
- (NSArray *) transformResults:(NSArray *)splittedResponse {
	NSMutableArray *albums = [NSMutableArray array];
	NSString *name = nil, *albumId = nil;
	SLAlbum *currentAlbum = nil;
	for (int i = 0; i < [splittedResponse count]; i++) {
		NSString *s = [splittedResponse objectAtIndex:i];
		
		if ([[s cliKey] isEqualToString:@"album"])
			name = [s cliValue];
		else if ([[s cliKey] isEqualToString:@"id"])
			albumId = [s cliValue];
		else if ([[s cliKey] isEqualToString:@"artwork_track_id"] && currentAlbum)
			[currentAlbum setArtId:[[s cliValue] intValue]];
		else if ([[s cliKey] isEqualToString:@"artist"] && currentAlbum)
			[currentAlbum setArtistName:[s cliValue]];
		
		if (name != nil && albumId != nil) {
			currentAlbum = [SLAlbum albumWithName:name andId:[albumId intValue]];
			[albums addObject:currentAlbum];
			name = nil;
			albumId = nil;
		}
	}
	
	return [NSArray arrayWithArray:albums];
}
@end
