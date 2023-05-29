Shader "Unlit/PostProcess"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PrePass ("PrePass", 2D) = "white" {}
        _MipLVL ("Mip Level", Range(0,10)) = 1
        _Distance ("Distance", Range(0,1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        /// PASS 0 - Mask
        Pass
        {
            name "Mask"
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _PrePass;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return float4(1,1,1,1);
            }
            ENDCG
        }

        /// PASS 1 - Glow
        Pass
        {
            name "Glow"
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _PrePass;
            float4 _MainTex_ST, _MainTex_TexelSize;
            float _MipLVL, _Distance;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 sum = fixed4(0.0, 0.0, 0.0, 0.0);

                sum += tex2Dlod(_MainTex, half4(i.uv.x, i.uv.y - 4.0 * 0.05 * _Distance * _MainTex_TexelSize.y, 0, _MipLVL)) * 0.05;
                sum += tex2Dlod(_MainTex, half4(i.uv.x, i.uv.y - 3.0 * 0.05 * _Distance * _MainTex_TexelSize.y,0 , _MipLVL)) * 0.09;
                sum += tex2Dlod(_MainTex, half4(i.uv.x, i.uv.y - 2.0 * 0.05 * _Distance * _MainTex_TexelSize.y,0, _MipLVL)) * 0.12;
                sum += tex2Dlod(_MainTex, half4(i.uv.x, i.uv.y,0,6)) * 0.16;
                sum += tex2Dlod(_MainTex, half4(i.uv.x, i.uv.y + 2.0 * 0.05 * _Distance * _MainTex_TexelSize.y,0, _MipLVL)) * 0.12;
                sum += tex2Dlod(_MainTex, half4(i.uv.x, i.uv.y + 3.0 * 0.05 * _Distance * _MainTex_TexelSize.y,0, _MipLVL)) * 0.09;
                sum += tex2Dlod(_MainTex, half4(i.uv.x, i.uv.y + 4.0 * 0.05 * _Distance * _MainTex_TexelSize.y,0, _MipLVL)) * 0.05;

                sum += tex2Dlod(_MainTex, half4(i.uv.x - 4.0 * 0.05 * _Distance * _MainTex_TexelSize.x, i.uv.y, 0, _MipLVL)) * 0.05;
                sum += tex2Dlod(_MainTex, half4(i.uv.x - 3.0 * 0.05 * _Distance * _MainTex_TexelSize.x, i.uv.y, 0 , _MipLVL)) * 0.09;
                sum += tex2Dlod(_MainTex, half4(i.uv.x - 2.0 * 0.05 * _Distance * _MainTex_TexelSize.x,i.uv.y, 0, _MipLVL)) * 0.12;
                sum += tex2Dlod(_MainTex, half4(i.uv.x, i.uv.y,0,6)) * 0.16;
                sum += tex2Dlod(_MainTex, half4(i.uv.x + 2.0 * 0.05 * _Distance * _MainTex_TexelSize.x, i.uv.y, 0, _MipLVL)) * 0.12;
                sum += tex2Dlod(_MainTex, half4(i.uv.x + 3.0 * 0.05 * _Distance * _MainTex_TexelSize.x, i.uv.y,0, _MipLVL)) * 0.09;
                sum += tex2Dlod(_MainTex, half4(i.uv.x + 4.0 * 0.05 * _Distance * _MainTex_TexelSize.x, i.uv.y,0, _MipLVL)) * 0.05;

                return saturate(sum) - col;
            }
                ENDCG
        }

        /// PASS 2 - Additive
        Pass
        {
            name "Additive"
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _PrePass;
            float4 _MainTex_ST, _MainTex_TexelSize;
            float _MipLVL, _Distance;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
                //TODO Additive
            }

            ENDCG
        }
    }
}
