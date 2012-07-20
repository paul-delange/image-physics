// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SearchResponse.h instead.

#import <CoreData/CoreData.h>


extern const struct SearchResponseAttributes {
	__unsafe_unretained NSString *term;
} SearchResponseAttributes;

extern const struct SearchResponseRelationships {
	__unsafe_unretained NSString *results;
} SearchResponseRelationships;

extern const struct SearchResponseFetchedProperties {
} SearchResponseFetchedProperties;

@class SearchResult;



@interface SearchResponseID : NSManagedObjectID {}
@end

@interface _SearchResponse : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SearchResponseID*)objectID;




@property (nonatomic, strong) NSString* term;


//- (BOOL)validateTerm:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* results;

- (NSMutableSet*)resultsSet;





@end

@interface _SearchResponse (CoreDataGeneratedAccessors)

- (void)addResults:(NSSet*)value_;
- (void)removeResults:(NSSet*)value_;
- (void)addResultsObject:(SearchResult*)value_;
- (void)removeResultsObject:(SearchResult*)value_;

@end

@interface _SearchResponse (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveTerm;
- (void)setPrimitiveTerm:(NSString*)value;





- (NSMutableSet*)primitiveResults;
- (void)setPrimitiveResults:(NSMutableSet*)value;


@end
