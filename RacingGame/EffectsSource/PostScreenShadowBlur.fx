#include "Macros.fxh"

string description = "Post screen shader for shadow blurring";

// Blur post processing effect.
// ScreenAdvancedBlur : 2 pass blur filter (horizontal and vertical) for ps11
// ScreenAdvancedBlur20 : 2 pass blur filter (horizontal and vertical) for ps20

// This script is only used for FX Composer, most values here
// are treated as constants by the application anyway.
// Values starting with an upper letter are constants.
float Script = 1.0;

const float4 ClearColor = { 0.0f, 0.0f, 0.0f, 1.0f};
const float ClearDepth = 1.0f;

// Render-to-Texture stuff
float2 windowSize;

const float BlurWidth = 1.25f;

// For PS_PROFILE use only half the blur width
// because we cover a range twice as big.
// Update: For shadows 2.0 looks much better and smoother :)
// ps_1_1 can't archive that effect with just 4 samples.
const float BlurWidth20 = 1.5f;

texture sceneMap;
sampler sceneMapSampler = sampler_state 
{
    texture = <sceneMap>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    AddressW  = Clamp;
    MIPFILTER = None;
    MINFILTER = Linear;
    MAGFILTER = Linear;
};

// Only for 2 passes (horz/vertical blur)
texture blurMap;
sampler blurMapSampler = sampler_state 
{
    texture = <blurMap>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    AddressW  = Clamp;
    MIPFILTER = None;
    MINFILTER = Linear;
    MAGFILTER = Linear;
};

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

struct VB_OutputPos4TexCoords
{
       float4 pos         : POSITION;
    float2 texCoord[4] : TEXCOORD0;
};

//-----------------------------------------------------------

// 8 Weights for PS_PROFILE
const float Weights8[8] =
{
    // more strength to middle to reduce effect of lighten up
    // shadowed areas due mixing and bluring!
    0.035,
    0.09,
    0.125,
    0.25,
    0.25,
    0.125,
    0.09,
    0.035,
};

struct VB_OutputPos8TexCoords
{
       float4 pos         : POSITION;
    float2 texCoord[8] : TEXCOORD0;
};

// generate texcoords for avanced blur
VB_OutputPos8TexCoords VS_AdvancedBlur20(
    float4 pos      : POSITION, 
    float2 texCoord : TEXCOORD0,
    uniform float2 dir)
{
    VB_OutputPos8TexCoords Out = (VB_OutputPos8TexCoords)0;
    Out.pos = pos;
    float2 texelSize = 1.0 / windowSize;
    float2 s = texCoord - texelSize*(8-1)*0.5*dir*BlurWidth20 + texelSize*0.5;
    for(int i=0; i<8; i++)
    {
        Out.texCoord[i] = s + texelSize*i*dir*BlurWidth20;
    }
    return Out;
}

VB_OutputPos8TexCoords VS_AdvancedBlur20Horizontal(
    float4 pos      : POSITION, 
    float2 texCoord : TEXCOORD0)
{
	return VS_AdvancedBlur20(pos, texCoord, float2(1, 0));
}

VB_OutputPos8TexCoords VS_AdvancedBlur20Vertical(
    float4 pos      : POSITION, 
    float2 texCoord : TEXCOORD0)
{
	return VS_AdvancedBlur20(pos, texCoord, float2(0, 1));
}

float4 PS_AdvancedBlur20Generic(
    VB_OutputPos8TexCoords In,
    uniform sampler2D tex) : COLOR
{
    float4 ret = 0;
    // This loop will be unrolled by the compiler
    for (int i=0; i<8; i++)
    {
        float4 col = tex2D(tex, In.texCoord[i]);
        ret += col * Weights8[i];
    }
    return ret;
}

float4 PS_AdvancedBlur20SceneMap(VB_OutputPos8TexCoords In) : COLOR
{
	return PS_AdvancedBlur20Generic(In, sceneMapSampler);
}

float4 PS_AdvancedBlur20BlurMap(VB_OutputPos8TexCoords In) : COLOR
{
	return PS_AdvancedBlur20Generic(In, blurMapSampler);
}

// Advanced blur technique for PS_PROFILE with 2 passes (horizontal and vertical)
// This one uses not only 4, but 8 texture samples!
technique ScreenAdvancedBlur20
{
    // Advanced blur shader
    pass AdvancedBlurHorizontal
    {
        VertexShader = compile VS_PROFILE VS_AdvancedBlur20Horizontal();
        PixelShader  = compile PS_PROFILE PS_AdvancedBlur20SceneMap();
    }

    pass AdvancedBlurVertical
    {
        VertexShader = compile VS_PROFILE VS_AdvancedBlur20Vertical();
        PixelShader  = compile PS_PROFILE PS_AdvancedBlur20BlurMap();
    }
}
