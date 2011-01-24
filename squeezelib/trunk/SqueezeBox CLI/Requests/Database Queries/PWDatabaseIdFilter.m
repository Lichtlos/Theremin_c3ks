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

#import "PWDatabaseIdFilter.h"

@interface PWDatabaseIdFilter (PrivateMethods)
- (NSString *) filterForType:(PWDatabaseIdFilterType)aType;
@end

@implementation PWDatabaseIdFilter
- (id) initWithType:(PWDatabaseIdFilterType)aType andId:(int)aId {
	self = [super init];
	if (self != nil) {
		_type = aType;
		_id = aId;
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (NSString *) filterForType:(PWDatabaseIdFilterType)aType {
	switch (aType) {
		case PWDatabaseIdFilterAlbum:
			return @"album_id";
		case PWDatabaseIdFilterArtist:
			return @"artist_id";
		case PWDatabaseIdFilterGenre:
			return @"genre_id";
	}
	[NSException raise:NSInternalInconsistencyException format:@"Unknown type %d", aType];
	return nil;
}

- (NSString *) assembleFilter {
	NSMutableString *s = [NSMutableString string];
	[s appendFormat:@"%@:%d", [self filterForType:_type], _id];
	return s;
}

- (PWDatabaseIdFilterType) type {
	return _type;
}

- (int) id {
	return _id;
}
@end
