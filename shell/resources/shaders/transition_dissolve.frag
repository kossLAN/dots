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

// Simple hash function for noise
float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void main() {
    vec2 uv = qt_TexCoord0;
    
    // Generate noise pattern
    float noise = hash(floor(uv * 100.0));
    
    // Add some variation with different scales
    noise = noise * 0.6 + hash(floor(uv * 50.0)) * 0.3 + hash(floor(uv * 200.0)) * 0.1;
    
    vec4 fromColor = texture(fromImage, uv);
    vec4 toColor = texture(toImage, uv);
    
    // Dissolve based on noise threshold
    float threshold = progress * 1.2; // Slightly over 1.0 to ensure full transition
    float edge = smoothstep(threshold - 0.1, threshold, noise);
    
    fragColor = mix(toColor, fromColor, edge) * qt_Opacity;
}
