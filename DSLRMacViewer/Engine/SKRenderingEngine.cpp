//
//  SKRenderingEngine.cpp
//  DSLRMacViewer
//
//  Created by hsg2510 on 2018. 12. 4..
//  Copyright © 2018년 hsg2510. All rights reserved.
//

#include "SKRenderingEngine.hpp"
#include "SKShaderLoader.hpp"
#include <iostream>

using namespace CP;
using namespace std;


static SKRenderingEngine *mEngineInstance = nullptr;


#pragma mark - init


SKRenderingEngine* SKRenderingEngine::getInstance()
{
    if (mEngineInstance == nullptr)
    {
        mEngineInstance = new SKRenderingEngine();
    }
    
    return mEngineInstance;
}

SKRenderingEngine::SKRenderingEngine()
{
    mMainVertexShader = 0;
    mMainFragShader = 0;
}


#pragma mark - public


GLuint SKRenderingEngine::loadMainShader(GLchar *aVertexSource, GLchar *aFragSource)
{
    GLuint sProgram = glCreateProgram();
    
    SKShaderLoader::getInstance()->compileShader(sProgram, &mMainVertexShader, GL_VERTEX_SHADER, aVertexSource);
    SKShaderLoader::getInstance()->compileShader(sProgram, &mMainFragShader, GL_FRAGMENT_SHADER, aFragSource);
    
    if (!SKShaderLoader::getInstance()->linkProgram(sProgram))
    {
        cout << "Failed to link program :" << endl;
        cout << sProgram << endl;
        
        if (mMainVertexShader)
        {
            glDeleteShader(mMainVertexShader);
            mMainVertexShader = 0;
        }
        
        if (mMainFragShader)
        {
            glDeleteShader(mMainFragShader);
            mMainFragShader = 0;
        }
        
        if (sProgram)
        {
            glDeleteProgram(sProgram);
        }
        
        return -1;
    }
    
    // Release vertex and fragment shaders.
    if (mMainVertexShader)
    {
        glDetachShader(sProgram, mMainVertexShader);
        glDeleteShader(mMainVertexShader);
    }
    
    if (mMainFragShader)
    {
        glDetachShader(sProgram, mMainFragShader);
        glDeleteShader(mMainFragShader);
    }
    
    return sProgram;
}

void SKRenderingEngine::useProgram(GLuint aProgram)
{
    glUseProgram(aProgram);
}
