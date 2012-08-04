//
//  configureRestKit.m
//  app
//
//  Created by MacBook Pro on 16/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import <RestKit/RestKit.h>

void configureRestKit(RKObjectManager* manager) {
    //Docs: https://datamarket.azure.com/dataset/bing/search#schema
    //Example: https://api.datamarket.azure.com/Bing/Search/Image?Query=%27america%27&$top=10&$format=json
    
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
}