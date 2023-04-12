Shader "01/SHDR_01_FXStack_Coordinates_Dir"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainTexB ("TextureB", 2D) = "white"{} 
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
            sampler2D _MainTexB;
            float4 _MainTex_ST, _MainTexB_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;//TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                //uv vortex tex
                uv *= 2;
                uv = frac(uv);
                uv -= 0.5;

                //uv of water panning tex


                //Spherical mask from center (to lerp after with the base texture)
                fixed mask = distance(fixed2(0,0), uv);
                mask = 1-mask;
                mask += 0.2f;
                mask = pow(mask, 10);
                mask = saturate(mask);

                //Transform uv vortex tex to polar

                

                //return 1-mask;
                
                //Apply effects on polar

                //return to cartessian

                //sampler both textures with both uvs

                //return interpolation between two by pre calculated mask
                //lerp(ColA,ColB, mask) -> 

                return mask;

                

                return float4(uv,0,1);
                
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
