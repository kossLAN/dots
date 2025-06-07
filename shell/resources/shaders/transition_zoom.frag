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
    vec2 center = vec2(0.5);
    
    // Old image zooms in and fades out
    float fromScale = 1.0 + progress * 0.3;
    vec2 fromUV = (uv - center) / fromScale + center;
    
    // New image starts zoomed out and scales to normal
    float toScale = 1.0 - (1.0 - progress) * 0.3;
    vec2 toUV = (uv - center) / toScale + center;
    
    vec4 fromColor = texture(fromImage, fromUV);
    vec4 toColor = texture(toImage, toUV);
    
    // Fade old out, new in
    float t = smoothstep(0.0, 1.0, progress);
    fromColor.a *= 1.0 - t;
    toColor.a *= t;
    
    fragColor = mix(fromColor, toColor, t) * qt_Opacity;
}
