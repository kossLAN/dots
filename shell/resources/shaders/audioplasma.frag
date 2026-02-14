#version 440

layout(location = 0) in vec2 coord;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    vec4 color0;      // background colors
    vec4 color1;
    vec4 color2;
    vec4 color3;
    vec4 waveColor;   // dedicated wave color
    vec4 params;      // x = time, y = unused, z = unused, w = unused
    vec4 bars0;       // bars 0-3 (low frequencies)
    vec4 bars1;       // bars 4-7
    vec4 bars2;       // bars 8-11 (mid frequencies)
    vec4 bars3;       // bars 12-15
    vec4 bars4;       // bars 16-19 (high frequencies)
} ubuf;

float getBarValue(int index) {
    int group = index / 4;
    int comp = index - group * 4;

    vec4 bar;
    if (group == 0) bar = ubuf.bars0;
    else if (group == 1) bar = ubuf.bars1;
    else if (group == 2) bar = ubuf.bars2;
    else if (group == 3) bar = ubuf.bars3;
    else bar = ubuf.bars4;

    return bar[comp];
}

float avgBars(int from, int to) {
    float sum = 0.0;
    for (int i = from; i <= to; i++)
        sum += getBarValue(i);
    return sum / float(to - from + 1);
}

// Sample bar values with interpolation at position x (0-1)
float sampleBars(float x) {
    float idx = x * 19.0;
    int i0 = int(floor(idx));
    int i1 = int(min(float(i0 + 1), 19.0));
    float frac = fract(idx);
    
    float v0 = getBarValue(i0);
    float v1 = getBarValue(i1);
    
    // Smooth interpolation
    float t = frac * frac * (3.0 - 2.0 * frac);
    return mix(v0, v1, t);
}

void main() {
    float t = ubuf.params.x;
    float pi2 = 6.28318;
    
    vec2 uv = coord;
    
    // Sample frequency bands for wave modulation
    float lowFreq = avgBars(0, 5);
    float midFreq = avgBars(6, 11);
    float highFreq = avgBars(12, 19);
    
    // Overall peak for base height
    float peak = max(max(lowFreq, midFreq), highFreq);
    
    // Base height from peak
    float baseHeight = 0.08 + peak * 0.5;
    
    // Sample bar values at current x position for local wave height variation
    float localBar = sampleBars(uv.x);
    
    // Multiple wave layers with different frequencies and phases
    // Now modulated by the frequency bands
    float wave = 0.0;
    
    // Low freq foundation wave - modulated by bass
    float lowAmp = 0.3 + lowFreq * 0.7;
    wave += sin(uv.x * 6.0 + t * pi2 * 1.2) * 0.5 * lowAmp;
    
    // Mid freq waves with amplitude modulation from mids
    float midAmp = 0.2 + midFreq * 0.8;
    float ampMod1 = 0.2 + 0.8 * sin(uv.x * 2.5 + t * pi2 * 0.4);
    wave += sin(uv.x * 15.0 + t * pi2 * 2.0) * 0.4 * ampMod1 * midAmp;
    
    float ampMod2 = 0.1 + 0.9 * cos(uv.x * 4.0 - t * pi2 * 0.6);
    wave += sin(uv.x * 23.0 - t * pi2 * 2.5 + 1.0) * 0.35 * ampMod2 * midAmp;
    
    // High freq detail - modulated by treble
    float highAmp = 0.2 + highFreq * 0.8;
    float ampMod3 = 0.2 + 0.8 * sin(uv.x * 6.0 + t * pi2 * 0.3);
    wave += sin(uv.x * 37.0 + t * pi2 * 3.5 + 2.0) * 0.25 * ampMod3 * highAmp;
    
    // Extra low freq for big sweeping height changes
    wave += sin(uv.x * 3.0 - t * pi2 * 0.8) * 0.45 * lowAmp;
    
    // Add local bar influence for position-specific reactivity
    wave += (localBar - 0.5) * 0.4;
    
    // Normalize to 0-1 range with more variation
    wave = wave * 0.35 + 0.5;
    wave = clamp(wave, 0.1, 1.0);
    float waveHeight = baseHeight * wave;
    
    // Distance from bottom
    float fromBottom = 1.0 - uv.y;
    
    // Wave edge
    float inWave = smoothstep(waveHeight, waveHeight - 0.02, fromBottom);
    
    // Subtle glow effect above wave
    float glow = smoothstep(waveHeight + 0.1, waveHeight, fromBottom) * 0.2;
    
    // Gradient within the wave (slightly brighter at top)
    float waveGradient = 1.0 - (fromBottom / max(waveHeight, 0.01));
    waveGradient = clamp(waveGradient, 0.0, 1.0);
    waveGradient = pow(waveGradient, 0.8);
    
    // Base background
    vec4 bgColor = mix(
        mix(ubuf.color0, ubuf.color1, uv.x),
        mix(ubuf.color2, ubuf.color3, uv.x),
        uv.y
    );
    
    // Wave color - translucent wave with subtle top highlight
    vec4 wavCol = vec4(ubuf.waveColor.rgb * 0.8, 0.7);
    wavCol.rgb = mix(wavCol.rgb, ubuf.waveColor.rgb, waveGradient * 0.3);
    
    // Apply subtle glow to background (keep opaque)
    vec3 glowCol = mix(bgColor.rgb, ubuf.waveColor.rgb * 0.35, glow);
    
    // Start with opaque background
    vec4 col = vec4(glowCol, 1.0);
    
    // Blend translucent wave on top
    col.rgb = mix(col.rgb, wavCol.rgb, inWave * wavCol.a);
    
    fragColor = col;
}
