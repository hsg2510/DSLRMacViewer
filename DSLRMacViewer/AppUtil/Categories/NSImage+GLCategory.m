//
//  NSImage+GLCategory.m
//  DSLRMacViewer
//
//  Created by hsg2510 on 2018. 12. 8..
//  Copyright © 2018년 hsg2510. All rights reserved.
//

#import "NSImage+GLCategory.h"


@implementation NSImage (GLCategory)


#pragma mark - public


- (GLubyte *)glByteByConverted
{
    CGImageRef sImageRef = [self cgImageRef];
    
    int sWidth = (int)CGImageGetWidth(sImageRef);
    int sHeight = (int)CGImageGetHeight(sImageRef);
    
    GLubyte* sTextureData = (GLubyte *)malloc(sWidth * sHeight * 4); // if 4 components per pixel (RGBA)
    CGColorSpaceRef sColorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger sBytesPerPixel = 4;
    NSUInteger sBytesPerRow = sBytesPerPixel * sWidth;
    NSUInteger sBitsPerComponent = 8;
    CGContextRef sContext = CGBitmapContextCreate(sTextureData, sWidth, sHeight,
                                                  sBitsPerComponent, sBytesPerRow, sColorSpace,
                                                  kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(sColorSpace);
    CGContextDrawImage(sContext, CGRectMake(0, 0, sWidth, sHeight), sImageRef);
    CGContextRelease(sContext);
    
    return sTextureData;
}


- (int)getWidth
{
    CGImageRef sImageRef = [self cgImageRef];
    
    return (int)CGImageGetWidth(sImageRef);
}


- (int)getHeight
{
    CGImageRef sImageRef = [self cgImageRef];
    
    return (int)CGImageGetHeight(sImageRef);
}


#pragma mark - privates


- (CGImageRef)cgImageRef
{
    NSData *sImageData = [self TIFFRepresentation];
    CGImageSourceRef sSource = CGImageSourceCreateWithData((__bridge CFDataRef)sImageData, NULL);
    
    return CGImageSourceCreateImageAtIndex(sSource, 0, NULL);
}


@end
