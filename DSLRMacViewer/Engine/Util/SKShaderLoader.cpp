//
//  SKShaderLoader.cpp
//  DSLRMacViewer
//
//  Created by hsg2510 on 2018. 12. 4..
//  Copyright © 2018년 hsg2510. All rights reserved.
//

#include "SKShaderLoader.hpp"

#include <iostream>

using namespace std;
using namespace CP;

static SKShaderLoader *mLoaderInstance = nullptr;


#pragma mark - init


SKShaderLoader* SKShaderLoader::getInstance()
{
    if (mLoaderInstance == nullptr)
    {
        mLoaderInstance = new SKShaderLoader();
    }
    
    return mLoaderInstance;
}

SKShaderLoader::SKShaderLoader()
{
    
}


#pragma mark - public


bool SKShaderLoader::compileShader(GLuint aProgram, GLuint *aShader, GLenum aType, const GLchar *aSource)
{
    GLint sStatus;
    
    if (!aSource)
    {
        cout << "Shader Source is Null!!" << endl;
        
        return false;
    }
    
    *aShader = glCreateShader(aType);
    glShaderSource(*aShader, 1, &aSource, NULL);
    glCompileShader(*aShader);
    
    //TODO : DEBUG define 설정하기.
#if defined(DEBUG)
    GLint sLogLength;
    glGetShaderiv(*aShader, GL_INFO_LOG_LENGTH, &sLogLength);
    
    if (sLogLength > 0)
    {
        GLchar *sLog = (GLchar *)malloc(sLogLength);
        glGetShaderInfoLog(*aShader, sLogLength, &sLogLength, sLog);
        
        cout << "Shader compile log:" << endl;
        cout << sLog << endl;
        
        free(sLog);
    }
#endif
    
    glGetShaderiv(*aShader, GL_COMPILE_STATUS, &sStatus);
    
    if (sStatus == 0)
    {
        glDeleteShader(*aShader);
        
        return false;
    }
    
    glAttachShader(aProgram, *aShader);
    
    return true;
}


bool SKShaderLoader::linkProgram(GLuint aProgram)
{
    GLint sStatus;
    glLinkProgram(aProgram);
    
    //TODO : DEBUG Define 설정하기
#if defined(DEBUG)
    GLint sLogLength;
    glGetProgramiv(aProgram, GL_INFO_LOG_LENGTH, &sLogLength);
    
    if (sLogLength > 0)
    {
        GLchar *sLog = (GLchar *)malloc(sLogLength);
        glGetProgramInfoLog(aProgram, sLogLength, &sLogLength, sLog);
        
        cout << "Program link log:" << endl;
        cout << sLog << endl;
        
        free(sLog);
    }
#endif
    
    glGetProgramiv(aProgram, GL_LINK_STATUS, &sStatus);
    
    if (sStatus == 0)
    {
        return false;
    }
    
    return true;
}


bool SKShaderLoader::validataProgram(GLuint aProgram)
{
    GLint sLogLength;
    GLint sStatus;
    
    glValidateProgram(aProgram);
    glGetProgramiv(aProgram, GL_INFO_LOG_LENGTH, &sLogLength);
    
    if (sLogLength > 0)
    {
        GLchar *sLog = (GLchar *)malloc(sLogLength);
        glGetProgramInfoLog(aProgram, sLogLength, &sLogLength, sLog);
        
        cout << "Program validate log:" << endl;
        cout << sLog << endl;
        
        free(sLog);
    }
    
    glGetProgramiv(aProgram, GL_VALIDATE_STATUS, &sStatus);
    
    if (sStatus == 0)
    {
        return false;
    }
    
    return true;
}

