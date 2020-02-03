

attribute vec4 aPos;
attribute vec2 aTexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

varying lowp vec2 v_texCoord;

void main()
{
    gl_Position = projection * view * model * vec4(aPos, 1.0f);
    v_texCoord = vec2(aTexCoord.x, 1.0 - aTexCoord.y);
}
