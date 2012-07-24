//
//  GPUImageBubbleFilter.m
//  app
//
//  Created by MacBook Pro on 24/07/12.
//  Copyright (c) 2012 Scimob. All rights reserved.
//

#import "GPUImageBubbleFilter.h"

NSString *const kGPUImageBubbleShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform highp vec2 center;
 uniform highp float radius;
 uniform highp float aspectRatio;
 uniform highp float refractiveIndex;
 
 void main()
 {
     highp vec2 textureCoordinateToUse = vec2(textureCoordinate.x, (textureCoordinate.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
     highp float distanceFromCenter = distance(center, textureCoordinateToUse);
     lowp float checkForPresenceWithinSphere = step(distanceFromCenter, radius);
     
     distanceFromCenter = distanceFromCenter / radius;
     
     highp float normalizedDepth = radius * sqrt(1.0 - distanceFromCenter * distanceFromCenter);
     highp vec3 sphereNormal = normalize(vec3(textureCoordinateToUse - center, normalizedDepth));
     
     highp vec3 refractedVector = refract(vec3(0.0, 0.0, -1.0), sphereNormal, refractiveIndex);
     
     lowp vec4 textureColor = texture2D(inputImageTexture, (refractedVector.xy + 1.0) * 0.5) * checkForPresenceWithinSphere; 
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2) * checkForPresenceWithinSphere;
     
     gl_FragColor = mix(textureColor, textureColor2, textureColor2.a);    
 }
 
 );


@interface GPUImageBubbleFilter () {
    GLint radiusUniform, centerUniform, aspectRatioUniform, refractiveIndexUniform;
}

@property (readwrite, nonatomic) CGFloat aspectRatio;

@end

@implementation GPUImageBubbleFilter
@synthesize radius = _radius, refractiveIndex = _refractiveIndex, aspectRatio = _aspectRatio;

- (id) init {
    self = [super initWithFragmentShaderFromString: kGPUImageBubbleShaderString];
    if( self ) {
        radiusUniform = [filterProgram uniformIndex: @"radius"];
        aspectRatioUniform = [filterProgram uniformIndex: @"aspectRatio"];
        centerUniform = [filterProgram uniformIndex: @"center"];
        refractiveIndexUniform = [filterProgram uniformIndex: @"refractiveIndex"];
        
        self.radius = 0.5;
        self.refractiveIndex = 0.5;
        self.aspectRatio = 1.0;
        
        GLfloat center[2] = {0.5, 0.5};
        [GPUImageOpenGLESContext useImageProcessingContext];
        [filterProgram use];
        glUniform2fv(centerUniform, 1, center);
        
        [self setBackgroundColorRed: 0 green: 0 blue: 0 alpha: 0];
    }
    
    return self;
}

#pragma mark - Accessors
- (void) setRadius:(CGFloat)radius {
    _radius = radius;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(radiusUniform, _radius);
}

- (void) setAspectRatio:(CGFloat)aspectRatio {
    _aspectRatio = aspectRatio;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(aspectRatioUniform, _aspectRatio);
}

- (void)setRefractiveIndex:(CGFloat)newValue;
{
    _refractiveIndex = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(refractiveIndexUniform, _refractiveIndex);
}

@end
