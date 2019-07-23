Shader "Hidden/HdrpBlitter/Glitch"
{
    HLSLINCLUDE

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/NormalBuffer.hlsl"
    #include "SimplexNoise2D.hlsl"

    TEXTURE2D(_Source1Texture);
    TEXTURE2D(_Source2Texture);
    float _FadeParameter;
    float _EffectTime;

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
        float2 reso = _ScreenSize.xy / 32;
        uint2 ireso = (uint2)reso;

        uint2 block = texcoord * reso;
        uint id = block.x + block.y * ireso.x;

        uint stride = 1 + 8 * floor((1 + snoise(_EffectTime)) * 3);
        uint segment = id / stride;

        float n1 = 0.5 * (1 + snoise(float2(segment, _EffectTime * 3)));
        float n2 = 0.5 * (1 + snoise(float2(segment, _EffectTime + 100)));

        half mask = n1 < _FadeParameter;
        id += mask * floor(n2 * 16) / 8 * ireso.x;

        float2 uv1 = float2(id % ireso.x, id / ireso.x) / reso;
        uv1 += fmod(texcoord, 1 / reso);

        float2 uv2 = texcoord;
        uv2.x += (Hash((uv2.y + _EffectTime * 60) * reso.y) - 0.5) * 0.03;

        uint2 p1 = uv1 * _ScreenSize.xy;
        uint2 p2 = uv2 * _ScreenSize.xy;

        float4 c1 = LOAD_TEXTURE2D(_Source1Texture, p1);
        float4 c2 = LOAD_TEXTURE2D(_Source2Texture, p2);

        return frac(c1 + c2 * mask);
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
