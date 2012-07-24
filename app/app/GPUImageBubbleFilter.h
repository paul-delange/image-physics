//
//  GPUImageBubbleFilter.h
//  app
//
//  Created by MacBook Pro on 24/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "GPUImage.h"
#import "GPUImageTwoInputFilter.h"

@interface GPUImageBubbleFilter : GPUImageTwoInputFilter

@property (readwrite, nonatomic) CGFloat refractiveIndex;   
@property (readwrite, nonatomic) CGFloat radius;            

@end
