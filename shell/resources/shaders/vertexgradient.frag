#version 440

layout(location = 0) in vec2 coord;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    vec4 topLeftColor;
    vec4 topCenterColor;
    vec4 topRightColor;
    vec4 middleLeftColor;
    vec4 middleRightColor;
    vec4 bottomLeftColor;
    vec4 bottomCenterColor;
    vec4 bottomRightColor;
} ubuf;

void main() {
    // Scattered color point positions
    vec2 p0 = vec2(0.05, 0.1);   // topLeft
    vec2 p1 = vec2(0.55, 0.05);  // topCenter
    vec2 p2 = vec2(0.9, 0.15);   // topRight
    vec2 p3 = vec2(0.1, 0.45);   // middleLeft
    vec2 p4 = vec2(0.85, 0.55);  // middleRight
    vec2 p5 = vec2(0.08, 0.9);   // bottomLeft
    vec2 p6 = vec2(0.5, 0.85);   // bottomCenter
    vec2 p7 = vec2(0.95, 0.92);  // bottomRight

    // Calculate inverse distance weights
    float d0 = 1.0 / (distance(coord, p0) + 0.001);
    float d1 = 1.0 / (distance(coord, p1) + 0.001);
    float d2 = 1.0 / (distance(coord, p2) + 0.001);
    float d3 = 1.0 / (distance(coord, p3) + 0.001);
    float d4 = 1.0 / (distance(coord, p4) + 0.001);
    float d5 = 1.0 / (distance(coord, p5) + 0.001);
    float d6 = 1.0 / (distance(coord, p6) + 0.001);
    float d7 = 1.0 / (distance(coord, p7) + 0.001);

    // Power for sharper/softer falloff
    float power = 2.5;
    d0 = pow(d0, power);
    d1 = pow(d1, power);
    d2 = pow(d2, power);
    d3 = pow(d3, power);
    d4 = pow(d4, power);
    d5 = pow(d5, power);
    d6 = pow(d6, power);
    d7 = pow(d7, power);

    float totalWeight = d0 + d1 + d2 + d3 + d4 + d5 + d6 + d7;

    // Weighted blend of all colors
    fragColor = (
        ubuf.topLeftColor * d0 +
        ubuf.topCenterColor * d1 +
        ubuf.topRightColor * d2 +
        ubuf.middleLeftColor * d3 +
        ubuf.middleRightColor * d4 +
        ubuf.bottomLeftColor * d5 +
        ubuf.bottomCenterColor * d6 +
        ubuf.bottomRightColor * d7
    ) / totalWeight;
}
