//
//  ShadersView.m
//  DSLRMacViewer
//
//  Created by hsg2510 on 2018. 12. 6..
//  Copyright © 2018년 hsg2510. All rights reserved.
//

#import "ShadersView.h"
#include <OpenGL/gl3.h>
#include "SKRenderingEngine.hpp"

using namespace CP;

/*
 vecn: n개의 float 타입 요소를 가지는 기본적인 vector(ex. vec2, vec3, vec4)
 bvecn: n개의 boolean 타입 요소를 가지는 vector
 ivecn: n개의 integer 타입 요소를 가지는 vector.
 uvecn: n개의 unsigned integer 타입 요소를 가지는 vector
 dvecn: n개의 double 타입 요소를 가지는 vector
 */

/*
 layout (location = 0) 명시자를 사용하지 않고 glGetAttribLocation 함수를 통해 attribute의 location은 물어볼 수 있지만 vertex shader에 직접 설정하는 것을 권장합니다. 이는 이해하기 쉽고 다른 작업을 하지 않아도 되도록 합니다.
 */

/*
 데이터를 한 shader에서 다른 shader롤 넘기고 싶다면 보내는 shader에서 출력을 선언해야하고 마찬가지로 받는 shader에서 입력을 선언해야 합니다. 양쪽의 타입과 이름이 같다면 OpenGL은 그 변수들을 연결시켜 shader 간에 데이터를 보낼 수 있도록 합니다(program 객체의 연결이 완료되면)
 */

/*
 uniform은 shader program 객체이서 고유한 변수이고 shader program의 모든 단계의 모든 shader에서 접근 가능합니다.
 */


@implementation ShadersView
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
    [super drawRect:aDirtyRect];
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    GLfloat sGreenValue = 0.5;
    /*
     glGetUniformLocation()을 사용하여 uniform location을 얻을 수 있다.
     이 함수는 program 객체를 직접 지정하기 때문에 glUseProgram()을 미리
     불러줄 필요는 없지만, glUniform4f()류의 uniform 값을 변경하는 함수들은
     현재 활성화 되어 있는 program을 접근하기 때문에, glUseProgam()을 통해
     해당 프로그램을 미리 활성화 시켜야 한다.
     glGetUniformLocation()이 -1을 return 하면 location을 찾지 못했다는 것이다.
     */
    GLint sVertexColorLocation = glGetUniformLocation(mProgram, "ourColor");
    SKRenderingEngine::getInstance()->useProgram(mProgram);
    glUniform4f(sVertexColorLocation, 0.0f, sGreenValue, 0.0f, 1.0f);
    glBindBuffer(GL_ARRAY_BUFFER, mVBO);
    glBindVertexArray(mVAO);
    glEnableVertexAttribArray(0);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    [[self openGLContext] flushBuffer];
}

- (void)setupTriangle
{
    float sVertices[] =
    {
        0.0, 0.5, 0.0,
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0
    };
    
    glGenBuffers(1, &mVBO);
    glBindBuffer(GL_ARRAY_BUFFER, mVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sVertices), sVertices, GL_STATIC_DRAW);
    glGenVertexArrays(1, &mVAO);
    glBindVertexArray(mVAO);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    NSString *sVertexPath = [[NSBundle mainBundle] pathForResource:@"vertexShader" ofType:@"vsh"];
    NSString *sFragPath = [[NSBundle mainBundle] pathForResource:@"fragmentShader" ofType:@"fsh"];
    GLchar *sVertexSource = (GLchar *)[[NSString stringWithContentsOfFile:sVertexPath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    GLchar *sFragSource = (GLchar *)[[NSString stringWithContentsOfFile:sFragPath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    mProgram = SKRenderingEngine::getInstance()->loadMainShader(sVertexSource, sFragSource);
}


@end
