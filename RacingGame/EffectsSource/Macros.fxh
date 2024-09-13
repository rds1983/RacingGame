//-----------------------------------------------------------------------------
// Macros.fxh
//
// Microsoft XNA Community Game Platform
// Copyright (C) Microsoft Corporation. All rights reserved.
//-----------------------------------------------------------------------------

#ifdef SM4

// Macros for targetting shader model 4.0 (DX11)

#define VS_PROFILE vs_4_0
#define PS_PROFILE ps_4_0

#else

// Macros for targetting shader model 3.0 (mojoshader)

#define VS_PROFILE vs_3_0
#define PS_PROFILE ps_3_0

#endif

#define TECHNIQUE(name, vsname, psname ) \
	technique name { pass { VertexShader = compile VS_PROFILE vsname (); PixelShader = compile PS_PROFILE psname(); } }
