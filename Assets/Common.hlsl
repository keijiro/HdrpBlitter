#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

float2 FixVFlip(float2 texcoord)
{
#if UNITY_UV_STARTS_AT_TOP
    bool flip = _ProjectionParams.x > 0;
#else
    bool flip = _ProjectionParams.x < 0;
#endif
    if (flip) texcoord.y = _RTHandleScale.y - texcoord.y;
    return texcoord;
}
