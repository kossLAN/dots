#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    float angle;
};

layout(binding = 1) uniform sampler2D fromImage;
layout(binding = 2) uniform sampler2D toImage;

void main() {
    vec2 uv = qt_TexCoord0;
    
    // Create directional wipe based on angle
    float rad = angle * 3.14159265 / 180.0;
    vec2 dir = vec2(cos(rad), sin(rad));
    
    // Project UV onto direction vector
    float proj = dot(uv - vec2(0.5), dir) + 0.5;
    
    // Soft edge wipe
    float edge = 0.1;
    float t = smoothstep(progress - edge, progress + edge, proj);
    
    vec4 fromColor = texture(fromImage, uv);
    vec4 toColor = texture(toImage, uv);
    
    fragColor = mix(toColor, fromColor, t) * qt_Opacity;
}
