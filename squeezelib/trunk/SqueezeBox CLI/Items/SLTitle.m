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

#import "SLTitle.h"
#import "NSString+CLI.h"

#import "SLArtist.h"
#import "SLAlbum.h"

@implementation SLTitle
+ (id) titleWithName:(NSString *)name andId:(int)titleId {
	return [[[SLTitle alloc] initWithName:name andId:titleId] autorelease];
}

- (id) initWithName:(NSString *)name andId:(int)titleId {
	self = [super init];
	if (self != nil) {
		_name = [name copy];
		_id = titleId;
		_trackNumber = -1;
		_duration = -1;
	}
	return self;
}

- (void) dealloc
{
	[_path release];
	[_name release];
	[_artist release];
	[_album release];
	[_genre release];
	[super dealloc];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"Title <%d> %@ (%d %d %d)", _id, [self title], [self trackNumber], [self duration], [self artId]];
}

- (NSString *) title {
	return [[_name retain] autorelease];
}

- (int) artId {
	return _albumArtId;
}

- (int) duration {
	return _duration;
}

- (int) trackNumber {
	return _trackNumber;
}

- (int) titleId {
	return _id;
}

- (void) setArtId:(int)aArtId {
	_albumArtId = aArtId;
}

- (void) setDuration:(int)aDuration {
	_duration = aDuration;
}

- (void) setTrackNumber:(int)aTrackNumber {
	_trackNumber = aTrackNumber;
}

- (NSString *) sortTitle {
	if (_trackNumber != -1)
		return [NSString stringWithFormat:@"%03d %@", _trackNumber, [self title]];
	return [self title];
}

- (NSString *) formattedDuration {
	return [NSString stringWithFormat:@"%d:%02d", _duration / 60, _duration % 60];
}

- (NSString *) formattedTrackNumber {
	return [NSString stringWithFormat:@"%d", _trackNumber];
}

- (NSComparisonResult)caseInsensitiveCompare:(SLTitle *)title {
	return [[self sortTitle] caseInsensitiveCompare:[title sortTitle]];
}




- (void) setAlbum:(SLAlbum *)aAlbum {
	[_album release];
	_album = [aAlbum retain];
}

- (void) setArtist:(SLArtist *)aArtist {
	[_artist release];
	_artist = [aArtist retain];
}

- (void) setGenre:(NSString *)aGenre {
	[_genre release];
	_genre = [aGenre retain];
}

- (void) setPath:(NSString *)aPath {
	[_path release];
	_path = [aPath retain];
}

- (SLAlbum *)album {
	return [[_album retain] autorelease];
}

- (SLArtist *)artist {
	return [[_artist retain] autorelease];
}

- (NSString *)genre {
	return [[_genre retain] autorelease];
}

- (NSString *)path {
	return [[_path retain] autorelease];
}

@end
