const int shadowMapResolution = 1024;
const bool shadowtex0Nearest = true;

vec3 distortShadowClipPos(vec3 shadowClipPos) {

    float distortionFactor = length(shadowClipPos.xy);
    distortionFactor += 0.1;

    shadowClipPos.xy /= distortionFactor;

    // Z方向の影描画範囲を拡張
    shadowClipPos.z *= 0.5;

    return shadowClipPos;
}