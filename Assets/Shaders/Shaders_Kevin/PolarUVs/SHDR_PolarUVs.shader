Shader "02/SHDR_PolarUVs"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{}
        _ST ("Scale and Offset", Vector) = (1,1,0,0)
        _PanningX("Panning X", Range(-1,1)) = 0
        _PanningY("Panning Y", Range(-1,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define PI2 6.283185307179586476924

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

            float2 CenterUVs(float2 uvs)
            {
                uvs -= 0.5f;
                uvs *= 2;
                return uvs;
            }

            float2 CartessianToPolar(float2 cartesian)
            {
	            float distance = length(cartesian);
	            float angle = atan2(cartesian.y, cartesian.x);
	            return float2(angle / PI2, distance);
            }

            float2 PolarToCartessian(float2 polar)
            {
                float2 cartesian;
                sincos(polar.x * PI2, cartesian.y, cartesian.x);
                return cartesian * polar.y;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_M, v.vertex); //Model to world
                o.vertex = mul(UNITY_MATRIX_V, o.vertex); //World to view
                o.vertex = mul(UNITY_MATRIX_P, o.vertex); //View to projection
                o.uv = CenterUVs(v.uv);
                //o.uv = (CenterUVs(v.uv) + _ST.zw) * _ST.xy; this should be after transformation to polar
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                

                //Transform to Polar uvs
                uv = CartessianToPolar(uv);
                uv = frac(uv);
                //return float4(uv,0,1);

                //Apply ST // Add power by distance? 
                uv = (uv + _ST.zw) * _ST.xy;

                //Apply Pannings
                uv += fixed2(_PanningX, _PanningY) * _Time.y ;

                //Apply additional effects
              //   uv.x += -1*_Time.y;
                uv.x += uv.y;
                uv.y -= uv.x;

                //Return to Cartessian
               // uv = PolarToCartessian(uv);
                
                uv = frac(uv);
                //return float4(uv,0,1);
                return tex2D(_MainTex, uv);
               // return fixed4(uv,0,1);
            }
            ENDCG
        }
    }
}
