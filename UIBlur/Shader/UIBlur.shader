Shader "Custom/UIBlur"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(IS_BLUR_ALPHA_MASKED)] _IsAlphaMasked("Image Alpha Masks Blur", Float) = 1
		
		[Space]
		
		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255

		_ColorMask("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		
		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
			Name "Default"
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ IS_BLUR_ALPHA_MASKED
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				float4 grabPos  : TEXCOORD2;
			};
			
			sampler2D _BlurTexture;
			sampler2D _MainTex;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				#ifdef UNITY_HALF_TEXEL_OFFSET
					OUT.vertex.xy += (_ScreenParams.zw-1.0) * float2(-1,1) * OUT.vertex.w;
				#endif

				OUT.grabPos = ComputeGrabScreenPos(OUT.vertex);

				#if UNITY_UV_STARTS_AT_TOP
					OUT.grabPos.y = 1.0 - OUT.grabPos.y;
				#endif

				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color;
				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				#if IS_BLUR_ALPHA_MASKED
					half4 maskCol = tex2D(_MainTex, IN.texcoord);
					float alpha = maskCol.a * IN.color.a;
				#else
					float alpha = IN.color.a;
				#endif

				return half4(tex2Dproj(_BlurTexture, IN.grabPos).rgb * IN.color.rgb, alpha);
			}
		ENDCG
		}
	}
}
