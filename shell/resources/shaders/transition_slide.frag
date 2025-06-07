#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    float direction; // 0=left, 1=right, 2=up, 3=down
};

layout(binding = 1) uniform sampler2D fromImage;
layout(binding = 2) uniform sampler2D toImage;

void main() {
    vec2 uv = qt_TexCoord0;
    
    vec2 offset;
    if (direction < 0.5) {
        offset = vec2(progress, 0.0); // slide left
    } else if (direction < 1.5) {
        offset = vec2(-progress, 0.0); // slide right
    } else if (direction < 2.5) {
        offset = vec2(0.0, progress); // slide up
    } else {
        offset = vec2(0.0, -progress); // slide down
    }
    
    vec2 fromUV = uv + offset;
    vec2 toUV = uv + offset - sign(offset);
    
    bool showTo;
    if (direction < 0.5) {
        showTo = uv.x < progress;
    } else if (direction < 1.5) {
        showTo = uv.x > 1.0 - progress;
    } else if (direction < 2.5) {
        showTo = uv.y < progress;
    } else {
        showTo = uv.y > 1.0 - progress;
    }
    
    if (showTo) {
        fragColor = texture(toImage, toUV + sign(offset)) * qt_Opacity;
    } else {
        fragColor = texture(fromImage, uv) * qt_Opacity;
    }
}
