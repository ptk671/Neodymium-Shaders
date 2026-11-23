
#version 330 compatibility

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;
uniform float sunAngle;
uniform vec3 shadowLightPosition;

in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;
in vec3 normal;

/* RENDERTARGETS: 0,2 */
layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 directionalLightData;

// ======================================
// Lighting Configuration
// ======================================

// Ambient
const vec3 ambientColor = vec3(0.10, 0.10, 0.12);
const float ambientIntensity = 0.7;

// Sky Light Colors

//個人的な好みに変更済み(daySkyColor)
//元0.48, 0.62, 0.8
const vec3 daySkyColor = vec3(0.6078, 0.7098, 0.8471);
const vec3 nightSkyColor = vec3(0.16, 0.22, 0.38);
const vec3 twilightSkyColor = vec3(1.0, 0.55, 0.32);

// Sky Light Intensities
const float daySkyIntensity = 0.75;
const float nightSkyIntensity = 0.22;
const float twilightSkyIntensity = 0.58;

// Blocklight
const vec3 blockLightColor = vec3(1.0, 0.48, 0.16);
const float blockLightIntensity = 0.85;

// ======================================
// Main
// ======================================

void main() {

    // Material
    vec4 albedo = texture(gtexture, texcoord) * glcolor;

    if (albedo.a < alphaTestRef) {
        discard;
    }

    // ----------------------------------
    // Lightmap Separation
    // ----------------------------------

    float blockLevel = clamp(lmcoord.x, 0.0, 1.0);
    float skyLevel = clamp(lmcoord.y, 0.0, 1.0);

    // ----------------------------------
    // Ambient Lighting
    // ----------------------------------

    vec3 ambient = ambientColor * ambientIntensity;

    // ----------------------------------
    // Skylight
    // ----------------------------------

// Sun height
float sunHeight = sin(sunAngle * 6.2831853);

// Day / Night transition
float dayFactor = smoothstep(-0.15, 0.15, sunHeight);

// Twilight transition
float twilightFactor = 1.0 - smoothstep(0.0, 0.65, abs(sunHeight));

// Sky Light color
vec3 skyColor = mix(
    nightSkyColor,
    daySkyColor,
    dayFactor
);

skyColor = mix(
    skyColor,
    twilightSkyColor,
    twilightFactor * 0.65
);

// Sky Light intensity
float skyIntensity = mix(
    nightSkyIntensity,
    daySkyIntensity,
    dayFactor
);

skyIntensity = mix(
    skyIntensity,
    twilightSkyIntensity,
    twilightFactor * 0.65
);

// Final Sky Light
vec3 skyLight = skyColor * skyLevel * skyIntensity;

    // ----------------------------------
    // Blocklight
    // ----------------------------------

    vec3 blockLight =
        blockLightColor *
        blockLevel *
        blockLightIntensity;

    // ----------------------------------
    // Lighting Composition
    // ----------------------------------


// Normal
vec3 N = normalize(normal);

// Current main light direction
vec3 lightDir = normalize(shadowLightPosition);

// Directional diffuse
float directionalDiffuse = max(dot(N, lightDir), 0.0);

// Day / Night factors
float nightFactor = 1.0 - dayFactor;

// Directional light color
vec3 directionalColor = mix(
    vec3(1.0, 0.94, 0.82),
    vec3(0.30, 0.40, 0.65),
    nightFactor
);

// Directional light intensity
float directionalIntensity = mix(
    0.35,
    0.08,
    nightFactor
);

// Final directional light
vec3 directionalLight =
    directionalColor
    * directionalDiffuse
    * directionalIntensity
    * skyLevel;



vec3 totalLighting =
    ambient
    + skyLight
    + blockLight
    + directionalLight;

    // Final Color
    vec3 finalColor = albedo.rgb * totalLighting;

    fragColor = vec4(finalColor, albedo.a);

// Save directional lighting for shadow calculation
directionalLightData = vec4(directionalLight, 1.0);
}
