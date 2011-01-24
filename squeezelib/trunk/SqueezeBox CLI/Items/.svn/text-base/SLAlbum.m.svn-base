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

#import "SLAlbum.h"

@implementation SLAlbum
+ (id) albumWithName:(NSString *)name andId:(int)albumId {
	return [[[SLAlbum alloc] initWithName:name andId:albumId] autorelease];
}

- (id) initWithName:(NSString *)name andId:(int)albumId {
	self = [super init];
	if (self != nil) {
		_name = [name copy];
		_id = albumId;
	}
	return self;
}

- (void) dealloc
{
	[_artistName release];
	[_name release];
	[super dealloc];
}

- (int) artId {
	return _artId;
}

- (void) setArtId:(int)aArtId {
	_artId = aArtId;
}

- (int) albumId {
	return _id;
}

- (NSString *) title {
	return [[_name retain] autorelease];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"Album <%d> %@ <artid:%d>", [self albumId], [self title], [self artId]];
}

- (NSString *) sortTitle {
	NSRange r = [[self title] rangeOfString:@"the " options:NSCaseInsensitiveSearch];
	if (r.location == 0) {
		return [[self title] substringFromIndex:r.length];
	}
	
	return [self title];
}

- (NSComparisonResult)caseInsensitiveCompare:(SLAlbum *)artist {
	return [[self sortTitle] caseInsensitiveCompare:[artist sortTitle]];
}

- (void) setArtistName:(NSString *)aArtist {
	[_artistName release];
	_artistName = [aArtist retain];
}

- (NSString *) artistName {
	return [[_artistName retain] autorelease];
}

- (BOOL)isEqual:(id)anObject {
	if ([anObject isKindOfClass:[SLAlbum class]]) {
		return [self isEqualToAlbum:anObject];
	}
	return NO;
}

- (BOOL)isEqualToAlbum:(SLAlbum *)anotherAlbum {
	return [self albumId] == [anotherAlbum albumId];
}

- (unsigned)hash {
	return [_name hash] ^ _id;
}

- (id)copyWithZone:(NSZone *)zone {
	SLAlbum *newAlbum = [[SLAlbum allocWithZone:zone] initWithName:_name andId:_id];
	newAlbum->_artistName = [[self artistName] copyWithZone:zone];
	newAlbum->_artId = [self artId];
	
	return newAlbum;
}
@end
