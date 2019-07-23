Shader "Hidden/HdrpBlitter/CrossFade"
{
    HLSLINCLUDE

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/NormalBuffer.hlsl"

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
        texcoord = GetFullScreenTriangleTexCoord(vertexID);
    }

    // Fragment shader
    float4 Fragment(
        float4 positionCS : SV_POSITION,
        float2 texcoord : TEXCOORD0
    ) : SV_Target
    {
        uint2 ssp = texcoord * _ScreenSize.xy;
        float4 c1 = LOAD_TEXTURE2D(_Source1Texture, ssp);
        float4 c2 = LOAD_TEXTURE2D(_Source2Texture, ssp);
        float4 c3 = lerp(c1, c2, _FadeParameter);
        return lerp(c3, _FillColor, _FillColor.a);
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
