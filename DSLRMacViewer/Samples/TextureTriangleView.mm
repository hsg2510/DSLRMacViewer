//
//  TextureTriangleView.m
//  DSLRMacViewer
//
//  Created by hsg2510 on 2018. 12. 8..
//  Copyright © 2018년 hsg2510. All rights reserved.
//

#import "TextureTriangleView.h"
#import "NSImage+GLCategory.h"
#include <OpenGL/gl3.h>
#include "SKRenderingEngine.hpp"

using namespace CP;


@implementation TextureTriangleView
{
    GLuint mEBO;
    GLuint mVBO;
    GLuint mVAO;
    GLuint mProgram;
    GLuint mTexture1;
    GLuint mTexture2;
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
    glBindVertexArray(mVAO);
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glEnableVertexAttribArray(2);
    SKRenderingEngine::getInstance()->useProgram(mProgram);
    glUniform1i(glGetUniformLocation(mProgram, "texture1"), 0);
    glUniform1i(glGetUniformLocation(mProgram, "texture2"), 1);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
    [[self openGLContext] flushBuffer];
}


- (void)setupTriangle
{
    float sVertices[] = {
        // 위치              // 컬러             // 텍스처 좌표
        1.0f,  1.0f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 0.0f,   // 우측 상단
        1.0f, -1.0f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 1.0f,   // 우측 하단
        -1.0f, -1.0f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 1.0f,   // 좌측 하단
        -1.0f,  1.0f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 0.0f    // 좌측 상단
    };

    glGenBuffers(1, &mVBO);
    glBindBuffer(GL_ARRAY_BUFFER, mVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sVertices), sVertices, GL_STATIC_DRAW);
    glGenVertexArrays(1, &mVAO);
    glBindVertexArray(mVAO);

    unsigned int sIndices[] = {  // 0부터 시작한다는 것을 명심하세요!
        0, 1, 3,   // 첫 번째 삼각형
        1, 2, 3    // 두 번째 삼각형
    };

    glGenBuffers(1, &mEBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,mEBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(sIndices), sIndices, GL_STATIC_DRAW);

    glGenTextures(1, &mTexture1);

    /*
     glActiveTexture로 텍스처 유닛을 활성화한 후에 호출되는 glBindTexture 함수는 해당 텍스처를 현재 활성화된 텍스처 유닛에 바인딩합니다.
     */
    glActiveTexture(GL_TEXTURE0);
    [self bindAndSetup2DTextureConfig:mTexture1];

    NSImage *sOnePersonImage = [NSImage imageNamed:@"onePerson"];

    [self loadImageToTexture:sOnePersonImage];

    glGenTextures(1, &mTexture2);
    glActiveTexture(GL_TEXTURE1);
    [self bindAndSetup2DTextureConfig:mTexture2];

    NSImage *sTwoPeopleImage = [NSImage imageNamed:@"twoPeople"];

    [self loadImageToTexture:sTwoPeopleImage];

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(3 * sizeof(float)));
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(6 * sizeof(float)));

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);

    NSString *sVertexPath = [[NSBundle mainBundle] pathForResource:@"textureTriangle" ofType:@"vsh"];
    NSString *sFragPath = [[NSBundle mainBundle] pathForResource:@"textureTriangle" ofType:@"fsh"];
    GLchar *sVertexSource = (GLchar *)[[NSString stringWithContentsOfFile:sVertexPath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    GLchar *sFragSource = (GLchar *)[[NSString stringWithContentsOfFile:sFragPath encoding:NSUTF8StringEncoding error:nil] UTF8String];

    mProgram = SKRenderingEngine::getInstance()->loadMainShader(sVertexSource, sFragSource);
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
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, sWidth, sHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, sData);
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
