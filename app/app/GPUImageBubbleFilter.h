//
//  GPUImageBubbleFilter.h
//  app
//
//  Created by MacBook Pro on 24/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "GPUImage.h"
#import "GPUImageFilter.h"

@interface GPUImageBubbleFilter : GPUImageFilter

@property (readwrite, nonatomic) CGFloat refractiveIndex;   
@property (readwrite, nonatomic) CGFloat radius;            

@end
