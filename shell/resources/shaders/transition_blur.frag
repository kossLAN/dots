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

vec4 blur(sampler2D tex, vec2 uv, float amount) {
    vec4 color = vec4(0.0);
    float total = 0.0;
    
    // 9-tap gaussian blur
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            float weight = exp(-(x*x + y*y) / 4.0);
            vec2 offset = vec2(x, y) * amount * 0.01;
            color += texture(tex, uv + offset) * weight;
            total += weight;
        }
    }
    
    return color / total;
}

void main() {
    vec2 uv = qt_TexCoord0;
    
    // Blur peaks at middle of transition
    float blurAmount = sin(progress * 3.14159265) * 3.0;
    
    vec4 fromColor = blur(fromImage, uv, blurAmount);
    vec4 toColor = blur(toImage, uv, blurAmount);
    
    // Crossfade
    float t = smoothstep(0.0, 1.0, progress);
    fragColor = mix(fromColor, toColor, t) * qt_Opacity;
}
