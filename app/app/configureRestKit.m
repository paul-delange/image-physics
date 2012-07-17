//
//  configureRestKit.m
//  app
//
//  Created by MacBook Pro on 16/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import <RestKit/RestKit.h>

void configureRestKit(RKObjectManager* manager) {
    //Docs: http://msdn.microsoft.com/en-us/library/dd251094
    //Example: http://api.bing.net/json.aspx?AppId=EADA47E8862F8D8EE67D68882289189A2115F6AA&Query=car&Sources=Image&Image.Count=50
    
    RKObjectMappingProvider* provider = manager.mappingProvider;
    RKManagedObjectStore* store = manager.objectStore;
    
    RKManagedObjectMapping* searchMapping = [RKManagedObjectMapping mappingForClass: NSClassFromString(@"SearchResponse")
                                                               inManagedObjectStore: store];
    RKManagedObjectMapping* resultMapping = [RKManagedObjectMapping mappingForClass: NSClassFromString(@"SearchResult")
                                                               inManagedObjectStore: store];
    RKObjectMapping* paginatorMapping = [RKObjectMapping mappingForClass: NSClassFromString(@"BingPaginator")];
    
    //Configure search mapping
    [searchMapping mapKeyPath: @"Query.SearchTerms" toAttribute: @"term"];
    [searchMapping mapKeyPath: @"Image.Results" toRelationship: @"results" withMapping: resultMapping];
    
    //Configure result mapping
    [resultMapping mapKeyPathsToAttributes:
     @"Title", @"title",
     @"MediaUrl", @"mediaURL",
     @"Thumbnail.Url", @"thumbURL",
     nil];
    
    //Configure pagination
    [paginatorMapping mapKeyPath: @"SearchResponse.Image.Total" toAttribute: @"objectCount"];
    [paginatorMapping mapKeyPath: @"SearchResponse.Image.Offset" toAttribute: @"currentOffset"];
    
    provider.paginationMapping = paginatorMapping;
    
    [provider setMapping: searchMapping forKeyPath: @"SearchResponse"];
}