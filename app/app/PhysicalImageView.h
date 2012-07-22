//
//  PhysicalImageView.h
//  app
//
//  Created by MacBook Pro on 18/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "PhysicalView.h"

@class SearchResult;

@interface PhysicalImageView : PhysicalView

@property (nonatomic, strong) SearchResult* imageModel;

@end
