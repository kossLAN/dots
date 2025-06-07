#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
};

layout(binding = 1) uniform sampler2D fromImage;
layout(binding = 2) uniform sampler2D toImage;

void main() {
    vec2 uv = qt_TexCoord0;
    vec4 fromColor = texture(fromImage, uv);
    vec4 toColor = texture(toImage, uv);
    fragColor = mix(fromColor, toColor, progress) * qt_Opacity;
}
