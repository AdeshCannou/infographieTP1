#define PI   3.1415926535
#define TAU  (2.0*PI)

float sdRoundedBox( in vec2 p, in vec2 b, in vec4 r )
{
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}

float sdCircle( vec2 p, float r )
{
  return r-length(p);
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

vec3 hueToRGB(float hue){
    float red = 0.0;
    float green = 0.0;
    float blue = 0.0;
    if(hue >= 0.0 && hue < 60.0){
        red = 1.0;
        green = hue/60.0;
        blue = 0.0;
    }else if(hue >= 60.0 && hue < 120.0){
        red = 1.0 - (hue - 60.0)/60.0;
        green = 1.0;
        blue = 0.0;
    }else if(hue >= 120.0 && hue < 180.0){
        red = 0.0;
        green = 1.0;
        blue = (hue - 120.0)/60.0;
    }else if(hue >= 180.0 && hue < 240.0){
        red = 0.0;
        green = 1.0 - (hue - 180.0)/60.0;
        blue = 1.0;
    }else if(hue >= 240.0 && hue < 300.0){
        red = (hue - 240.0)/60.0;
        green = 0.0;
        blue = 1.0;
    }else if(hue >= 300.0 && hue <= 360.0){
        red = 1.0;
        green = 0.0;
        blue = 1.0 - (hue - 300.0)/60.0;
    }
    return vec3(red,green,blue);
}

float map(float value, float fromLow, float fromHigh, float toLow, float toHigh) {
    return toLow + (value - fromLow) * (toHigh - toLow) / (fromHigh - fromLow);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 backgroundColor = vec3(0.0, 0.0, 0.5);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = (2.0*fragCoord-iResolution.xy)/iResolution.y;
    vec2 q = p;

    // Position et taille du color picker
    vec2 colorPickerPos = vec2(0.0, 0.0);
    vec2 colorPickerSize = vec2(1.0, 0.1); 

    ///////// forme /////////

    // rectangle
    float d = sdBox( q + vec2(0.0,-0.06), vec2(2.0, 0.5) );

    // premier rectangle
    float d1 = sdRoundedBox( q+ vec2(0.0,-0.06), vec2(1.0, 0.4), vec4(0.1) );

    // 2eme rectangle inside
    float d2 = sdRoundedBox( q+ vec2(0.0,-0.06), vec2(0.8, 0.28), vec4(0.1) );

    // 1st color
    vec3 rectangleColor1 = vec3(0.8); 

    // 2nd color
    vec3 rectangleColor2 = vec3(0.2); 


    ////////// cercle /////////
    float cercle1 = sdCircle(p - vec2(0.65, 0.23), 0.05); 
    float cercle2 = sdCircle(p - vec2(0.7, 0.06), 0.05); 
    float cercle3 = sdCircle(p - vec2(0.65, -0.10), 0.05); 

    float cercle4 = sdCircle(p - vec2(-0.65, 0.23), 0.05); 
    float cercle5 = sdCircle(p - vec2(-0.7, 0.06), 0.05); 
    float cercle6 = sdCircle(p - vec2(-0.65, -0.10), 0.05); 

    float cercle7 = sdCircle(p - vec2(0, 0), 0.2);

    float cercle8 = sdCircle(p - vec2(0.17, 0.15), 0.09);

    vec3 circleColor = vec3(0.5);

    ////////// logo konoha /////////
    float theta = atan(p.y,p.x); // from -pi to pi
    float dist = distance(p, vec2(0.0)); 
    
    vec3 col = vec3(0.8);
    if (mod(theta + pow(dist + 4.9, 1.7)*11. + 6.4, TAU) < 0.99)
        col *= 0.0;

    float segment = sdSegment(p, vec2(-0.25, -0.13), vec2(-0.17, 0.015));
    segment = min(segment, sdSegment(p, vec2(-0.23, -0.13), vec2(0., -0.13)));
    segment = min(segment, sdSegment(p, vec2(0.07, 0.175), vec2(0.15, 0.25)));
    
    
    // affichage
    vec3 finalColor = mix(rectangleColor1, rectangleColor2, smoothstep(0.0, 0.01, d2));
    finalColor = mix(finalColor, backgroundColor, smoothstep(0.0, 0.01, d1));

    // gere le fonctionnement du color picker
    if (iMouse.x > colorPickerPos.x * iResolution.x && iMouse.x < (colorPickerPos.x + colorPickerSize.x) * iResolution.x &&
    iMouse.y > colorPickerPos.y * iResolution.y && iMouse.y < (colorPickerPos.y + colorPickerSize.y) * iResolution.y) {
    
        float hue = map(iMouse.x / iResolution.x, colorPickerPos.x, colorPickerPos.x + colorPickerSize.x, 0.0, 360.0);
        backgroundColor = hueToRGB(hue);

    }
    
    finalColor = mix(finalColor, backgroundColor, smoothstep(0.0, 0.01, d1));
 
    finalColor = mix(finalColor, circleColor, smoothstep(0.0, 0.01, cercle1));
    finalColor = mix(finalColor, circleColor, smoothstep(0.0, 0.01, cercle2));
    finalColor = mix(finalColor, circleColor, smoothstep(0.0, 0.01, cercle3));

    finalColor = mix(finalColor, circleColor, smoothstep(0.0, 0.01, cercle4));
    finalColor = mix(finalColor, circleColor, smoothstep(0.0, 0.01, cercle5));
    finalColor = mix(finalColor, circleColor, smoothstep(0.0, 0.01, cercle6));

    finalColor = mix(finalColor, col, smoothstep(0.0, 0.01, cercle7));
    finalColor = mix(finalColor, rectangleColor1, smoothstep(0.0, 0.01, cercle8));
    finalColor = mix(finalColor, vec3(1.0), smoothstep(0.0, 0.01, d));

    
    fragColor = vec4(segment > 0.010 ? finalColor : vec3(0.0), 1.0);
    

    // color picker
    vec2 uv = fragCoord.xy / iResolution.xy;

    float hue2 = fract(uv.x); 

    float barHeight = 0.1; 

    float barY = 0.0; 
    float barBottom = barY + barHeight;

    if (uv.y >= barY && uv.y <= barBottom) {
        vec3 rgbColor = hsv2rgb(vec3(hue2, 1.0, 1.0));
        fragColor = vec4(rgbColor, 1.0);
    }
    
    
}
