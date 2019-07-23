Shader "Hidden/HdrpBlitter/CrossFade"
{
    HLSLINCLUDE

    #include "Common.hlsl"

    TEXTURE2D(_Source1Texture);
    TEXTURE2D(_Source2Texture);
    float _FadeParameter;
    float4 _FillColor;

    // Vertex shader (procedural fullscreen triangle)
    void Vertex(
        uint vertexID : SV_VertexID,
        out float4 positionCS : SV_POSITION,
        out float2 texcoord : TEXCOORD0
    )
    {
        positionCS = GetFullScreenTriangleVertexPosition(vertexID);
        texcoord = FixVFlip(GetFullScreenTriangleTexCoord(vertexID));
    }

    // Fragment shader
    float4 Fragment(
        float4 positionCS : SV_POSITION,
        float2 texcoord : TEXCOORD0
    ) : SV_Target
    {
        uint2 ssp = texcoord * _ScreenSize.xy;
        float4 c1 = LinearToSRGB(LOAD_TEXTURE2D(_Source1Texture, ssp));
        float4 c2 = LinearToSRGB(LOAD_TEXTURE2D(_Source2Texture, ssp));
        float4 c3 = LinearToSRGB(_FillColor);
        return SRGBToLinear(lerp(lerp(c1, c2, _FadeParameter), c3, c3.a));
    }

    ENDHLSL
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDHLSL
        }
    }
}
