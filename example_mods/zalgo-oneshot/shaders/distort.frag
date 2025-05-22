// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D

uniform float amp;

// end of ShadertoyToFlixel header


vec2 uvp(vec2 uv) {
	return clamp(uv, 0.0, 1.0);
}

float outCirc(float t) {
    return sqrt(-t * t + 2.0 * t);
}

float rand(vec2 co) {
	return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 col;
    
    //amp *= 0.5;
    
    for (int i = 0; i < 3; i++) {
    	vec2 uv = fragCoord / iResolution.xy;
        uv += vec2(sin(iTime + float(i) + amp), cos(iTime + float(i) + amp)) * amp * 0.2;
        vec3 texOrig = texture(iChannel0, uvp(uv)).rgb;
        
        uv.x += (rand(vec2(uv.y + float(i), iTime)) * 2.0 - 1.0) * amp * 0.8 * (texOrig[i] + 0.2);
        uv.y += (rand(vec2(uv.x, iTime + float(i))) * 2.0 - 1.0) * amp * 0.1 * (texOrig[i] + 0.2);
        
        vec3 tex = texture(iChannel0, uvp(uv)).rgb;
        
        //tex += (rand(uv + iTime + float(i)) * 2.0 - 1.0) * amp * 0.1;
        //tex += (rand(uv + iTime + tex[i] + float(i)) * 2.0 - 1.0) * amp * 0.2;
        //tex += mix(1.0, rand(uv + tex[i] + float(i) * 253.6 + iTime) * tex.r * 5.0, amp);
        tex += abs(tex[i] - texOrig[i]);
        
        tex *= rand(uv) * amp + 1.0;
    
        
        col[i] = tex[i];
    }
    
    fragColor = vec4(col, texture(iChannel0, fragCoord / iResolution.xy).a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}