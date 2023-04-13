Shader "03/Shader_Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AmbientCol ("Ambient light color", Color) = (0.25, 0.25, 0.35, 1)
        // A lo mejor necesitamos una variable para el color del objeto
        _SpecCol ("Specular light color", Color) = (1, 1, 1, 1)
        _SpecIntensity ("Specular light intensity", Range(0, 100)) = 10
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags { "Lightmode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform float4 _LightColor0;

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
                half3 wpos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _AmbientCol;
            half4 _SpecCol;
            float _SpecIntensity;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wpos = mul((float3x3)unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 finalCol;

                half3 viewDir = normalize(i.wpos - _WorldSpaceCameraPos);
                half lightDir = _WorldSpaceLightPos0.xyz * (1 - _WorldSpaceLightPos0.w);

                half3 ambient = half3(0, 0, 0);
                half3 diffuse = half3(0, 0, 0);
                half3 specular = half3(0, 0, 0);

                ambient = _AmbientCol;
                diffuse = _LightColor0.rgb /* "* _Color.rgb *" */ * max(0.0, dot(i.normal, lightDir));
                
                if (dot(i.normal, lightDir) < 0.0)
                    specular = half3(0, 0, 0);
                else
                    specular = /* "attenuation" */ _LightColor0.rgb * _SpecCol.rgb * pow(max(0.0, dot(reflect(lightDir, i.normal), viewDir)), _SpecIntensity);

                finalCol = fixed4((ambient + diffuse) * col + specular, 1);

                return finalCol;
            }

            ENDCG
        }
    }
}