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
    
    // Pixelate effect: larger pixels in the middle of transition
    float pixelPhase = 1.0 - abs(2.0 * progress - 1.0); // 0 -> 1 -> 0
    float minPixels = 1.0;
    float maxPixels = 80.0;
    float pixels = mix(minPixels, maxPixels, pixelPhase * pixelPhase);
    
    vec2 pixelatedUV = floor(uv * pixels) / pixels;
    
    vec4 fromColor = texture(fromImage, pixelatedUV);
    vec4 toColor = texture(toImage, pixelatedUV);
    
    // Smooth transition between images
    float t = smoothstep(0.0, 1.0, progress);
    fragColor = mix(fromColor, toColor, t) * qt_Opacity;
}
