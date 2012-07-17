// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SearchResult.m instead.

#import "_SearchResult.h"

const struct SearchResultAttributes SearchResultAttributes = {
	.mediaURL = @"mediaURL",
	.thumbURL = @"thumbURL",
	.title = @"title",
};

const struct SearchResultRelationships SearchResultRelationships = {
	.search = @"search",
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
	

	return keyPaths;
}




@dynamic mediaURL;






@dynamic thumbURL;






@dynamic title;






@dynamic search;

	






@end
