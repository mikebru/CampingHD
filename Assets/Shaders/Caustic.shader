// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Caustic"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 15
		_Albedo("Albedo", 2D) = "white" {}
		_Intensity("Intensity", Float) = 0.1
		_Tint("Tint", Color) = (1,1,1,0)
		_Speed("Speed", Float) = 0.1
		[HDR]_EmissionColor("EmissionColor", Color) = (1,1,1,0)
		[HDR]_Emission2("Emission2", Color) = (1,1,1,0)
		_Remap("Remap", Vector) = (0,1,0,1)
		_EmissionTexture("EmissionTexture", 2D) = "white" {}
		_FlowMap("FlowMap", 2D) = "white" {}
		_Tiling("Tiling", Vector) = (0,0,0,0)
		_Displace("Displace", Range( -1 , 1)) = 0.1
		_Wavespeed("Wave speed", Range( 0 , 2)) = 0
		_NormalValues("Normal Values", Vector) = (0.5,2,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform float _Displace;
		uniform float _Wavespeed;
		uniform sampler2D _EmissionTexture;
		uniform float4 _Tiling;
		uniform sampler2D _FlowMap;
		uniform float _Speed;
		uniform float _Intensity;
		uniform float2 _NormalValues;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _Tint;
		uniform float4 _Remap;
		uniform float4 _EmissionColor;
		uniform float4 _Emission2;
		uniform float _EdgeLength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_vertexNormal = v.normal.xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float mulTime65 = _Time.y * _Wavespeed;
			float4 _Vector1 = float4(-2,2,0,1);
			v.vertex.xyz += ( ase_vertexNormal * _Displace * (_Vector1.z + (( sin( ( ase_vertex3Pos.x * mulTime65 ) ) + sin( ( ase_vertex3Pos.z * ( mulTime65 * 0.33 ) ) ) ) - _Vector1.x) * (_Vector1.w - _Vector1.z) / (_Vector1.y - _Vector1.x)) );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TexCoord30 = i.uv_texcoord * (_Tiling).xy;
			float mulTime22 = _Time.y * _Speed;
			float cos31 = cos( mulTime22 );
			float sin31 = sin( mulTime22 );
			float2 rotator31 = mul( float2( 0,0 ) - float2( 0.5,0.5 ) , float2x2( cos31 , -sin31 , sin31 , cos31 )) + float2( 0.5,0.5 );
			float2 uv_TexCoord28 = i.uv_texcoord * (_Tiling).zw + ( ( tex2D( _FlowMap, uv_TexCoord30 ).r + rotator31 ) * _Intensity );
			float2 temp_output_2_0_g1 = uv_TexCoord28;
			float2 break6_g1 = temp_output_2_0_g1;
			float temp_output_25_0_g1 = ( pow( _NormalValues.x , 3.0 ) * 0.1 );
			float2 appendResult8_g1 = (float2(( break6_g1.x + temp_output_25_0_g1 ) , break6_g1.y));
			float4 tex2DNode14_g1 = tex2D( _EmissionTexture, temp_output_2_0_g1 );
			float temp_output_4_0_g1 = _NormalValues.y;
			float3 appendResult13_g1 = (float3(1.0 , 0.0 , ( ( tex2D( _EmissionTexture, appendResult8_g1 ).g - tex2DNode14_g1.g ) * temp_output_4_0_g1 )));
			float2 appendResult9_g1 = (float2(break6_g1.x , ( break6_g1.y + temp_output_25_0_g1 )));
			float3 appendResult16_g1 = (float3(0.0 , 1.0 , ( ( tex2D( _EmissionTexture, appendResult9_g1 ).g - tex2DNode14_g1.g ) * temp_output_4_0_g1 )));
			float3 normalizeResult22_g1 = normalize( cross( appendResult13_g1 , appendResult16_g1 ) );
			o.Normal = normalizeResult22_g1;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			o.Albedo = ( tex2D( _Albedo, uv_Albedo ) * _Tint ).rgb;
			float4 tex2DNode6 = tex2D( _EmissionTexture, uv_TexCoord28 );
			float temp_output_38_0 = (_Remap.z + (tex2DNode6.r - _Remap.x) * (_Remap.w - _Remap.z) / (_Remap.y - _Remap.x));
			float4 lerpResult51 = lerp( _EmissionColor , _Emission2 , tex2DNode6.r);
			o.Emission = ( temp_output_38_0 * i.vertexColor.r * lerpResult51 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16700
7;23;1906;1010;-13.16211;281.2162;1;True;True
Node;AmplifyShaderEditor.Vector4Node;53;-3370.346,813.8837;Float;False;Property;_Tiling;Tiling;16;0;Create;True;0;0;False;0;0,0,0,0;80,80,10,10;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-2400.038,662.9824;Float;False;Property;_Speed;Speed;10;0;Create;True;0;0;False;0;0.1;0.07;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;54;-2936.54,524.942;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;33;-2273.936,386.3874;Float;False;Constant;_Vector0;Vector 0;7;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TexturePropertyNode;52;-3027.334,-183.9381;Float;True;Property;_FlowMap;FlowMap;15;0;Create;True;0;0;False;0;None;cd460ee4ac5c1e746b7a734cc7cc64dd;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleTimeNode;22;-2139.221,699.837;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;30;-2577.22,248.6888;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;66;-744.3363,1246.92;Float;False;Property;_Wavespeed;Wave speed;18;0;Create;True;0;0;False;0;0;1.297;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;31;-1982.952,366.097;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;29;-2212.594,117.3323;Float;True;Property;_scaledFlow;scaledFlow;1;0;Create;True;0;0;False;0;None;cd460ee4ac5c1e746b7a734cc7cc64dd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;65;-374.9657,1233.058;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-394.7158,1115.98;Float;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;False;0;0.33;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-1691.241,333.5711;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1685.399,522.8922;Float;False;Property;_Intensity;Intensity;8;0;Create;True;0;0;False;0;0.1;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;62;-357.8058,920.2479;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-107.0691,1117.532;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;55;-2619.613,1015.753;Float;True;False;False;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1510.851,410.6936;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;15.6637,995.9199;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;12.6637,883.9199;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;80;-1671.326,-358.895;Float;True;Property;_EmissionTexture;EmissionTexture;14;0;Create;True;0;0;False;0;None;9fbef4b79ca3b784ba023cb1331520d5;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-1373.531,637.2084;Float;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;70;219.6637,994.9199;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;69;213.6637,900.9199;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-1223.847,-11.05523;Float;True;Property;_EmissionTex;EmissionTex;0;0;Create;True;0;0;False;0;None;9fbef4b79ca3b784ba023cb1331520d5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;73;222.5236,1127.934;Float;False;Constant;_Vector1;Vector 1;12;0;Create;True;0;0;False;0;-2,2,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;50;-779.5029,715.0001;Float;False;Property;_Emission2;Emission2;12;1;[HDR];Create;True;0;0;False;0;1,1,1,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;37;-794.8661,504.3987;Float;False;Property;_EmissionColor;EmissionColor;11;1;[HDR];Create;True;0;0;False;0;1,1,1,0;0,0.2130444,0.3372549,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;39;-1102.025,266.1973;Float;False;Property;_Remap;Remap;13;0;Create;True;0;0;False;0;0,1,0,1;0.06,0.08,0,0.1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;71;401.6637,952.9199;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;91.98644,555.2076;Float;False;Property;_Displace;Displace;17;0;Create;True;0;0;False;0;0.1;-0.003;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;34;-698.6237,260.3297;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;51;-355.1052,645.4266;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;72;576.3638,849.8198;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;38;-709.3403,32.98384;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-650.5,-201;Float;False;Property;_Tint;Tint;9;0;Create;True;0;0;False;0;1,1,1,0;0.1509432,0.1509432,0.1509432,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;59;143.5735,400.8428;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-668,-417;Float;True;Property;_Albedo;Albedo;7;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;81;127.2249,108.9884;Float;False;Property;_NormalValues;Normal Values;19;0;Create;True;0;0;False;0;0.5,2;-1.4,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SummedBlendNode;74;-21.75415,265.7092;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;75;407.5178,63.24365;Float;True;NormalCreate;5;;1;e12f7ae19d416b942820e3932b56220f;0;4;1;SAMPLER2D;;False;2;FLOAT2;0,0;False;3;FLOAT;0.5;False;4;FLOAT;2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-188.5,-177;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;58;-2483.837,-322.1696;Float;False;Constant;_InputPosition;Input Position;10;0;Create;True;0;0;False;0;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;24;-1839.045,597.0031;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-287.5641,48.04149;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;752.8638,339.5928;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1117.6,-67.3;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;Caustic;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;54;0;53;0
WireConnection;22;0;23;0
WireConnection;30;0;54;0
WireConnection;31;1;33;0
WireConnection;31;2;22;0
WireConnection;29;0;52;0
WireConnection;29;1;30;0
WireConnection;65;0;66;0
WireConnection;25;0;29;1
WireConnection;25;1;31;0
WireConnection;67;0;65;0
WireConnection;67;1;68;0
WireConnection;55;0;53;0
WireConnection;27;0;25;0
WireConnection;27;1;26;0
WireConnection;64;0;62;3
WireConnection;64;1;67;0
WireConnection;63;0;62;1
WireConnection;63;1;65;0
WireConnection;28;0;55;0
WireConnection;28;1;27;0
WireConnection;70;0;64;0
WireConnection;69;0;63;0
WireConnection;6;0;80;0
WireConnection;6;1;28;0
WireConnection;71;0;69;0
WireConnection;71;1;70;0
WireConnection;51;0;37;0
WireConnection;51;1;50;0
WireConnection;51;2;6;1
WireConnection;72;0;71;0
WireConnection;72;1;73;1
WireConnection;72;2;73;2
WireConnection;72;3;73;3
WireConnection;72;4;73;4
WireConnection;38;0;6;1
WireConnection;38;1;39;1
WireConnection;38;2;39;2
WireConnection;38;3;39;3
WireConnection;38;4;39;4
WireConnection;74;0;38;0
WireConnection;75;1;80;0
WireConnection;75;2;28;0
WireConnection;75;3;81;1
WireConnection;75;4;81;2
WireConnection;5;0;1;0
WireConnection;5;1;4;0
WireConnection;24;1;22;0
WireConnection;36;0;38;0
WireConnection;36;1;34;1
WireConnection;36;2;51;0
WireConnection;60;0;59;0
WireConnection;60;1;61;0
WireConnection;60;2;72;0
WireConnection;0;0;5;0
WireConnection;0;1;75;0
WireConnection;0;2;36;0
WireConnection;0;11;60;0
ASEEND*/
//CHKSM=2D777A5C1D0F35D9CBFC448DE9C41766957BD8C6