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

#import "PWTitleResultTransformer.h"
#import "SLTitle.h"
#import "SLArtist.h"
#import "SLAlbum.h"
#import "NSString+CLI.h"

@implementation PWTitleResultTransformer
- (NSArray *) transformResults:(NSArray *)splittedResponse {
	NSMutableArray *titles = [NSMutableArray array];
	NSString *name = nil, *titleId = nil;
	SLTitle *currentTitle = nil;	
	
	NSString *artistName = nil, *albumName = nil;
	int artistId = -1, albumId = -1;
	
	for (int i = 0; i < [splittedResponse count]; i++) {
		NSString *s = [splittedResponse objectAtIndex:i];
		
		if ([[s cliKey] isEqualToString:@"title"])
			name = [s cliValue];
		else if ([[s cliKey] isEqualToString:@"id"])
			titleId = [s cliValue];
		else if (currentTitle) {
			if ([[s cliKey] isEqualToString:@"artwork_track_id"]) [currentTitle setArtId:[[s cliValue] intValue]];
			else if ([[s cliKey] isEqualToString:@"duration"])    [currentTitle setDuration:[[s cliValue] intValue]];
			else if ([[s cliKey] isEqualToString:@"tracknum"])    [currentTitle setTrackNumber:[[s cliValue] intValue]];
			else if ([[s cliKey] isEqualToString:@"artist"])      artistName = [s cliValue];
			else if ([[s cliKey] isEqualToString:@"album"])       albumName = [s cliValue];
			else if ([[s cliKey] isEqualToString:@"artist_id"])	  artistId = [[s cliValue] intValue];
			else if ([[s cliKey] isEqualToString:@"album_id"])	  albumId = [[s cliValue] intValue];
			else if ([[s cliKey] isEqualToString:@"genre"])		  [currentTitle setGenre:[s cliValue]];
		}
		
		if (currentTitle != nil) {
			if (artistName != nil && artistId >= 0) {
				[currentTitle setArtist:[SLArtist artistWithName:artistName andId:artistId]];
				artistName = nil;
				artistId = -1;
			}
			
			if (albumName != nil && albumId >= 0) {
				[currentTitle setAlbum:[SLAlbum albumWithName:albumName andId:albumId]];
				albumName =  nil;
				artistId = -1;
			}
		}
		
		if (name != nil && titleId != nil) {	
			currentTitle = [SLTitle titleWithName:name andId:[titleId intValue]];
			
			[titles addObject:currentTitle];
			name = titleId = nil;
			
			artistName = nil;
			artistId = -1;
			albumName =  nil;
			artistId = -1;
		}
	}
	
	return [NSArray arrayWithArray:titles];
}
@end
