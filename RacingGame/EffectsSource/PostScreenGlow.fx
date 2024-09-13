#include "Macros.fxh"

string description = "Post screen shader for glowing with big radius";

// Glow/bloom post processing effect, adjusted for RacingGameManager.
// Parts are based on NVidias Post_bloom.fx, (c) NVIDIA Corporation 2004
// Also includes a border darken effect with help of screenBorderFadeout.dds.

// This script is only used for FX Composer, most values here
// are treated as constants by the application anyway.
// Values starting with an upper letter are constants.
float Script = 0.5;

const float DownsampleMultiplicator = 0.25f;
const float4 ClearColor : DIFFUSE = { 0.0f, 0.0f, 0.0f, 1.0f };
const float ClearDepth = 1.0f;

float GlowIntensity= 0.7f;

// Only used in PS_PROFILE
float HighlightThreshold = 0.975f;
float HighlightIntensity = 0.4f;
float radialBlurScaleFactor = -0.004f;

// Render-to-Texture stuff
float2 windowSize : VIEWPORTPIXELSIZE;
const float downsampleScale = 0.25;

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

texture radialSceneMap;
sampler radialSceneMapSampler = sampler_state 
{
    texture = <radialSceneMap>;
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

// For the last pass we add this screen border fadeout map to darken the borders
texture screenBorderFadeoutMap;
sampler screenBorderFadeoutMapSampler = sampler_state 
{
    texture = <screenBorderFadeoutMap>;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
    AddressW  = CLAMP;
    MIPFILTER = NONE;
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

float4 PS_Display(
    VB_OutputPosTexCoord In,
    uniform sampler2D tex) : COLOR
{   
    float4 outputColor = tex2D(tex, In.texCoord);
    // Display color
    return outputColor;
}

float4 PS_DisplayAlpha(
    VB_OutputPosTexCoord In,
    uniform sampler2D tex) : COLOR
{
    float4 outputColor = tex2D(tex, In.texCoord);
    // Just display alpha
    return float4(outputColor.a, outputColor.a, outputColor.a, 0.0f);
}

/////////////////////////////
// ps_1_1 shader functions //
/////////////////////////////

VB_OutputPos3TexCoords VS_ScreenQuadSampleUp(
    float4 pos      : POSITION, 
    float2 texCoord : TEXCOORD0)
{
    VB_OutputPos3TexCoords Out;
    float2 texelSize = 1.0 / windowSize;
    Out.pos = pos;
    // Don't use bilinear filtering
    Out.texCoord[0] = texCoord + texelSize*0.5f;
    Out.texCoord[1] = texCoord + texelSize*0.5f/downsampleScale;
    Out.texCoord[2] = texCoord + (1.0/128.0f)*0.5f;
    return Out;
}

float4 PS_ComposeFinalImage20Generic(
    VB_OutputPos3TexCoords In,
    uniform sampler2D sceneSampler,
    uniform sampler2D blurredSceneSampler) : COLOR
{
    float4 orig = tex2D(sceneSampler, In.texCoord[0]);
    float4 blur = tex2D(blurredSceneSampler, In.texCoord[1]);

    float4 screenBorderFadeout =
        tex2D(screenBorderFadeoutMapSampler, In.texCoord[2]);
        
    float4 ret =
        0.75f*orig +
        GlowIntensity*blur +
        HighlightIntensity*blur.a;
    ret.rgb *= screenBorderFadeout;
    
    // Change colors a bit, sub 20% red and add 25% blue (photoshop values)
    // Here the values are -4% and +5%
    ret.rgb = float3(
        ret.r+0.054f/2,
        ret.g-0.021f/2,
        ret.b-0.035f/2);
    
    // Change brightness -5% and contrast +10%
    ret.rgb = ret.rgb * 0.95f;
    ret.rgb = (ret.rgb - float3(0.5, 0.5, 0.5)) * 1.05f +
        float3(0.5, 0.5, 0.5);

    return ret;
}

float4 PS_ComposeFinalImage20(VB_OutputPos3TexCoords In) : COLOR
{
	return PS_ComposeFinalImage20Generic(In, radialSceneMapSampler, blurMap2Sampler);
}

//////////////////
// PS_PROFILE stuff //
//////////////////

// Works only on PS_PROFILE and up
struct VB_OutputPos7TexCoords
{
    float4 pos         : POSITION;
    float2 texCoord[7] : TEXCOORD0;
};

struct VB_OutputPos8TexCoords
{
    float4 pos         : POSITION;
    float2 texCoord[8] : TEXCOORD0;
};

// Blur Width is only used for PS_PROFILE, ps_1_1 is optimized!
float BlurWidth <
    string UIName = "Blur width";
    string UIWidget = "slider";
    float UIMin = 0.0f;
    float UIMax = 10.0f;
    float UIStep = 0.5f;
> = 8.0f;

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

float4 PS_DownSample20(VB_OutputPos4TexCoords In) : COLOR
{
    float4 c;

    // box filter (only for PS_PROFILE)
    c = tex2D(radialSceneMapSampler, In.texCoord[0])/4;
    c += tex2D(radialSceneMapSampler, In.texCoord[1])/4;
    c += tex2D(radialSceneMapSampler, In.texCoord[2])/4;
    c += tex2D(radialSceneMapSampler, In.texCoord[3])/4;

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

VB_OutputPos7TexCoords VS_Blur20Horizontal(float4 pos : POSITION, float2 texCoord : TEXCOORD0)
{
	return VS_Blur20(float2(1, 0), pos, texCoord);
}

VB_OutputPos7TexCoords VS_Blur20Vertical(float4 pos : POSITION, float2 texCoord : TEXCOORD0)
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

float4 PS_Blur20(VB_OutputPos7TexCoords In, uniform sampler2D tex) : COLOR
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

VB_OutputPos8TexCoords VS_RadialBlur20(
    float4 pos      : POSITION, 
    float2 texCoord : TEXCOORD0)
{
    VB_OutputPos8TexCoords Out;
    float2 texelSize = 1.0 / windowSize;
    Out.pos = pos;
    // Don't use bilinear filtering, correct pixel locations
    
    // This is our original finalSceneMap, reuse existing locations
    Out.texCoord[0] = texCoord + texelSize*0.5f;
    
    // For all radial blur steps scale the finalSceneMap
    float2 texCentered = (texCoord-float2(0.5f, 0.5f))*2.0f;
    
    // Now apply formula to nicely increase blur factor to the borders
    for (int i=1; i<8; i++)
    {
        texCentered = texCentered+
            radialBlurScaleFactor*(0.5f+i*0.15f)*texCentered*abs(texCentered);
        Out.texCoord[i] = (texCentered+float2(1.0f, 1.0f))/2.0f + texelSize*0.5;
    }
    
    return Out;
}

float4 PS_RadialBlur20(VB_OutputPos8TexCoords In) : COLOR
{
    float4 radialBlur = tex2D(sceneMapSampler, In.texCoord[0]);
    for (int i=1; i<8; i++)
        radialBlur += tex2D(sceneMapSampler, In.texCoord[i]);
    return radialBlur/8;
}

// Same for PS_PROFILE, looks better and allows more control over the parameters.
technique ScreenGlow20
{
    // Generate the radial blur with help of the current scene (finalSceneMap)
    // This pass is quite slow, but for the high quality of the effect we need
    // full screen processing and using a lot of texture fetches.
    pass RadialBlur
    {
        // Disable alpha testing, else most pixels will be skipped
        // because of the highlight HDR technique tricks used here!
        //AlphaTestEnable = false;
        VertexShader = compile VS_PROFILE VS_RadialBlur20();
        PixelShader  = compile PS_PROFILE PS_RadialBlur20();
    }
    
    // Sample full render area down to (1/4, 1/4) of its size!
    pass DownSample
    {
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
        // Save 1 pass by combining the radial blur effect and the compose pass.
        // This pass is not as fast as the previous passes (they were done
        // in 1/16 of the original screen size and executed very fast).
        VertexShader = compile VS_PROFILE VS_ScreenQuadSampleUp();
        PixelShader  = compile PS_PROFILE PS_ComposeFinalImage20();
    }
}