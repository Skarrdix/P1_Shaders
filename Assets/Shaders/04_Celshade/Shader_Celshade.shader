Shader "04/Unlit/Shader_Celshade"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutWidth ("Outline Width",Range(0,2)) = 0.25
        _OutCol ("Outline Color", color) =  (0, 0, 0, 1)
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimIntensity ("Rim Intensity", Range(0, 1)) = 0
        _RimPower ("Rim Power", Range(0, 5)) = 1
    }
    
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass // Outline
        {
            Cull Front

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            half _OutWidth;
            half4 _OutCol;

            v2f vert (appdata v)
            {
                v2f o;

                v.vertex.xyz += v.normal * _OutWidth;
                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutCol;
            }

            ENDCG
        }

        Pass // Interior
        {
            Cull Back

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
                float4 vertex : SV_POSITION;

                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 viewDirection : TEXCOORD2;
            };

            sampler2D _MainTex;
            half _OutWidth;
            half4 _OutCol;
            half4 _RimColor;
            float _RimIntensity;
            float _RimPower;

            half4 rimLight(half4 color, float3 normal, float3 viewDir)
            {
                // Watch out!
                    // No hemos encontrado la función para
                    // hacer el OneMinus con ShaderLab.
                float NdotVDir = 1 - dot(normal, viewDir);

                NdotVDir = pow(NdotVDir, _RimPower);
                NdotVDir *= _RimIntensity;

                // Watch out!
                    // Devuelve tres veces red, por algún motivo.
                half4 finalColor = lerp(color, _RimColor, NdotVDir);

                return finalColor;
            }

            v2f vert (appdata v)
            {
                v2f o;

                //v.vertex.xyz += v.normal * _OutWidth;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDirection = WorldSpaceViewDir(v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                i.worldNormal = normalize(i.worldNormal);
                i.viewDirection = normalize(i.viewDirection);

                col = rimLight(col, i.worldNormal, i.viewDirection);

                return col;
            }

            ENDCG
        }
    }
}