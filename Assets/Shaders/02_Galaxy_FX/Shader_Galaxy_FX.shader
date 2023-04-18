Shader "02/Shader_Galaxy_FX"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Size ("Size", Range(0, 5)) = 1
        _PanSpeed ("Pan Speed", Range(-2, 2)) = 0
        _Shininess ("Shininess", Range(-1, 100)) = 0
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _FresnelExponent ("Fresnel Exponent", Range(0, 10)) = 2
        _FresnelMultiplier ("Fresnel Multiplier", Range(0, 1)) = 1
    }

    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Opaque"}

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 normal : NORMAL;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _Color;
            float _Size;
            float _PanSpeed;
            float _Shininess;
            float3 _SpecularColor;
            float _FresnelExponent;
            float _FresnelMultiplier;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = mul(unity_ObjectToWorld, float4(v.normal, 0)).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float2 uv = i.uv * _Size;
                uv += _Time.y * _PanSpeed; // add panning to the UV coordinates
                float4 galaxy = tex2D(_MainTex, uv);

                float3 lightDir = normalize(_WorldSpaceLightPos0 - i.worldPos);
                float3 halfwayDir = normalize(i.viewDir + lightDir);

                float diffuse = max(0, dot(i.worldNormal, lightDir));
                float specular = pow(max(0, dot(i.worldNormal, halfwayDir)), _Shininess);

                col.rgb *= _Color.rgb * galaxy.rgb;
                col.rgb += _SpecularColor.rgb * specular;
                col.a *= galaxy.a;

                // add fresnel effect
                // Hey listen!
                    // This fresnel effect is pretty bad and poopy and stinky.
                    // We don't know what the shader should look like, so we are waiting to know (xD).
                float fresnel = 1 - pow(max(0, dot(i.viewDir, i.worldNormal)), _FresnelExponent);
                col.rgb = lerp(col.rgb, _SpecularColor.rgb, fresnel * _FresnelMultiplier);

                return col;
            }

            ENDCG
        }
    }
}