//
//  CoordinateView.m
//  DSLRMacViewer
//
//  Created by SUNGGON HONG on 04/09/2019.
//  Copyright © 2019 hsg2510. All rights reserved.
//

#import "CoordinateView.h"
#import "NSImage+GLCategory.h"
#include <OpenGL/gl3.h>
#define STB_IMAGE_IMPLEMENTATION
//#include "stb_image.h"
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include "SKRenderingEngine.hpp"

using namespace CP;

@implementation CoordinateView
{
    GLuint mVBO;
    GLuint mVAO;
    GLuint mProgram;
    GLuint mTexture;
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
    [self setupBox];
}


- (void)setupBox
{
    float sVertices[] = {
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    };
    
    glGenBuffers(1, &mVBO);
    glBindBuffer(GL_ARRAY_BUFFER, mVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sVertices), sVertices, GL_STATIC_DRAW);
    glGenVertexArrays(1, &mVAO);
    glBindVertexArray(mVAO);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    
    glGenTextures(1, &mTexture);
    glActiveTexture(GL_TEXTURE0);
    [self bindAndSetup2DTextureConfig:mTexture];
    
    NSImage *sOnePersonImage = [NSImage imageNamed:@"onePerson"];
    
    [self loadImageToTexture:sOnePersonImage];
    
    NSString *sVertexPath = [[NSBundle mainBundle] pathForResource:@"box" ofType:@"vsh"];
    NSString *sFragPath = [[NSBundle mainBundle] pathForResource:@"box" ofType:@"fsh"];
    GLchar *sVertexSource = (GLchar *)[[NSString stringWithContentsOfFile:sVertexPath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    GLchar *sFragSource = (GLchar *)[[NSString stringWithContentsOfFile:sFragPath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    mProgram = SKRenderingEngine::getInstance()->loadMainShader(sVertexSource, sFragSource);
}

- (void)drawRect:(NSRect)aDirtyRect
{
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glBindVertexArray(mVAO);
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    SKRenderingEngine::getInstance()->useProgram(mProgram);
    glUniform1i(glGetUniformLocation(mProgram, "u_texture"), 0);
    glm::mat4 model         = glm::mat4(1.0f); // make sure to initialize matrix to identity matrix first
    glm::mat4 view          = glm::mat4(1.0f);
    glm::mat4 projection    = glm::mat4(1.0f);
    model = glm::rotate(model, (float)3.0, glm::vec3(0.5f, 1.0f, 0.0f));
    view  = glm::translate(view, glm::vec3(0.0f, 0.0f, -3.0f));
    projection = glm::perspective(glm::radians(45.0f), (float)0.5625, 0.1f, 100.0f);
    // retrieve the matrix uniform locations
//    unsigned int modelLoc = glGetUniformLocation(ourShader.ID, "model");
//    unsigned int viewLoc  = glGetUniformLocation(ourShader.ID, "view");
//    // pass them to the shaders (3 different ways)
//    glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));
//    glUniformMatrix4fv(viewLoc, 1, GL_FALSE, &view[0][0]);

    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    [[self openGLContext] flushBuffer];
}

- (void)loadImageToTexture:(NSImage *)aImage
{
    GLubyte *sData = [aImage glByteByConverted];
    int sWidth = [aImage getWidth];
    int sHeight = [aImage getHeight];
    
    if (sData)
    {
        /*
         2번째 파라미터 : 우리가 생성하는 텍스처의 mipmap 레벨을 수동으로 지정하고 싶을때 지정한다.
         3번째 파라미터 : 텍스처가 어떤 포맷을 가져야 할지 알려준다.
         4번째, 5번째 파라미터 : 텍스처의 너비와 높이를 설정한다.
         6번째 파라미터 : 항상 0으로 지정해야 한다.
         7번째, 8번째 파라미터 : 원본 이미지의 포맷과 데이터 타입을 지정한다. unsigned char*(uBytes)로 저장했기 때문에, 해당 값으로 지정.
         마지막 파라미터 : 실제 데이터
         */
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, sWidth, sHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, sData);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    else
    {
        NSLog(@"Failed to load texture");
    }
}


- (void)bindAndSetup2DTextureConfig:(GLuint)aTexture
{
    glBindTexture(GL_TEXTURE_2D, aTexture);
    // 텍스처 wrapping/filtering 옵션 설정(현재 바인딩된 텍스처 객체에 대해)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}

@end
