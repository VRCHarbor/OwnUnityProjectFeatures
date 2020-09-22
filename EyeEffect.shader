Shader "Harbor/EyeEffect"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_Color2 ("Color2", Color) = (0,0,0,1)
		_Color3 ("Color3", Color) = (0,0,0,1)
		_Color4 ("Color4", Color) = (0,0,0,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_CheckTex ("Checmate texture offsets", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.0
		
		[HDR] _ColorHDR("HDR", Color) = (1,1,1,1)

		_EyeRadius("EyeRadius", Range(0, 1)) = 0.1
		_EyeWidth("EyeWidth", Range(0,1)) = 1
		_EyeGradientOffset("EyeGradientOffset", Range(0,1)) = 1
		
		_SinWidth("SinWidth", Range(0,1000)) = 10
		_SinSpeed("SinSpeed", range(0,100)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		#define ROUNDS

        sampler2D _MainTex;
		uniform float4 _MainTex_TexelSize;
		//uniform float4 _MainTex_ST;

		half _EyeWidth;
		half _EyeRadius;
		half _EyeGradientOffset;

		half _SinWidth;
		half _SinSpeed;

		half GradientByOfset(float2 UV, half A, half B, half P, fixed offset = 0.5) {
			half val = sqrt(pow(UV.x - offset, 2) + pow(UV.y - offset, 2));
			return val < P ? (val - A) / (P - A != 0 ? P - A : 1) : (B - val) / (B - P != 0 ? B - P : 1);
		}


        struct Input
        {
			float2 uv_MainTex;
			float2 uv_CheckTex;
        };


        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
		fixed4 _Color2;
		fixed4 _Color3;
		fixed4 _Color4;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
			bool IsRound;
			fixed2 offset = 0.5;
			float2 center = float2(0.5, 0.5);
			#ifdef ROUND
			IsRound = (true);
			#else
			IsRound = (pow(IN.uv_MainTex.x - offset.x, 2) + pow(IN.uv_MainTex.y - offset.y, 2)) < pow(_EyeRadius, 2);
			IsRound = IsRound && (pow(IN.uv_MainTex.x - offset.x, 2) + pow(IN.uv_MainTex.y - offset.y, 2)) > pow(_EyeRadius*(1 - _EyeWidth),2);
			#endif

			
			half OffPoint = ((_EyeRadius - (_EyeRadius * _EyeWidth)) + (_EyeRadius - (_EyeRadius - (_EyeRadius * _EyeWidth))) * _EyeGradientOffset);


			float round = IsRound ? 
				GradientByOfset(IN.uv_MainTex, 
					_EyeRadius - (_EyeRadius * _EyeWidth),
					_EyeRadius,
					(OffPoint - (sin(_Time.y) * (OffPoint - (_EyeRadius - (_EyeRadius * _EyeWidth))/2) - offset))
				) : 0;

			float insideRound = (pow(IN.uv_MainTex.x - offset.x, 2) + pow(IN.uv_MainTex.y - offset.y, 2)) < pow(_EyeRadius * (1 - _EyeWidth), 2)? 1:0;
			float checkmate = IN.uv_CheckTex.x % 1 > 0.5 ^ IN.uv_CheckTex.y % 1> 0.5 ? 1 : 0; //sin(IN.uv_MainTex.x ) * cos(IN.uv_MainTex.y );
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) *_Color * checkmate * round;
			c += tex2D(_MainTex, IN.uv_MainTex) * _Color2 * (1 - checkmate) * round;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness * round;
            o.Alpha = c.a;
			o.Emission = 
				insideRound * frac(sin(IN.uv_MainTex.x * _SinWidth + _Time.y * _SinSpeed)) * _Color3 * pow(IN.uv_MainTex.x,2) + 
				_Color2 * (1 - checkmate) * round * pow(IN.uv_MainTex.x,2) + 
				_Color * (checkmate) * round * pow(1 - IN.uv_MainTex.x, 2) + 
				insideRound * (1 - frac(sin(IN.uv_MainTex.x * _SinWidth + _Time.y * _SinSpeed))) * _Color4 * pow(1 - IN.uv_MainTex.x, 2);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
