//
//  TriangleView.m
//  DSLRMacViewer
//
//  Created by hsg2510 on 2018. 12. 4..
//  Copyright © 2018년 hsg2510. All rights reserved.
//

#import "TriangleView.h"
#include <OpenGL/gl3.h>
#include "SKRenderingEngine.hpp"

using namespace CP;


@implementation TriangleView
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


- (void)setupTriangle
{
    float sVertices[] =
    {
        0.0, 0.5, 0.0,
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0
    };
    
    /*
     Vertex Buffer Object(VBO)는 많은 양의 Vertex attribute 데이터들을
     GPU 메모리에 저장할 수 있다.
     CPU -> GPU로의 데이터 전송은 느리기 때문에, 한번에 많은 데이터를 전송하는 것이 좋다.
     glBufferData()를 통해 한번에 많은 데이터를 GPU로 보낼 수 있다.
     */
    glGenBuffers(1, &mVBO);
    
    /*
     VBO의 버퍼 유형은 GL_ARRAY_BUFFER 이다.
     Binding한 이후 시점부터 GL_ARRAY_BUFFER를 Target으로 하는 모든 버퍼는
     Binding된 VBO를 사용하게 된다.
     */
    glBindBuffer(GL_ARRAY_BUFFER, mVBO);
    
    /*
     이 함수는 데이터를 VBO에 복사한다.
     두번째 파라미터는, 데이터의 크기(바이트 단위).
     세번째 파라미터는, 실제 데이터
     네번째 파라미터는,
     GL_STATIC_DRAW: 데이터가 거의 변하지 않습니다.
     GL_DYNAMIC_DRAW: 데이터가 자주 변경됩니다.
     GL_STREAM_DRAW: 데이터가 그려질때마다 변경됩니다.
     
     예를 들어, 자주 바뀔 수 있는 GL_DYNAMIC_DRAW, GL_STREAM_DRAW로 설정하면
     GPU가 빠르게 접근할 수 있는 메모리에 데이터를 저장한다.
     */
    glBufferData(GL_ARRAY_BUFFER, sizeof(sVertices), sVertices, GL_STATIC_DRAW);
    
    /*
     Vertex Array Object(VAO)는 VBO와 같이 Binding 될 수 있다.
     Binding 된 이후, Vertex Attribute에 관한 호출정보는 VAO에 저장됨.
     
     저장 항목
     1. glEnableVertexAttribArray 함수나 glDisableVertexAttribArray 함수의 호출여부
     2. glVertexAttribPointer 함수를 통한 Vertex Attribute의 구성
     3. glVertexAttribPointer 함수를 통해 Vertex Attribute과 연결된 VBO들.
     
     즉, 위 3개의 함수들은 VAO가 Binding된 이후에 호출해줘야 VAO에 저장된다.
     */
    glGenVertexArrays(1, &mVAO);
    glBindVertexArray(mVAO);
    
    /*
     단순히 VBO 에다가 데이터만 복사해놓고, OpenGL에게 알아써 쓰라고 하면 안된다.
     해당 데이터를 어떻게 사용할지 알려줘야 하는데, 바로 다음 함수를 사용한다.
     동작 방식은, 현재 Binding된 VBO를 밑에 여섯개의 파라미터와 묶어서
     현재 Binding된 VAO에 저장하는 것이다.
     나중에 Draw Call이 호출될 때 OpenGL이 Binding된 VAO를 보고
     Vertex 데이터를 가져다 쓰는 방식이다.
     
     첫번째 파라미터, Vertex Attribute 위치.
     두번째 파라미터, Vertex Attribute 데이터 개수, vec3 이므로 3.
     세번째 파라미터, 데이터 타입.
     네번째 파라미터, 정규화 여부, 부호를 가진 타입이면 -1 ~ 1, 부호 없으면 0 ~ 1
     사이로 정규화 됨.
     다섯번째 파라미터, stride, Vertex간의 간격, 0으로 지정하면 데이터 타입과 개수를 보고 알아서 계산한다.
     여섯번째 파라미터, 버퍼에서 데이터가 시작하는 offset(void* 으로 형변환 필요).
     */
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    
    /*
     VBO, VAO를 나중에 사용하기 위해 Unbinding 시켜준다.
     */
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    NSString *sVertexPath = [[NSBundle mainBundle] pathForResource:@"triangle" ofType:@"vsh"];
    NSString *sFragPath = [[NSBundle mainBundle] pathForResource:@"triangle" ofType:@"fsh"];
    GLchar *sVertexSource = (GLchar *)[[NSString stringWithContentsOfFile:sVertexPath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    GLchar *sFragSource = (GLchar *)[[NSString stringWithContentsOfFile:sFragPath encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    mProgram = SKRenderingEngine::getInstance()->loadMainShader(sVertexSource, sFragSource);
}


- (void)drawRect:(NSRect)aDirtyRect
{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindBuffer(GL_ARRAY_BUFFER, mVBO);
    glBindVertexArray(mVAO);
    glEnableVertexAttribArray(0);
    SKRenderingEngine::getInstance()->useProgram(mProgram);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    [[self openGLContext] flushBuffer];
}


@end
