Shader "02/SHDR_PolarUVs_Dir"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ST("Tiling and Offset", Vector) = (1,1,0,0)
        _PanningX("Panning X", Range(-10,10)) = 0
        _PanningY("Panning Y", Range(-10,10)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define TAU 6.283185307179586476924

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

            float2 CartessianToPolar(float2 cartesian)
            {
	            float distance = length(cartesian);
	            float angle = atan2(cartesian.y, cartesian.x);
	            return float2(angle / TAU, distance);
            }

            float2 PolarToCartessian(float2 polar)
            {
                float2 cartesian;
                sincos(polar.x * TAU, cartesian.y, cartesian.x);
                return cartesian * polar.y;
            }

            sampler2D _MainTex;
            float4 _ST;
            fixed _PanningX, _PanningY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = v.uv;
                
                o.uv = (v.uv * _ST.xy) + _ST.zw;
                o.uv += float2(_PanningX, _PanningY) * (_Time.y);
                //o.uv = frac(o.uv);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                //base uv setup 
                float2 uv = i.uv;
                uv -= 0.5;

                //Cartessian to polar 
                uv = CartessianToPolar(uv);

                //Additional modifications
                uv.x += -1*_Time.y;
                uv.x += uv.y;

                //Return to Cartessian

                uv = PolarToCartessian(uv);

                //return float4(uv,0,1);
                //Final correction and return 
                uv = frac(uv);
                //return float4(uv,0,1);
                return tex2D(_MainTex,uv);
            }
            ENDCG
        }
    }
}
