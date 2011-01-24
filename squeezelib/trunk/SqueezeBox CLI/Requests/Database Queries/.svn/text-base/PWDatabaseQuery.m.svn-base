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

#import "PWDatabaseQuery.h"
#import "PWDatabaseFilterProtocol.h"
#import "PWResultTransformer.h"

#import "SLAlbum.h"
#import "SLTitle.h"
#import "SLArtist.h"
#import "SLGenre.h"

@interface PWDatabaseQuery (PrivateMethods)
- (NSString *) assembleCommand;

- (NSString *) assembleFilters:(NSArray *)theFilters;
- (NSString *) commandForType:(PWDatabaseQueryEntityType)aType;
- (NSString *) additionalCommandParameters;
- (Class) classForType:(PWDatabaseQueryEntityType)aType;
@end

@implementation PWDatabaseQuery
- (id) initWithEntityType:(PWDatabaseQueryEntityType)aType andFilters:(NSArray *)someFilters {
	self = [super initWithCommand:nil];
	if (self != nil) {
		_type = aType;
		_filters = [someFilters retain];
		_offset = 0;
		
		[self setCommand:[self assembleCommand]];
	}
	return self;
}

- (void) dealloc
{
	[_filters release];
	[super dealloc];
}

- (NSString *) assembleCommand {
	NSMutableString *s = [NSMutableString string];
	[s appendFormat:@"%@ ", [self commandForType:_type]];
	[s appendFormat:@"%d 80 ", _offset];
	[s appendString:[self assembleFilters:_filters]];
	[s appendString:[self additionalCommandParameters]];
	return s;
}

- (NSString *) assembleFilters:(NSArray *)theFilters {
	NSMutableString *s = [NSMutableString string];
	for (int i = 0; i < [theFilters count]; i++) {
		id<PWDatabaseFilterProtocol> protocol = [theFilters objectAtIndex:i];
		[s appendFormat:@" %@ ", [protocol assembleFilter]];
	}
	return s;
}

- (NSString *) commandForType:(PWDatabaseQueryEntityType)aType {
	switch (aType) {
		case PWDatabaseQueryEntityTypeAlbum:
			return @"albums";
		case PWDatabaseQueryEntityTypeArtist:
			return @"artists";
		case PWDatabaseQueryEntityTypeGenre:
			return @"genres";
		case PWDatabaseQueryEntityTypeTitle:
			return @"songs";
	}
	[NSException raise:NSInternalInconsistencyException format:@"Unknown type %d", aType];
	return nil;
}

- (Class) classForType:(PWDatabaseQueryEntityType)aType {
	switch (aType) {
		case PWDatabaseQueryEntityTypeAlbum:
			return [SLAlbum class];
		case PWDatabaseQueryEntityTypeArtist:
			return [SLArtist class];
		case PWDatabaseQueryEntityTypeGenre:
			return [SLGenre class];
		case PWDatabaseQueryEntityTypeTitle:
			return [SLTitle class];
	}
	[NSException raise:NSInternalInconsistencyException format:@"Unknown type %d", aType];
	return nil;
}

- (NSString *) additionalCommandParameters {
	if (_type == PWDatabaseQueryEntityTypeTitle) {
		return @"tags:dtJalsge";
	}
	return @"";
}

- (NSArray *) currentResultList {
	return [[PWResultTransformer resultTransformerForClass:[self classForType:_type]] transformResults:[self splittedAndUnescapedResponse]];
}

- (void) setOffset:(int)offset {
	_offset = offset;
	[super setCommand:[self assembleCommand]];
}

- (PWDatabaseQueryEntityType)type {
	return _type;
}

@end
