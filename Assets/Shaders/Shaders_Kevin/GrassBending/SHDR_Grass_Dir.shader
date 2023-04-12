Shader "03/SHDR_Grass_Dir"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Offset ("Offset color", Range(-1,1)) = 0
        _Contrast("Contrast color", Range(0,10)) = 1
        _ColA ("Color Top", Color) = (1,1,1,1)
        _ColB ("Color Bottom", Color) = (0,0,0,1) 
    }
    SubShader
    {
        Tags {"Queue"="AlphaTest"  "RenderType"="TransparentCutout"}
        Blend One OneMinusSrcAlpha
     //ss   ZWrite Off
        
        
        Cull Off

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
            float4 _MainTex_ST;
            fixed4 _ColA, _ColB;
            float _Contrast, _Offset;
            
            

            v2f vert (appdata v)
            {
                v2f o;
                v.vertex.xy += sin(_Time.y) * v.uv.y;  
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                //create interpolation var and calculate from uv.y - base var for color interp
                
                //add to interpolation offset, clamp it (saturate) and apply contrast with pow

                //apply color interpolation via lerp (cola, colb, interpolation) 


                float interpolation = i.uv.y;

                interpolation = saturate(interpolation + _Offset);
                interpolation = saturate(pow(interpolation, _Contrast));
                


                col.rgb = lerp(_ColB, _ColA, interpolation);


                if(col.a < 0.5)
                    discard;
                

                
                
                    
                col.rgb *= col.a ;
                return col;
            }
            ENDCG
        }
    }
}
