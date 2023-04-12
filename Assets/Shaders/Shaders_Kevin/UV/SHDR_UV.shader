Shader "02/SHDR_UV"
{
    Properties
    {
         _MainTex("Main Tex", 2D) = "white"{}
        _ST ("Scale and Offset", Vector) = (1,1,0,0)
        _PanningX("Panning X", Range(-10,10)) = 0
        _PanningY("Panning Y", Range(-10,10)) = 0
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;
            float4 _ST;
            fixed _PanningX, _PanningY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_M, v.vertex); //Model to world
                o.vertex = mul(UNITY_MATRIX_V, o.vertex); //World to view
                o.vertex = mul(UNITY_MATRIX_P, o.vertex); //View to projection
                o.uv = (v.uv + _ST.zw) * _ST.xy;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                uv += fixed2(_PanningX, _PanningY) * _Time.y;

                
                uv = frac(uv);

               // return float4(uv,0,1);
                return tex2D(_MainTex,uv);
            }
            ENDCG
        }
    }
}
