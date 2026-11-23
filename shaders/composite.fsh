
#version 330 compatibility
#include "/lib/distort.glsl"
// Textures
uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;

// Matrices
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
// Shadow Bias
const float shadowBias = 0.002;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

// Projection helper
vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
    vec4 homPos = projectionMatrix * vec4(position, 1.0);
    return homPos.xyz / homPos.w;
}

// Shadow calculation
float getShadow(vec3 screenPos) {

    if (
        screenPos.x < 0.0 || screenPos.x > 1.0 ||
        screenPos.y < 0.0 || screenPos.y > 1.0 ||
        screenPos.z < 0.0 || screenPos.z > 1.0
    ) {
        return 1.0;
    }

    float shadowDepth = texture(
        shadowtex0,
        screenPos.xy
    ).r;

    return step(screenPos.z, shadowDepth);
}





// PCF Soft Shadow
float getSoftShadow(vec3 screenPos) {
    float shadowAccum = 0.0;

    const float weights[9] = float[](
        1.0, 2.0, 1.0,
        2.0, 4.0, 2.0,
        1.0, 2.0, 1.0
    );

    int index = 0;

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y))
                / float(shadowMapResolution);

            vec3 samplePos = screenPos;
            samplePos.xy += offset;

            shadowAccum += getShadow(samplePos) * weights[index];
            index++;
        }
    }

    return shadowAccum / 16.0;
}


void main() {

    // Original scene color
    vec4 sceneColor = texture(colortex0, texcoord);

    // Directional lighting contribution
    vec3 directionalLight = texture(
        colortex2,
        texcoord
    ).rgb;

    // Preserve sky pixels
    float depth = texture(depthtex0, texcoord).r;

    if (depth >= 1.0) {
        color = sceneColor;
        return;
    }

    // Screen space -> NDC
    vec3 ndcPos = vec3(texcoord, depth) * 2.0 - 1.0;

    // NDC -> View space
    vec3 viewPos = projectAndDivide(
        gbufferProjectionInverse,
        ndcPos
    );

    // View space -> Player space
    vec3 playerPos = (
        gbufferModelViewInverse *
        vec4(viewPos, 1.0)
    ).xyz;

    // Player space -> Shadow view space
    vec3 shadowViewPos = (
        shadowModelView *
        vec4(playerPos, 1.0)
    ).xyz;

    // Shadow view -> Shadow clip
    vec4 shadowClipPos = (
        shadowProjection *
        vec4(shadowViewPos, 1.0)
    );

    // Shadow bias
    shadowClipPos.z -= shadowBias;

// Shadow distortion
shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz);

    // Clip -> NDC
    vec3 shadowNDC = (
        shadowClipPos.xyz /
        shadowClipPos.w
    );

    // NDC -> Texture coordinates
    vec3 shadowScreenPos = shadowNDC * 0.5 + 0.5;

    // Shadow visibility
   float shadow = getSoftShadow(shadowScreenPos);

    // Apply shadow only to directional lighting
    vec3 finalColor =
        sceneColor.rgb
        - directionalLight
        + directionalLight * shadow;

    color = vec4(
        max(finalColor, vec3(0.0)),
        sceneColor.a
    );
}
