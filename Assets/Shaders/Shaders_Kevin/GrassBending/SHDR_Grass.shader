Shader "03/SHDR_Grass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColB ("Col Bottom", Color ) = (0,0,0,1)
        _ColA ("Col Top", Color ) = (1,1,1,1)
        _Offset("Offset", Range(-1,1)) = 0
        _Contrast("Contrast", Range(0,10)) = 1
    }
    SubShader
    {
        Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
        Blend One OneMinusSrcAlpha
        ZWrite Off
        
        
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
            float4 _MainTex_ST, _ColB, _ColA;
            float _Offset,_Contrast;

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
                fixed mask = tex2D(_MainTex, i.uv).a;
                float interpolation = i.uv.y;

                interpolation = saturate(pow(saturate(interpolation + _Offset), _Contrast));

                
                fixed4 col = fixed4(0,0,0,0);
                col = lerp(_ColB, _ColA, interpolation);
                col.rgb *= mask;
                col.a = mask;

                

                
                return col;
            }
            ENDCG
        }
    }
}
