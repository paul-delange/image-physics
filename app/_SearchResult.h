// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SearchResult.h instead.

#import <CoreData/CoreData.h>


extern const struct SearchResultAttributes {
	__unsafe_unretained NSString *mediaURL;
	__unsafe_unretained NSString *thumbURL;
	__unsafe_unretained NSString *title;
} SearchResultAttributes;

extern const struct SearchResultRelationships {
	__unsafe_unretained NSString *search;
} SearchResultRelationships;

extern const struct SearchResultFetchedProperties {
} SearchResultFetchedProperties;

@class SearchResponse;





@interface SearchResultID : NSManagedObjectID {}
@end

@interface _SearchResult : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SearchResultID*)objectID;




@property (nonatomic, strong) NSString* mediaURL;


//- (BOOL)validateMediaURL:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* thumbURL;


//- (BOOL)validateThumbURL:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* title;


//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SearchResponse* search;

//- (BOOL)validateSearch:(id*)value_ error:(NSError**)error_;





@end

@interface _SearchResult (CoreDataGeneratedAccessors)

@end

@interface _SearchResult (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveMediaURL;
- (void)setPrimitiveMediaURL:(NSString*)value;




- (NSString*)primitiveThumbURL;
- (void)setPrimitiveThumbURL:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (SearchResponse*)primitiveSearch;
- (void)setPrimitiveSearch:(SearchResponse*)value;


@end
