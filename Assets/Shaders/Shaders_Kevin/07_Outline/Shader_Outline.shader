Shader "07/Unlit/Shader_Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutWidth ("Outline Width",Range(0,2)) = 0.25
        _OutCol ("Outline Color", color) =  (0, 0, 0, 1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
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

        Pass
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
                //v.vertex.xyz += v.normal * _OutWidth;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return (1, 1, 1, 1);
            }
            ENDCG
        }
    }
}