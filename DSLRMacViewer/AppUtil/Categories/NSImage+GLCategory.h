//
//  NSImage+GLCategory.h
//  DSLRMacViewer
//
//  Created by hsg2510 on 2018. 12. 8..
//  Copyright © 2018년 hsg2510. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (GLCategory)

- (GLubyte *)glByteByConverted;
- (int)getWidth;
- (int)getHeight;


@end

NS_ASSUME_NONNULL_END
