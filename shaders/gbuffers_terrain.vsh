
#version 330 compatibility

out vec2 texcoord;
out vec2 lmcoord;
out vec4 glcolor;
out vec3 normal;

void main() {
    // Vertex position
    gl_Position = ftransform();

    // Texture coordinates
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    // Lightmap coordinates
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    // Normalize lightmap coordinates to approximately 0-1
    lmcoord = lmcoord / (30.0 / 32.0) - (1.0 / 32.0);

    // Vertex color
    glcolor = gl_Color;

    // View Space normal
    normal = normalize(gl_NormalMatrix * gl_Normal);
}
