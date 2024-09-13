#include "Macros.fxh"

// Simple shader for RacingGame
float4x4 worldViewProj : WorldViewProjection;
float4x4 world : World;
float4x4 viewInverse : ViewInverse;

float3 lightDir : Direction
<
    string Object = "DirectionalLight";
    string Space = "World";
> = { 1, 0, 0 };

float4 ambientColor : Ambient = { 0.2f, 0.2f, 0.2f, 1.0f };
float4 diffuseColor : Diffuse = { 0.5f, 0.5f, 0.5f, 1.0f };
float4 specularColor : Specular = { 1.0, 1.0, 1.0f, 1.0f };
float specularPower : SpecularPower = 24.0f;

texture diffuseTexture : Diffuse
<
    string ResourceName = "marble.jpg";
>;
sampler diffuseTextureSampler = sampler_state
{
    Texture = <diffuseTexture>;
    AddressU  = Wrap;
    AddressV  = Wrap;
    AddressW  = Wrap;
    MinFilter=linear;
    MagFilter=linear;
    MipFilter=linear;
};

// Vertex input structure (used for ALL techniques here!)
struct VertexInput
{
    float3 pos      : POSITION;
    float2 texCoord : TEXCOORD0;
    float3 normal   : NORMAL;
    float3 tangent    : TANGENT;
};

// Vertex output structure
struct VertexOutput_SpecularPerPixel
{
    float4 pos      : POSITION;
    float2 texCoord    : TEXCOORD0;
    float3 normal   : TEXCOORD1;
    float3 halfVec    : TEXCOORD2;
};

// Common functions
float4 TransformPosition(float3 pos)
{
    return mul(float4(pos.xyz, 1), worldViewProj);
}

float3 GetWorldPos(float3 pos)
{
    return mul(float4(pos, 1), world).xyz;
}

float3 GetCameraPos()
{
    return viewInverse[3].xyz;
}

float3 CalcNormalVector(float3 nor)
{
    return normalize(mul(nor, (float3x3)world));
}

// Vertex output structure
struct VertexOutput_Diffuse
{
    float4 pos      : POSITION;
    float2 texCoord    : TEXCOORD0;
    float3 normal   : TEXCOORD1;
};

// Very simple diffuse mapping shader
VertexOutput_Diffuse VS_Diffuse(VertexInput In)
{
    VertexOutput_Diffuse Out = (VertexOutput_Diffuse)0;      
    Out.pos = TransformPosition(In.pos);
    Out.texCoord = In.texCoord;

    // Calc normal vector
    Out.normal = 0.5 + 0.5 * CalcNormalVector(In.normal);
    
    // Rest of the calculation is done in pixel shader
    return Out;
}

// Pixel shader
float4 PS_Diffuse(VertexOutput_Diffuse In) : COLOR
{
    float4 diffuseTexture = tex2D(diffuseTextureSampler, In.texCoord);
    // Convert colors back to vectors. Without normalization it is
    // a bit faster (2 instructions less), but not as correct!
    float3 normal = 2.0 * (saturate(In.normal)-0.5);

    // Diffuse factor
    float diff = saturate(dot(normal, lightDir));

    // Output the color
    float4 diffAmbColor = ambientColor + diff * diffuseColor;
    return diffuseTexture * diffAmbColor;
}

// -----------------------------------------------------

// Vertex shader for ps_1_1 (specular is just not as strong)
VertexOutput_SpecularPerPixel VS_SpecularPerPixel(VertexInput In)
{
    VertexOutput_SpecularPerPixel Out = (VertexOutput_SpecularPerPixel)0;      
    Out.pos = TransformPosition(In.pos);
    Out.texCoord = In.texCoord;

    // Determine the eye vector
    float3 worldEyePos = GetCameraPos();
    float3 worldVertPos = GetWorldPos(In.pos);

    // Calc normal vector
    Out.normal = 0.5 + 0.5 * CalcNormalVector(In.normal);
    // Eye vector
    float3 eyeVec = normalize(worldEyePos - worldVertPos);
    // Half angle vector
    Out.halfVec = 0.5 + 0.5 * normalize(eyeVec + lightDir);

    // Rest of the calculation is done in pixel shader
    return Out;
}

// Pixel shader
float4 PS_SpecularPerPixel(VertexOutput_SpecularPerPixel In) : COLOR
{
    float4 diffuseTexture = tex2D(diffuseTextureSampler, In.texCoord);
    // Convert colors back to vectors. Without normalization it is
    // a bit faster (2 instructions less), but not as correct!
    float3 normal = 2.0 * (saturate(In.normal)-0.5);
    float3 halfVec = 2.0 * (saturate(In.halfVec)-0.5);

    // Diffuse factor
    float diff = saturate(dot(normal, lightDir));
    // Specular factor
    float spec = saturate(dot(normal, halfVec));
    //max. possible pow fake with mults here: spec = pow(spec, 8);
    //same as: spec = spec*spec*spec*spec*spec*spec*spec*spec;

    // (saturate(4*(dot(N,H)^2-0.75))^2*2 is a close approximation
    // to pow(dot(N,H), 16). I use something like
    // (saturate(4*(dot(N,H)^4-0.75))^2*2 for approx. pow(dot(N,H), 32)
    spec = pow(saturate(4*(pow(spec, 2)-0.75)), 2);

    // Output the color
    float4 diffAmbColor = ambientColor + diff * diffuseColor;
    return diffuseTexture *
        diffAmbColor +
        spec * specularColor * diffuseTexture.a;
}

//-------------------------------------

// Vertex shader
VertexOutput_SpecularPerPixel VS_SpecularPerPixel20(VertexInput In)
{
    VertexOutput_SpecularPerPixel Out = (VertexOutput_SpecularPerPixel)0;
    float4 pos = float4(In.pos, 1); 
    Out.pos = mul(pos, worldViewProj);
    Out.texCoord = In.texCoord;
    Out.normal = mul(In.normal, world);
    // Eye pos
    float3 eyePos = viewInverse[3];
    // World pos
    float3 worldPos = mul(pos, world);
    // Eye vector
    float3 eyeVector = normalize(eyePos-worldPos);
    // Half vector
    Out.halfVec = normalize(eyeVector+lightDir);
    
    return Out;
}

// Pixel shader
float4 PS_SpecularPerPixel20(VertexOutput_SpecularPerPixel In) : COLOR
{
    float4 textureColor = tex2D(diffuseTextureSampler, In.texCoord);
    float3 normal = normalize(In.normal);
    float brightness = dot(normal, lightDir);
	float dotp = dot(normal, In.halfVec);
    float specular = pow(dotp, specularPower);
    return textureColor *
        (ambientColor +
        brightness * diffuseColor) +
        specular * specularColor;
}

//---------------------------------------------------

// vertex shader output structure
struct VertexOutput_ShadowCar20
{
    float4 pos          : POSITION;
    float2 texCoord     : TEXCOORD0;
};

// Special shader for car rendering, which allows to change the car color!
float4 shadowCarColor
<
    string UIName = "Shadow Car Color";
    string Space = "material";
> = {1.0f, 1.0f, 1.0f, 0.125f};

// Vertex shader function
float4 VS_ShadowCar20(VertexInput In) : POSITION0
{
    return TransformPosition(In.pos);
}

// Pixel shader function
float4 PS_ShadowCar20() : COLOR
{
    return shadowCarColor;
}

TECHNIQUE(Diffuse, VS_Diffuse, PS_Diffuse);
TECHNIQUE(Diffuse20, VS_Diffuse, PS_Diffuse);
TECHNIQUE(SpecularPerPixel, VS_SpecularPerPixel, PS_SpecularPerPixel);
TECHNIQUE(SpecularPerPixel20, VS_SpecularPerPixel20, PS_SpecularPerPixel20);

technique ShadowCar
{
    pass P0
    {
        ZWriteEnable = false;
        AlphaBlendEnable = true;
        SrcBlend = SrcAlpha;
        DestBlend = One;
        VertexShader = compile VS_PROFILE VS_ShadowCar20();
        PixelShader  = compile PS_PROFILE PS_ShadowCar20();
    }
}

technique ShadowCar20
{
    pass P0
    {
        ZWriteEnable = false;
        AlphaBlendEnable = true;
        SrcBlend = SrcAlpha;
        DestBlend = One;
        VertexShader = compile VS_PROFILE VS_ShadowCar20();
        PixelShader  = compile PS_PROFILE PS_ShadowCar20();
    }
}
