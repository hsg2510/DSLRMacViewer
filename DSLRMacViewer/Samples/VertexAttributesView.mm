//
//  VertexAttributesView.m
//  DSLRMacViewer
//
//  Created by hsg2510 on 2018. 12. 6..
//  Copyright © 2018년 hsg2510. All rights reserved.
//

#import "VertexAttributesView.h"
#include <OpenGL/gl3.h>
#include "SKRenderingEngine.hpp"

using namespace CP;


@implementation VertexAttributesView
{
    GLuint mVBO;
    GLuint mVAO;
    GLuint mProgram;
}


- (void)awakeFromNib
{
    NSOpenGLPixelFormatAttribute sAttrs[] =
    {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize,
        24,
        NSOpenGLPFAOpenGLProfile,
        NSOpenGLProfileVersion3_2Core,
        0
    };
    
    NSOpenGLPixelFormat *sPixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:sAttrs];
    
    if (!sPixelFormat)
    {
        NSLog(@"No OpenGL pixel format");
    }
    
    NSOpenGLContext* sContext = [[NSOpenGLContext alloc] initWithFormat:sPixelFormat shareContext:nil];
    
    [self setPixelFormat:sPixelFormat];
    [self setOpenGLContext:sContext];
    [[self openGLContext] makeCurrentContext];
    [self setupTriangle];
}


- (void)drawRect:(NSRect)aDirtyRect
{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindBuffer(GL_ARRAY_BUFFER, mVBO);
    glBindVertexArray(mVAO);
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    SKRenderingEngine::getInstance()->useProgram(mProgram);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    [[self openGLContext] flushBuffer];}


- (void)setupTriangle
{
    float sVertices[] = {
        // 위치              // 컬러
        0.5f, -0.5f, 0.0f,  1.0f, 0.0f, 0.0f,   // 우측 하단
        -0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,   // 좌측 하단
        0.0f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f    // 위
    };
    
    glGenBuffers(1, &mVBO);
    glBindBuffer(GL_ARRAY_BUFFER, mVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sVertices), sVertices, GL_STATIC_DRAW);
    glGenVertexArrays(1, &mVAO);
    glBindVertexArray(mVAO);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)0);
    /*
     stride가 6 * sizeof(float) 이고, 시작좌표가 3 * sizeof(float) 이다.
     */
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(3 * sizeof(float)));
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    NSString *sVertexPath = [[NSBundle mainBundle] pathForResource:@"attributes" ofType:@"vsh"];
    NSString *sFragPath = [[NSBundle mainBundle] pathForResource:@"attributes" ofType:@"fsh"];
    GLchar *sVertexSource = (GLchar *)[[NSString stringWithContentsOfFile:sVertexPath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    GLchar *sFragSource = (GLchar *)[[NSString stringWithContentsOfFile:sFragPath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    mProgram = SKRenderingEngine::getInstance()->loadMainShader(sVertexSource, sFragSource);
}

@end
