// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SearchResult.m instead.

#import "_SearchResult.h"

const struct SearchResultAttributes SearchResultAttributes = {
	.contentType = @"contentType",
	.height = @"height",
	.mediaURL = @"mediaURL",
	.sourceUrl = @"sourceUrl",
	.thumbURL = @"thumbURL",
	.title = @"title",
	.width = @"width",
};

const struct SearchResultRelationships SearchResultRelationships = {
};

const struct SearchResultFetchedProperties SearchResultFetchedProperties = {
};

@implementation SearchResultID
@end

@implementation _SearchResult

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SearchResult" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SearchResult";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SearchResult" inManagedObjectContext:moc_];
}

- (SearchResultID*)objectID {
	return (SearchResultID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"heightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"height"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"widthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"width"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic contentType;






@dynamic height;



- (int16_t)heightValue {
	NSNumber *result = [self height];
	return [result shortValue];
}

- (void)setHeightValue:(int16_t)value_ {
	[self setHeight:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveHeightValue {
	NSNumber *result = [self primitiveHeight];
	return [result shortValue];
}

- (void)setPrimitiveHeightValue:(int16_t)value_ {
	[self setPrimitiveHeight:[NSNumber numberWithShort:value_]];
}





@dynamic mediaURL;






@dynamic sourceUrl;






@dynamic thumbURL;






@dynamic title;






@dynamic width;



- (int16_t)widthValue {
	NSNumber *result = [self width];
	return [result shortValue];
}

- (void)setWidthValue:(int16_t)value_ {
	[self setWidth:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveWidthValue {
	NSNumber *result = [self primitiveWidth];
	return [result shortValue];
}

- (void)setPrimitiveWidthValue:(int16_t)value_ {
	[self setPrimitiveWidth:[NSNumber numberWithShort:value_]];
}










@end
