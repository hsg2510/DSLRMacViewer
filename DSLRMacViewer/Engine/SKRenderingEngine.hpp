//
//  SKRenderingEngine.hpp
//  DSLRMacViewer
//
//  Created by hsg2510 on 2018. 12. 4..
//  Copyright © 2018년 hsg2510. All rights reserved.
//

#ifndef SKRenderingEngine_hpp
#define SKRenderingEngine_hpp

#include <stdio.h>
#include <OpenGL/gl3.h>

namespace CP {
    using namespace CP;
    
    class SKRenderingEngine
    {
    public:
        static SKRenderingEngine* getInstance();
        SKRenderingEngine();
        
        GLuint loadMainShader(GLchar *aVertexSource, GLchar *aFragSource);
        void useProgram(GLuint aProgram);
        void setupMainUniforms();
        
        enum Usage
        {
            POSITION = 1,
            NORMAL = 2,
            COLOR = 3,
            TANGENT = 4,
            BINORMAL = 5,
            BLENDWEIGHTS = 6,
            BLENDINDICES = 7,
            TEXCOORD0 = 8,
            TEXCOORD1 = 9,
            TEXCOORD2 = 10,
            TEXCOORD3 = 11,
            TEXCOORD4 = 12,
            TEXCOORD5 = 13,
            TEXCOORD6 = 14,
            TEXCOORD7 = 15
        };
        
        enum MainUniform
        {
            MAIN_TEXTURE,
            NUM_UNIFORMS
        };
        
    private:
        GLuint mMainVertexShader;
        GLuint mMainFragShader;
        GLint mMainUniforms[NUM_UNIFORMS];
    };
}


#endif /* SKRenderingEngine_hpp */

