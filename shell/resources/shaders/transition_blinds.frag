#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    float count;
};

layout(binding = 1) uniform sampler2D fromImage;
layout(binding = 2) uniform sampler2D toImage;

void main() {
    vec2 uv = qt_TexCoord0;
    
    // Create horizontal blinds
    float blindIndex = floor(uv.y * count);
    float blindPos = fract(uv.y * count);
    
    // Stagger the blinds slightly for a wave effect
    float stagger = blindIndex / count * 0.3;
    float adjustedProgress = clamp((progress - stagger) / (1.0 - 0.3), 0.0, 1.0);
    
    // Each blind reveals from top to bottom
    float reveal = smoothstep(0.0, 1.0, adjustedProgress);
    
    vec4 fromColor = texture(fromImage, uv);
    vec4 toColor = texture(toImage, uv);
    
    // Reveal new image as blind opens
    float t = step(blindPos, reveal);
    fragColor = mix(fromColor, toColor, t) * qt_Opacity;
}
