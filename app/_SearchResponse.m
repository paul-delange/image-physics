// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SearchResponse.m instead.

#import "_SearchResponse.h"

const struct SearchResponseAttributes SearchResponseAttributes = {
	.term = @"term",
};

const struct SearchResponseRelationships SearchResponseRelationships = {
	.results = @"results",
};

const struct SearchResponseFetchedProperties SearchResponseFetchedProperties = {
};

@implementation SearchResponseID
@end

@implementation _SearchResponse

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SearchResponse" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SearchResponse";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SearchResponse" inManagedObjectContext:moc_];
}

- (SearchResponseID*)objectID {
	return (SearchResponseID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic term;






@dynamic results;

	
- (NSMutableSet*)resultsSet {
	[self willAccessValueForKey:@"results"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"results"];
  
	[self didAccessValueForKey:@"results"];
	return result;
}
	






@end
