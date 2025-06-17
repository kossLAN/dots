#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D mask;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
};

void main() {
    vec4 sourceColor = texture(source, qt_TexCoord0);
    vec4 maskColor = texture(mask, qt_TexCoord0);

    // Use the mask's luminance to determine opacity
    float maskValue = dot(maskColor.rgb, vec3(0.299, 0.587, 0.114));

    // Black areas of mask = transparent, white areas = opaque
    sourceColor.a *= (1.0 - maskValue) * qt_Opacity;

    fragColor = sourceColor;
}
