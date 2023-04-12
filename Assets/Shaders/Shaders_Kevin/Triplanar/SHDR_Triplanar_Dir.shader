Shader "Unlit/SHDR_Triplanar_Dir"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FallOff ("Fall Off blend", Range(0,5)) = 0.25
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
                half3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                half3 normal : NORMAL;
                float3 wpos : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _FallOff;

            v2f vert (appdata v)
            {
                v2f o;
                //calculate world position an assign it to o.wpos
                o.wpos = mul((float3x3)unity_ObjectToWorld, v.vertex);
                
                //calculate world space normal
                o.normal = UnityObjectToWorldNormal(v.normal);
    
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                //calculate uv top abs(wpos.xz) an assign as uv_top
                float2 uv_top = i.wpos.xz;
                //calculate uv right abs(wpos.yz) an assign as uv_right
                float2 uv_right = i.wpos.yz;
                //calculate uv forward abs(wpos.yx) an assign as uv_forward
                float2 uv_forward = i.wpos.yx;
                
                //tex2D (_MainTex, uv_top)...
                fixed4 col_top = tex2D(_MainTex, uv_top);
                fixed4 col_right = tex2D(_MainTex, uv_right);
                fixed4 col_forward = tex2D(_MainTex, uv_forward);

                half3 weights;
                weights.y = pow(abs(i.normal.y), _FallOff);
                weights.x = pow(abs(i.normal.x), _FallOff);
                weights.z = pow(abs(i.normal.z), _FallOff);

                weights = weights / (weights.x + weights.y + weights.z);

                col_top *= weights.y;
                col_right *= weights.x;
                col_forward *= weights.z;
                
                fixed4 col = col_top + col_forward + col_right;


                return col;
            }
            ENDCG
        }
    }
}
