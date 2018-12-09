//
//  Shader.vsh
//  
//


attribute vec4 a_position;
attribute vec2 a_texCoord;

varying lowp vec2 v_texCoord;

void main()
{
    v_texCoord = aTexCoord;
   gl_Position = a_position;
}
