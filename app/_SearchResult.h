// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SearchResult.h instead.

#import <CoreData/CoreData.h>


extern const struct SearchResultAttributes {
	__unsafe_unretained NSString *contentType;
	__unsafe_unretained NSString *height;
	__unsafe_unretained NSString *index;
	__unsafe_unretained NSString *mediaURL;
	__unsafe_unretained NSString *sourceUrl;
	__unsafe_unretained NSString *term;
	__unsafe_unretained NSString *thumbURL;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *width;
} SearchResultAttributes;

extern const struct SearchResultRelationships {
} SearchResultRelationships;

extern const struct SearchResultFetchedProperties {
} SearchResultFetchedProperties;












@interface SearchResultID : NSManagedObjectID {}
@end

@interface _SearchResult : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SearchResultID*)objectID;




@property (nonatomic, strong) NSString* contentType;


//- (BOOL)validateContentType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* height;


@property int16_t heightValue;
- (int16_t)heightValue;
- (void)setHeightValue:(int16_t)value_;

//- (BOOL)validateHeight:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* index;


@property int64_t indexValue;
- (int64_t)indexValue;
- (void)setIndexValue:(int64_t)value_;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* mediaURL;


//- (BOOL)validateMediaURL:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* sourceUrl;


//- (BOOL)validateSourceUrl:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* term;


//- (BOOL)validateTerm:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* thumbURL;


//- (BOOL)validateThumbURL:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* title;


//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* width;


@property int16_t widthValue;
- (int16_t)widthValue;
- (void)setWidthValue:(int16_t)value_;

//- (BOOL)validateWidth:(id*)value_ error:(NSError**)error_;






@end

@interface _SearchResult (CoreDataGeneratedAccessors)

@end

@interface _SearchResult (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveContentType;
- (void)setPrimitiveContentType:(NSString*)value;




- (NSNumber*)primitiveHeight;
- (void)setPrimitiveHeight:(NSNumber*)value;

- (int16_t)primitiveHeightValue;
- (void)setPrimitiveHeightValue:(int16_t)value_;




- (NSNumber*)primitiveIndex;
- (void)setPrimitiveIndex:(NSNumber*)value;

- (int64_t)primitiveIndexValue;
- (void)setPrimitiveIndexValue:(int64_t)value_;




- (NSString*)primitiveMediaURL;
- (void)setPrimitiveMediaURL:(NSString*)value;




- (NSString*)primitiveSourceUrl;
- (void)setPrimitiveSourceUrl:(NSString*)value;




- (NSString*)primitiveTerm;
- (void)setPrimitiveTerm:(NSString*)value;




- (NSString*)primitiveThumbURL;
- (void)setPrimitiveThumbURL:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSNumber*)primitiveWidth;
- (void)setPrimitiveWidth:(NSNumber*)value;

- (int16_t)primitiveWidthValue;
- (void)setPrimitiveWidthValue:(int16_t)value_;




@end
