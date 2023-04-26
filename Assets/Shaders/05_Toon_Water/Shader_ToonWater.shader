Shader "05/Shader_ToonWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GrayScaleTex ("Grayscale texture", 2D) = "white" {}
        _WaveSpeed ("Wave speed", float) = (1, 0, 0, 0)
        _WaveHeight ("Wave height", Range(0, 1)) = 0.5
        _WaveFrequency ("Wave frequency", Range(0, 10)) = 1
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

            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
            };

            // Declare variables
            float4 _MainTex_ST;

            float4 _WaveSpeed;
            float _WaveHeight;
            float _WaveFrequency;
            sampler2D _MainTex;
            sampler2D _GrayScaleTex;

            float offset;

            // Vertex shader function
            v2f vert(appdata v)
            {
                v2f o;
                offset = _WaveHeight * sin(_WaveFrequency * v.vertex.x + _WaveSpeed.x * _Time.y);

                v.vertex.y += offset;
                o.pos = UnityObjectToClipPos(v.vertex);

                // Calculate the displacement of the vertex
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                // Apply the displacement to the vertex position
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = worldPos;

                return o;
            }

            // Fragment shader function
            fixed4 frag(v2f i) : SV_Target
            {
                // Sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 _grayScaleCol = tex2D(_GrayScaleTex, float2(offset, 1));

                return col * _grayScaleCol;
            }

            ENDCG
        }
    }
}
