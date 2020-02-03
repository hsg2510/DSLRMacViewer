//
//  TriangleEBOView.m
//  DSLRMacViewer
//
//  Created by hsg2510 on 2018. 12. 5..
//  Copyright © 2018년 hsg2510. All rights reserved.
//

#import "TriangleEBOView.h"
#include <OpenGL/gl3.h>
#include "SKRenderingEngine.hpp"

using namespace CP;


@implementation TriangleEBOView
{
    GLuint mEBO;
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
    [self setupTriangles];
}


- (void)drawRect:(NSRect)aDirtyRect
{
    [super drawRect:aDirtyRect];
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    /*
     아래 함수는 primitive를 그리는 방법을 지정해주는 것이다.
     첫번째 파라미터로, 앞 뒤 모두를
     두번째 파라미터로, 선으로 그려라 라는 것이다.
     
     이후 glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)을 통해서 기본값으로 되돌려 주지 않으면,
     이후의 모든 drawing을 선으로 그려지게 된다.
     */
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glBindVertexArray(mVAO);
    glEnableVertexAttribArray(0);
    SKRenderingEngine::getInstance()->useProgram(mProgram);
    /*
     glDrawElements()는 현재 Binding된 EBO로부터 index들을 가져와서 그림.
     */
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    glDisableVertexAttribArray(0);
    glBindVertexArray(0);
    [[self openGLContext] flushBuffer];
}


- (void)setupTriangles
{
    float sVertices[] = {
        // 첫 번째 삼각형
        0.5f,  0.5f, 0.0f,  // 우측 상단
        0.5f, -0.5f, 0.0f,  // 우측 하단
        -0.5f,  -0.5f, 0.0f,  // 좌측 상단
        -0.5f,  0.5f, 0.0f   // 좌측 상단
    };
    
    glGenBuffers(1, &mVBO);
    glBindBuffer(GL_ARRAY_BUFFER, mVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sVertices), sVertices, GL_STATIC_DRAW);
    glGenVertexArrays(1, &mVAO);
    glBindVertexArray(mVAO);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    
    unsigned int sIndices[] = {  // 0부터 시작한다는 것을 명심
        0, 1, 3,   // 첫 번째 삼각형
        1, 2, 3    // 두 번째 삼각형
    };
    
    glGenBuffers(1, &mEBO);
    /*
     VAO는 또한 EBO도 저장한다.
     저장하는 방법은 VAO가 Binding 되어 있을때 EBO를 Binding 하면 자동으로 저장된다.
     그리고 그리는 시점에 VAO만 Binding을 해도 EBO를 자동으로 Binding 시켜준다.
     */
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mEBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(sIndices), sIndices, GL_STATIC_DRAW);
    
    /*
     VBO, VAO, EBO를 나중에 사용할 일이 있을지 모르니 차례로 Unbinding 시켜주고 있다.
     단, VAO는 EBO의 Binding, Unbinding 정보 둘다 저장하기 때문에
     VAO가 Unbinding되기 전에 EBO를 Unbinding하면 안된다.
     VBO는 상관없다.
     */
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
    
    NSString *sVertexPath = [[NSBundle mainBundle] pathForResource:@"triangle" ofType:@"vsh"];
    NSString *sFragPath = [[NSBundle mainBundle] pathForResource:@"triangle" ofType:@"fsh"];
    GLchar *sVertexSource = (GLchar *)[[NSString stringWithContentsOfFile:sVertexPath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    GLchar *sFragSource = (GLchar *)[[NSString stringWithContentsOfFile:sFragPath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    mProgram = SKRenderingEngine::getInstance()->loadMainShader(sVertexSource, sFragSource);
}

@end
