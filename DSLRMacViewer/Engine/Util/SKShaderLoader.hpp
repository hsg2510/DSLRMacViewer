//
//  SKShaderLoader.hpp
//  DSLRMacViewer
//
//  Created by hsg2510 on 2018. 12. 4..
//  Copyright © 2018년 hsg2510. All rights reserved.
//

#ifndef SKShaderLoader_hpp
#define SKShaderLoader_hpp

#include <stdio.h>
#include <OpenGL/gl3.h>


namespace CP {
    using namespace CP;
    
    class SKShaderLoader
    {
    public:
        static SKShaderLoader* getInstance();
        SKShaderLoader();
        bool compileShader(GLuint aProgram, GLuint *aShader, GLenum aType, const GLchar *aSource);
        bool linkProgram(GLuint aProgram);
        bool validataProgram(GLuint aPragram);
    };
}

#endif /* SKShaderLoader_hpp */

