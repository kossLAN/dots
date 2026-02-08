#version 440

layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;

layout(location = 0) out vec2 coord;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    vec4 color0;
    vec4 color1;
    vec4 color2;
    vec4 color3;
    vec4 waveColor;
    vec4 params;
    vec4 bars0;       // bars 0-3
    vec4 bars1;       // bars 4-7
    vec4 bars2;       // bars 8-11
    vec4 bars3;       // bars 12-15
    vec4 bars4;       // bars 16-19
} ubuf;

out gl_PerVertex { vec4 gl_Position; };

void main() {
    coord = qt_MultiTexCoord0;
    gl_Position = ubuf.qt_Matrix * qt_Vertex;
}
