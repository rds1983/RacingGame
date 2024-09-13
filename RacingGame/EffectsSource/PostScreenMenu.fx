#include "Macros.fxh"

string description =
"Post screen shader for the menu in RacingGame with glow and various screen effects";

// Glow/bloom with menu effects, adjusted for RacingGameManager.
// Based on PostScreenGlow.fx

// This script is only used for FX Composer, most values here
// are treated as constants by the application anyway.
// Values starting with an upper letter are constants.
float Script = 0.5;

const float DownsampleMultiplicator = 0.25f;
const float4 ClearColor : DIFFUSE = { 0.0f, 0.0f, 0.0f, 1.0f};
const float ClearDepth = 1.0f;

float GlowIntensity = 0.25f;

float HighlightThreshold = 0.925f;
float HighlightIntensity = 0.145f;
float BlurWidth = 4.0f;

// Render-to-Texture stuff
float2 windowSize;
const float downsampleScale = 0.25;
float Timer;
float Speed = 0.0032f;
float Speed2 = 0.0016f;
float ScratchIntensity = 0.605f;
float IS = 0.031f;

texture sceneMap;
sampler sceneMapSampler = sampler_state 
{
    texture = <sceneMap>;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
    AddressW  = CLAMP;
    MIPFILTER = NONE;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

texture downsampleMap;
sampler downsampleMapSampler = sampler_state 
{
    texture = <downsampleMap>;
    AddressU  = CLAMP;        
    AddressV  = CLAMP;
    AddressW  = CLAMP;
    MIPFILTER = NONE;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

texture blurMap1;
sampler blurMap1Sampler = sampler_state 
{
    texture = <blurMap1>;
    AddressU  = CLAMP;        
    AddressV  = CLAMP;
    AddressW  = CLAMP;
    MIPFILTER = NONE;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

texture blurMap2;
sampler blurMap2Sampler = sampler_state 
{
    texture = <blurMap2>;
    AddressU  = CLAMP;        
    AddressV  = CLAMP;
    AddressW  = CLAMP;
    MIPFILTER = NONE;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

texture noiseMap;
sampler noiseMapSampler = sampler_state 
{
    texture = <noiseMap>;
    AddressU  = WRAP;        
    AddressV  = WRAP;
    AddressW  = WRAP;
    MIPFILTER = LINEAR;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

// Returns luminance value of col to convert color to grayscale
float Luminance(float3 col)
{
    return dot(col, float3(0.3, 0.59, 0.11));
}

struct VB_OutputPosTexCoord
{
       float4 pos      : POSITION;
    float2 texCoord : TEXCOORD0;
};

struct VB_OutputPos2TexCoords
{
       float4 pos         : POSITION;
    float2 texCoord[2] : TEXCOORD0;
};

struct VB_OutputPos3TexCoords
{
       float4 pos         : POSITION;
    float2 texCoord[3] : TEXCOORD0;
};

struct VB_OutputPos4TexCoords
{
       float4 pos         : POSITION;
    float2 texCoord[4] : TEXCOORD0;
};

struct VB_OutputPos3TexCoordsWithColor
{
       float4 pos         : POSITION;
    float2 texCoord[3] : TEXCOORD0;
    float color        : COLOR0;
};

VB_OutputPos2TexCoords VS_ScreenQuadSampleUp(
    float4 pos      : POSITION, 
    float2 texCoord : TEXCOORD0)
{
    VB_OutputPos2TexCoords Out;
    float2 texelSize = 1.0 / windowSize;
    Out.pos = pos;
    // Don't use bilinear filtering
    Out.texCoord[0] = texCoord + texelSize*0.5f;
    Out.texCoord[1] = texCoord + texelSize*0.5f/downsampleScale;
    return Out;
}

float4 PS_ComposeFinalImage20Generic(
    VB_OutputPos2TexCoords In,
    uniform sampler2D sceneSampler,
    uniform sampler2D blurredSceneSampler) : COLOR
{
    half flash = 1.0;
    if(frac(Timer/10)<0.075)
        flash = 2.0*(0.55+0.45*sin(Timer*3.14f*2));
        
    float2 texCoord = In.texCoord[0];
    if (flash != 1.0f)
        texCoord.x += (flash-1.5f)/40.0f *
            cos(Timer*7+texCoord.y*25.18f);
        
    float4 orig = tex2D(sceneSampler, texCoord);
    float4 blur = tex2D(blurredSceneSampler, In.texCoord[1]);
    float Side = (Timer*Speed2);
    float ScanLine = (Timer*Speed);
    float2 s = float2(texCoord.x/5+Side,ScanLine);
    float scratch = tex2D(noiseMapSampler,s).x;
    
    // Add scratches
    scratch = 2.0f*(scratch - ScratchIntensity)/IS;
    scratch = 1.0-abs(1.0f-scratch);
    scratch = max(0,scratch) * 0.5f *
        (0.55f+0.45f*sin(Timer*4.0));
    orig *= 1+float4(scratch.xxx,0);

    float4 ret =
        0.8f * orig +
        0.5f * blur +
        HighlightIntensity * blur.a;
    
    ret *= flash;

    // Change colors a bit, sub 20% red and add 25% blue (photoshop values)
    // Here the values are -4% and +5%
    ret.rgb = float3(
        ret.r+0.054f,
        ret.g-0.021f,
        ret.b-0.035f+(flash-1)/3);
    
    // Change brightness -5% and contrast +10%
    ret.rgb = ret.rgb * 0.95f;
    ret.rgb = (ret.rgb - float3(0.5, 0.5, 0.5)) * 1.10f +
        float3(0.5, 0.5, 0.5);

    return ret;
}

float4 PS_ComposeFinalImage20(VB_OutputPos2TexCoords In) : COLOR
{
	return PS_ComposeFinalImage20Generic(In, sceneMapSampler, blurMap2Sampler);
}

// Works only on PS_PROFILE and up
struct VB_OutputPos7TexCoords
{
    float4 pos         : POSITION;
    float2 texCoord[7] : TEXCOORD0;
};

VB_OutputPos4TexCoords VS_DownSample20(
    float4 pos : POSITION,
    float2 texCoord : TEXCOORD0)
{
    VB_OutputPos4TexCoords Out;
    float2 texelSize = DownsampleMultiplicator /
        (windowSize * downsampleScale);
    float2 s = texCoord;
    Out.pos = pos;
    
    Out.texCoord[0] = s + float2(-1, -1)*texelSize;
    Out.texCoord[1] = s + float2(+1, +1)*texelSize;
    Out.texCoord[2] = s + float2(+1, -1)*texelSize;
    Out.texCoord[3] = s + float2(+1, +1)*texelSize;
    
    return Out;
}

float4 PS_DownSample20Generic(
    VB_OutputPos4TexCoords In,
    uniform sampler2D tex) : COLOR
{
    float4 c;

    // box filter (only for PS_PROFILE)
    c = tex2D(tex, In.texCoord[0])/4;
    c += tex2D(tex, In.texCoord[1])/4;
    c += tex2D(tex, In.texCoord[2])/4;
    c += tex2D(tex, In.texCoord[3])/4;
    
    // store hilights in alpha, can't use smoothstep version!
    // Fake it with highly optimized version using 80% as treshold.
    float l = Luminance(c.rgb);
    float treshold = 0.75f;
    if (l < treshold)
        c.a = 0;
    else
    {
        l = l-treshold;
        l = l+l+l+l; // bring 0..0.25 back to 0..1
        c.a = l;
    }

    return c;
}

float4 PS_DownSample20(VB_OutputPos4TexCoords In) : COLOR
{
	return PS_DownSample20Generic(In, sceneMapSampler);
}

// Blur downsampled map
VB_OutputPos7TexCoords VS_Blur20(
    uniform float2 direction,
    float4 pos : POSITION, 
    float2 texCoord : TEXCOORD0)
{
    VB_OutputPos7TexCoords Out = (VB_OutputPos7TexCoords)0;
    Out.pos = pos;

    float2 texelSize = BlurWidth / windowSize;
    float2 s = texCoord - texelSize*(7-1)*0.5*direction;
    for (int i=0; i<7; i++)
    {
        Out.texCoord[i] = s + texelSize*i*direction;
    }

    return Out;
}

VB_OutputPos7TexCoords VS_Blur20Horizontal(
    float4 pos : POSITION, 
    float2 texCoord : TEXCOORD0)
{
	return VS_Blur20(float2(1, 0), pos, texCoord);
}

VB_OutputPos7TexCoords VS_Blur20Vertical(
    float4 pos : POSITION, 
    float2 texCoord : TEXCOORD0)
{
	return VS_Blur20(float2(0, 1), pos, texCoord);
}

// blur filter weights
const half weights7[7] =
{
    0.05,
    0.1,
    0.2,
    0.3,
    0.2,
    0.1,
    0.05,
};    

float4 PS_Blur20(
    VB_OutputPos7TexCoords In,
    uniform sampler2D tex) : COLOR
{
    float4 c = 0;
    
    // this loop will be unrolled by compiler
    for(int i=0; i<7; i++)
    {
        c += tex2D(tex, In.texCoord[i]) * weights7[i];
       }
    return c;
}

float4 PS_Blur20Downsample(VB_OutputPos7TexCoords In) : COLOR
{
	return PS_Blur20(In, downsampleMapSampler);
}

float4 PS_Blur20BlurMap1(VB_OutputPos7TexCoords In) : COLOR
{
	return PS_Blur20(In, blurMap1Sampler);
}

// Same for PS_PROFILE, looks better and allows more control over the parameters.
technique ScreenGlow20
{
    // Sample full render area down to (1/4, 1/4) of its size!
    pass DownSample
    {
        // Disable alpha testing, else most pixels will be skipped
        // because of the highlight HDR technique tricks used here!
        //AlphaTestEnable = false;
        VertexShader = compile VS_PROFILE VS_DownSample20();
        PixelShader  = compile PS_PROFILE PS_DownSample20();
    }

    pass GlowBlur1
    {
        VertexShader = compile VS_PROFILE VS_Blur20Horizontal();
        PixelShader  = compile PS_PROFILE PS_Blur20Downsample();
    }

    pass GlowBlur2
    {
        VertexShader = compile VS_PROFILE VS_Blur20Vertical();
        PixelShader  = compile PS_PROFILE PS_Blur20BlurMap1();
    }

    // And compose the final image with the Blurred Glow and the original image.
    pass ComposeFinalScene
    {
        // This pass is not as fast as the previous passes (they were done
        // in 1/16 of the original screen size and executed very fast).
        VertexShader = compile VS_PROFILE VS_ScreenQuadSampleUp();
        PixelShader  = compile PS_PROFILE PS_ComposeFinalImage20();
    }
}