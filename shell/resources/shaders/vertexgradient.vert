#version 440

layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;

layout(location = 0) out vec2 coord;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    vec4 topLeftColor;
    vec4 topCenterColor;
    vec4 topRightColor;
    vec4 middleLeftColor;
    vec4 middleRightColor;
    vec4 bottomLeftColor;
    vec4 bottomCenterColor;
    vec4 bottomRightColor;
} ubuf;

out gl_PerVertex { vec4 gl_Position; };

void main() {
    coord = qt_MultiTexCoord0;
    gl_Position = ubuf.qt_Matrix * qt_Vertex;
}
