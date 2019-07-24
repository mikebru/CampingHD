// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Amplify/PortalAmplify"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_LeftTex("_LeftTex", 2D) = "white" {}
		_FlowMap("FlowMap", 2D) = "white" {}
		_DistanceMultiplier("DistanceMultiplier", Range( 0 , 10)) = 0.5
		_inputPos1("inputPos1", Vector) = (0,0,0,0)
		_inputPos2("inputPos2", Vector) = (0,0,0,0)
		_inputPos3("inputPos3", Vector) = (0,0,0,0)
		_Intensity("Intensity", Float) = 0.1
		_Speed("Speed", Float) = 0.1
		_Thickness("Thickness", Range( 0 , 1)) = 0.5
		_EdgeCutoff("EdgeCutoff", Range( 0 , 1)) = 0.5
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform sampler2D _LeftTex;
		uniform float _DistanceMultiplier;
		uniform float3 _inputPos1;
		uniform float3 _inputPos2;
		uniform float3 _inputPos3;
		uniform sampler2D _FlowMap;
		uniform float _Speed;
		uniform float _Intensity;
		uniform float _EdgeCutoff;
		uniform float _Thickness;
		uniform float4 _EmissionColor;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos3 = UnityObjectToClipPos( ase_vertex3Pos );
			float4 computeScreenPos4 = ComputeScreenPos( unityObjectToClipPos3 );
			float2 temp_output_7_0 = ( (computeScreenPos4).xy / (computeScreenPos4).w );
			float4 tex2DNode9 = tex2D( _LeftTex, temp_output_7_0 );
			float4 appendResult17 = (float4(tex2DNode9.r , tex2DNode9.g , tex2DNode9.b , 0.0));
			float3 ase_worldPos = i.worldPos;
			float temp_output_28_0 = ( _DistanceMultiplier * distance( _inputPos1 , ase_worldPos ) );
			float clampResult27 = clamp( ( 1.0 - ( temp_output_28_0 * temp_output_28_0 ) ) , 0.0 , 1.0 );
			float temp_output_32_0 = ( _DistanceMultiplier * distance( _inputPos2 , ase_worldPos ) );
			float clampResult35 = clamp( ( 1.0 - ( temp_output_32_0 * temp_output_32_0 ) ) , 0.0 , 1.0 );
			float temp_output_42_0 = ( _DistanceMultiplier * distance( _inputPos3 , ase_worldPos ) );
			float clampResult45 = clamp( ( 1.0 - ( temp_output_42_0 * temp_output_42_0 ) ) , 0.0 , 1.0 );
			float temp_output_38_0 = ( clampResult27 + clampResult35 + clampResult45 );
			float2 uv_TexCoord62 = i.uv_texcoord * float2( 4,4 );
			float mulTime57 = _Time.y * _Speed;
			float cos58 = cos( mulTime57 );
			float sin58 = sin( mulTime57 );
			float2 rotator58 = mul( float2( 0,0 ) - float2( 0.5,0.5 ) , float2x2( cos58 , -sin58 , sin58 , cos58 )) + float2( 0.5,0.5 );
			float2 uv_TexCoord53 = i.uv_texcoord + ( ( tex2D( _FlowMap, uv_TexCoord62 ).r + rotator58 ) * _Intensity );
			float temp_output_52_0 = ( temp_output_38_0 + ( temp_output_38_0 * tex2D( _FlowMap, uv_TexCoord53 ).r ) );
			o.Emission = ( appendResult17 + ( ( step( temp_output_52_0 , ( _EdgeCutoff + _Thickness ) ) - step( temp_output_52_0 , _EdgeCutoff ) ) * _EmissionColor ) ).xyz;
			o.Alpha = temp_output_52_0;
			clip( temp_output_52_0 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16800
-1913;1;1906;1051;2108.115;1535.681;2.097476;True;True
Node;AmplifyShaderEditor.CommentaryNode;29;102.212,150.7717;Float;False;1248.043;478.2759;Position Input 1;7;18;27;22;25;28;20;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;30;148.1252,668.7885;Float;False;1248.043;478.2759;Position Input 1;6;36;35;34;33;32;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;39;125.3296,1192.853;Float;False;1248.043;478.2759;Position Input 1;6;45;44;43;42;41;40;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;36;174.059,806.3213;Float;False;Property;_inputPos2;inputPos2;7;0;Create;True;0;0;False;0;0,0,0;-0.2,-1.788,-1.49;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;40;151.2634,1330.385;Float;False;Property;_inputPos3;inputPos3;8;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;19;161.3087,441.223;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;18;169.0579,200.6355;Float;False;Property;_inputPos1;inputPos1;6;0;Create;True;0;0;False;0;0,0,0;0.713,-1.87,1.419;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;60;23.51784,2362.282;Float;False;Property;_Speed;Speed;10;0;Create;True;0;0;False;0;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;63;127.8099,1714.797;Float;True;Property;_FlowMap;FlowMap;3;0;Create;True;0;0;False;0;None;cd460ee4ac5c1e746b7a734cc7cc64dd;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.Vector2Node;59;416.6179,2186.319;Float;False;Constant;_Vector0;Vector 0;7;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DistanceOpNode;41;502.2603,1362.488;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;20;479.1425,320.407;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;57;437.0827,2366.301;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;284.52,52.3962;Float;False;Property;_DistanceMultiplier;DistanceMultiplier;5;0;Create;True;0;0;False;0;0.5;0.66;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;31;525.0558,838.4238;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;62;131.6399,1989.819;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;4,4;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;705.9307,1336.439;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;682.8128,294.3576;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;58;778.7897,2208.798;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;61;551.2659,1752.463;Float;True;Property;_scaledFlow;scaledFlow;1;0;Create;True;0;0;False;0;None;cd460ee4ac5c1e746b7a734cc7cc64dd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;728.7262,812.3744;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;847.4236,279.8763;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;1037.551,2213.004;Float;False;Property;_Intensity;Intensity;9;0;Create;True;0;0;False;0;0.1;0.55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;893.3369,797.8931;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;870.5414,1321.957;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;1072.619,1968.701;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;44;1009.781,1321.415;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;22;986.6626,279.3335;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;1253.009,2045.824;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;34;1032.576,797.3503;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;53;1442.184,1830.444;Float;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;45;1176.016,1322.78;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;35;1198.812,798.7156;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;27;1152.899,280.6988;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;2;-755,-131;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;38;1500.876,755.0691;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;46;1694.386,1604.781;Float;True;Property;_NoiseMap;NoiseMap;2;0;Create;True;0;0;False;0;None;1250643187cd6e84f873b5efc80f049d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;3;-495,-127;Float;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;74;2058.839,706.5127;Float;False;Property;_Thickness;Thickness;11;0;Create;True;0;0;False;0;0.5;0.127;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;1811.748,957.9319;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;2059.412,840.4797;Float;False;Property;_EdgeCutoff;EdgeCutoff;12;0;Create;True;0;0;False;0;0.5;0.462;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;4;-259,-124;Float;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;5;14,-230;Float;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;6;27,-125;Float;False;FLOAT;3;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;2362.839,689.5127;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;1997.249,337.7822;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;7;215,-217;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;65;2512.819,555.9064;Float;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;66;2505,845.1417;Float;True;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;67;2810,690.1417;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;688.6174,-302.7462;Float;True;Property;_LeftTex;_LeftTex;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;79;2869.089,1067.213;Float;False;Property;_EmissionColor;EmissionColor;13;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,4.759381,3.624006,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;17;2993.805,-198.3292;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;3103.536,701.6058;Float;True;2;2;0;FLOAT;0;False;1;COLOR;2,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;10;526.5797,-768.2124;Float;True;Property;_RightTex;_RightTex;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;533.6792,-871.6398;Float;False;Property;_RecursiveRender;_RecursiveRender;4;1;[Toggle];Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;3462.444,12.16168;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;77;3652.732,-136.9227;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Amplify/PortalAmplify;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;41;0;40;0
WireConnection;41;1;19;0
WireConnection;20;0;18;0
WireConnection;20;1;19;0
WireConnection;57;0;60;0
WireConnection;31;0;36;0
WireConnection;31;1;19;0
WireConnection;42;0;15;0
WireConnection;42;1;41;0
WireConnection;28;0;15;0
WireConnection;28;1;20;0
WireConnection;58;1;59;0
WireConnection;58;2;57;0
WireConnection;61;0;63;0
WireConnection;61;1;62;0
WireConnection;32;0;15;0
WireConnection;32;1;31;0
WireConnection;25;0;28;0
WireConnection;25;1;28;0
WireConnection;33;0;32;0
WireConnection;33;1;32;0
WireConnection;43;0;42;0
WireConnection;43;1;42;0
WireConnection;56;0;61;1
WireConnection;56;1;58;0
WireConnection;44;0;43;0
WireConnection;22;0;25;0
WireConnection;54;0;56;0
WireConnection;54;1;55;0
WireConnection;34;0;33;0
WireConnection;53;1;54;0
WireConnection;45;0;44;0
WireConnection;35;0;34;0
WireConnection;27;0;22;0
WireConnection;38;0;27;0
WireConnection;38;1;35;0
WireConnection;38;2;45;0
WireConnection;46;0;63;0
WireConnection;46;1;53;0
WireConnection;3;0;2;0
WireConnection;51;0;38;0
WireConnection;51;1;46;1
WireConnection;4;0;3;0
WireConnection;5;0;4;0
WireConnection;6;0;4;0
WireConnection;73;0;72;0
WireConnection;73;1;74;0
WireConnection;52;0;38;0
WireConnection;52;1;51;0
WireConnection;7;0;5;0
WireConnection;7;1;6;0
WireConnection;65;0;52;0
WireConnection;65;1;73;0
WireConnection;66;0;52;0
WireConnection;66;1;72;0
WireConnection;67;0;65;0
WireConnection;67;1;66;0
WireConnection;9;1;7;0
WireConnection;17;0;9;1
WireConnection;17;1;9;2
WireConnection;17;2;9;3
WireConnection;69;0;67;0
WireConnection;69;1;79;0
WireConnection;10;1;7;0
WireConnection;80;0;17;0
WireConnection;80;1;69;0
WireConnection;77;2;80;0
WireConnection;77;9;52;0
WireConnection;77;10;52;0
ASEEND*/
//CHKSM=28DD8769D57AA7E82A722136FB8E8CD1B7CB4206