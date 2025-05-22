#pragma header
vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

uniform float pixelSize;

void mainImage()
{
    vec2 screenRes = vec2(pixelSize, pixelSize);
    
    vec2 iPixelSize = vec2(1., 1.)/screenRes;
    
    vec2 uv = fragCoord/iResolution.xy;

    vec2 iPixelateRes = iResolution.xy * iPixelSize;

    vec2 sampleUV = floor(uv / iPixelSize) * iPixelSize;
    vec4 col = texture(iChannel0, sampleUV);

    fragColor = col;
}