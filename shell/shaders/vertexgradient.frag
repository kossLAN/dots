#version 440

layout(location = 0) in vec2 coord;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    vec4 topLeftColor;
    vec4 topRightColor;
    vec4 bottomLeftColor;
    vec4 bottomRightColor;
} ubuf;

void main() {
    vec4 topColor = mix(ubuf.topLeftColor, ubuf.topRightColor, coord.x);
    vec4 bottomColor = mix(ubuf.bottomLeftColor, ubuf.bottomRightColor, coord.x);
    fragColor = mix(topColor, bottomColor, coord.y);
}
