Shader "01/Shader_Visual_Landscape_Deformation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SubTex ("Sub Texture", 2D) = "white" {}
        _HeightTex ("Height Texture", 2D) = "white" {}
        _FallOff ("Fall Off blend", Range(0,10)) = 5
        _DDist ("Derivate Distance", Range(0.001, 1)) = 0.015
        _Height ("Height Multiplier", Range(0, 20)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                half3 normal : NORMAL;
                float3 wpos : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _SubTex;
            sampler2D _HeightTex;
            float4 _MainTex_ST, _HeightTex_TexelSize;
            float _DDist;
            float _Height;
            fixed _FallOff;

            float3 normalsFromHeight(float4 uv, float texelSize)
            {
                float4 h;
                h[0] = tex2Dlod(_HeightTex, uv + float4(texelSize * float2(0, -1 / _DDist), 0, 0)).r * _Height;
                h[1] = tex2Dlod(_HeightTex, uv + float4(texelSize * float2(-1 / _DDist, 0), 0, 0)).r * _Height;
                h[2] = tex2Dlod(_HeightTex, uv + float4(texelSize * float2(1 / _DDist, 0), 0, 0)).r * _Height;
                h[3] = tex2Dlod(_HeightTex, uv + float4(texelSize * float2(0, 1 / _DDist), 0, 0)).r * _Height;
                float3 n;
                n.z = h[3] - h[0];
                n.x = h[2] - h[1];
                n.y = 2;
                return normalize(n);
            }

            v2f vert (appdata v)
            {
                v2f o;

                float heightSample = tex2Dlod(_HeightTex, float4(v.uv, 0, 0)).x * _Height;
                //calculate world position an assign it to o.wpos
                o.wpos = mul((float3x3)unity_ObjectToWorld, v.vertex).xyz + float4(0, heightSample, 0 ,0);
                o.vertex = UnityObjectToClipPos(v.vertex + float3(0, heightSample, 0));

                o.normal = normalsFromHeight(float4(v.uv, 0, 0), _HeightTex_TexelSize.x);

                //calculate world space normal
                o.normal = UnityObjectToWorldNormal(o.normal);
    
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //calculate uv top abs(wpos.xz) an assign as uv_top
                float2 uv_top = i.wpos.xz;
                //calculate uv right abs(wpos.yz) an assign as uv_right
                float2 uv_right = i.wpos.yz;
                //calculate uv forward abs(wpos.yx) an assign as uv_forward
                float2 uv_forward = i.wpos.yx;
                
                //tex2D (_MainTex, uv_top)...
                fixed4 col_top = tex2D(_SubTex, uv_top);
                fixed4 col_right = tex2D(_MainTex, uv_right);
                fixed4 col_forward = tex2D(_MainTex, uv_forward);

                half3 weights;
                weights.y = pow(abs(i.normal.y), _FallOff);
                weights.x = pow(abs(i.normal.x), _FallOff);
                weights.z = pow(abs(i.normal.z), _FallOff);

                weights = weights / (weights.x + weights.y + weights.z);

                col_top *= weights.y;
                col_right *= weights.x;
                col_forward *= weights.z;
                
                fixed4 col = col_top + col_forward + col_right;

                return col;
            }

            ENDCG
        }
    }
}