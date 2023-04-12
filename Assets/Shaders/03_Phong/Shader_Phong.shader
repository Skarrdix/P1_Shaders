Shader "03/Unlit/Shader_Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AmbientCol ("Ambient light color", Color) = (0.25, 0.25, 0.35, 1) // NEW
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags {"Lightmode" = "ForwardBase"} // NEW

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal : NORMAL; // NEW
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 normal : NORMAL; // NEW
                half3 wpos : TEXCOORD1; // NEW
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _AmbientCol; // NEW

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal); // NEW
                o.wpos = mul((float3x3)unity_ObjectToWorld, v.vertex); // NEW
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture

                fixed4 col = tex2D(_MainTex, i.uv);

                half3 viewDir = normalize(i.wpos - _WorldSpaceCameraPos); // NEW
                half lightDir = _WorldSpaceLightPos0.xyz * (1 - _WorldSpaceLightPos0.w); // NEW

                half3 ambient = half3(0, 0, 0); // NEW
                half3 diffuse = half3(0, 0, 0); // NEW
                half3 specular = half3(0, 0, 0); // NEW

                ambient = _AmbientCol; // NEW
                diffuse = unity_LightColor0.rgb * max(0.0, dot(i.normal, lightDir)); // NEW
                specular; // NEW

                return col;
            }

            ENDCG
        }
    }
}