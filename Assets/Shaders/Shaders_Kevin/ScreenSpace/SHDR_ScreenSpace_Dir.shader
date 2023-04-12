Shader "Unlit/SHDR_ScreenSpace_Dir"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FresnelCol("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

        Pass{
            CGPROGRAM

            #include "UnityCG.cginc"

            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5

            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _FresnelCol;

            struct appdata{
                float4 vertex : POSITION;
                half3 normal : NORMAL;
            };

            
            struct v2f{
                float4 position : SV_POSITION;
                float3 normal : NORMAL;
                half3 viewDir : TEXCOORD1;
                float4 screenPosition : TEXCOORD0;
                float3 wpos: TEXCOORD2;
            };

            v2f vert(appdata v){
                v2f o;
                o.wpos = mul(unity_ObjectToWorld, v.vertex);
                o.position = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
               //clip space vertex to transpose coordinates
                o.screenPosition = ComputeScreenPos(o.position);

                o.viewDir = normalize(o.wpos - _WorldSpaceCameraPos);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                //Divide screen position xy, by screen position w;
                float2 screenspaceuv = i.screenPosition.xy / i.screenPosition.w;
                screenspaceuv *= 4;

                float ratio = _ScreenParams.x / _ScreenParams.y;

                screenspaceuv.x *= ratio;
                float4 col = tex2D(_MainTex, screenspaceuv);

                fixed fresnel = saturate(dot(i.viewDir*-1, i.normal));
               

                fixed4 fresnelCol = lerp(_FresnelCol, col,fresnel);
                

                return fresnelCol;
                
            }
            ENDCG
        }
    }
}
