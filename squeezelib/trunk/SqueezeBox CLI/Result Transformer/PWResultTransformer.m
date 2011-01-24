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

#import "PWResultTransformer.h"

#import "PWTitleResultTransformer.h"
#import "PWArtistResultTransformer.h"
#import "PWAlbumResultTransformer.h"
#import "PWGenreResultTransformer.h"

#import "SLTitle.h"
#import "SLAlbum.h"
#import "SLArtist.h"
#import "SLGenre.h"

@implementation PWResultTransformer
+ (id<PWResultTransformerProtocol>) resultTransformerForClass:(Class)aClass {
	if ([aClass isEqual:[SLTitle class]])
		return [[[PWTitleResultTransformer alloc] init] autorelease];
	else if ([aClass isEqual:[SLAlbum class]])
		return [[[PWAlbumResultTransformer alloc] init] autorelease];
	else if ([aClass isEqual:[SLArtist class]])
		return [[[PWArtistResultTransformer alloc] init] autorelease];
	else if ([aClass isEqual:[SLGenre class]])
		return [[[PWGenreResultTransformer alloc] init] autorelease];
	
	[NSException raise:NSInternalInconsistencyException format:@"No transformer for class %@ available.", aClass];
	return nil;
}
@end
