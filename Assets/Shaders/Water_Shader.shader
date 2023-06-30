Shader "Water_Graph"
{
    Properties
    {
        _BaseColor("BaseColor", Color) = (0, 0.7098846, 1, 0)
        _RippleSpeed("RippleSpeed", Float) = 1
        _RippleDensity("RippleDensity", Float) = 7
        _RipplePower("RipplePower", Float) = 5
        _RippleColor("RippleColor", Color) = (0.240566, 1, 1, 0)
        _WaveSpeed("WaveSpeed", Float) = 0.1
        [HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
        [HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
    }
        SubShader
    {
        Tags
        {
            // RenderPipeline: <None>
            "RenderType" = "Transparent"
            "BuiltInMaterialType" = "Lit"
            "Queue" = "Transparent"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "BuiltInLitSubTarget"
        }
        Pass
        {
            Name "BuiltIn Forward"
            Tags
            {
                "LightMode" = "ForwardBase"
            }

        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask RGB

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile_fwdbase
        #pragma vertex vert
        #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>

        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
             float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz = input.positionWS;
            output.interp1.xyz = input.normalWS;
            output.interp2.xyzw = input.tangentWS;
            output.interp3.xyzw = input.texCoord0;
            output.interp4.xyz = input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz = input.sh;
            #endif
            output.interp7.xyzw = input.fogFactorAndVertexLight;
            output.interp8.xyzw = input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        float _RippleSpeed;
        float _RippleDensity;
        float _RipplePower;
        float4 _RippleColor;
        float _WaveSpeed;
        CBUFFER_END

            // Object and Global properties

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

        // Graph Includes
        // GraphIncludes: <None>

        // Graph Functions

        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }


        inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for (int y = -1; y <= 1; y++)
            {
                for (int x = -1; x <= 1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if (d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_8621dfa301704db7bbde7355c312c130_Out_0 = _BaseColor;
            float4 _Property_5e7dbe3484e04d8e9641efbad610fceb_Out_0 = _RippleColor;
            float _Property_097fd7fd07f243d7a8ac877e1fe6f02a_Out_0 = _RippleSpeed;
            float _Multiply_9fb8a098e320416aac47090f7007565d_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_097fd7fd07f243d7a8ac877e1fe6f02a_Out_0, _Multiply_9fb8a098e320416aac47090f7007565d_Out_2);
            float _Property_6669dc7aeaf24b79a7e62166c0b64a34_Out_0 = _RippleDensity;
            float _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Out_3;
            float _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Cells_4;
            Unity_Voronoi_float(IN.uv0.xy, _Multiply_9fb8a098e320416aac47090f7007565d_Out_2, _Property_6669dc7aeaf24b79a7e62166c0b64a34_Out_0, _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Out_3, _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Cells_4);
            float _Property_c5010c9feb18420e866699165ecd3028_Out_0 = _RipplePower;
            float _Power_4bd71a9692d7403f8aaa66633c25403a_Out_2;
            Unity_Power_float(_Voronoi_da73fc8471c7472ab8db3ff4780873a8_Out_3, _Property_c5010c9feb18420e866699165ecd3028_Out_0, _Power_4bd71a9692d7403f8aaa66633c25403a_Out_2);
            float4 _Multiply_52b50b11cdde4506a1ad42fd8d39a335_Out_2;
            Unity_Multiply_float4_float4(_Property_5e7dbe3484e04d8e9641efbad610fceb_Out_0, (_Power_4bd71a9692d7403f8aaa66633c25403a_Out_2.xxxx), _Multiply_52b50b11cdde4506a1ad42fd8d39a335_Out_2);
            float4 _Add_45a9a28fb1f242429167631ec284e16a_Out_2;
            Unity_Add_float4(_Property_8621dfa301704db7bbde7355c312c130_Out_0, _Multiply_52b50b11cdde4506a1ad42fd8d39a335_Out_2, _Add_45a9a28fb1f242429167631ec284e16a_Out_2);
            surface.BaseColor = (_Add_45a9a28fb1f242429167631ec284e16a_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = 0.4;
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs

        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal = input.normalOS;
            output.ObjectSpaceTangent = input.tangentOS.xyz;
            output.ObjectSpacePosition = input.positionOS;

            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
        }

        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex = float4(attributes.positionOS, 1);
            result.tangent = attributes.tangentOS;
            result.normal = attributes.normalOS;
            result.texcoord = attributes.uv0;
            result.texcoord1 = attributes.uv1;
            result.vertex = float4(vertexDescription.Position, 1);
            result.normal = vertexDescription.Normal;
            result.tangent = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }

        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            result.viewDir = varyings.viewDirectionWS;
            // World Tangent isn't an available input on v2f_surf

            result._ShadowCoord = varyings.shadowCoord;

            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = varyings.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif

            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }

        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;

            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = surfVertex.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif

            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

        ENDHLSL
        }
        Pass
        {
            Name "BuiltIn ForwardAdd"
            Tags
            {
                "LightMode" = "ForwardAdd"
            }

            // Render State
            Blend SrcAlpha One
            ZWrite Off
            ColorMask RGB

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma multi_compile_fwdadd_fullshadows
            #pragma vertex vert
            #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD_ADD
            #define BUILTIN_TARGET_API 1
            #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
            #endif
            #ifdef _BUILTIN_ALPHATEST_ON
            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
            #endif
            #ifdef _BUILTIN_AlphaClip
            #define _AlphaClip _BUILTIN_AlphaClip
            #endif
            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
            #endif


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                 float4 uv1 : TEXCOORD1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 positionWS;
                 float3 normalWS;
                 float4 tangentWS;
                 float4 texCoord0;
                 float3 viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                 float2 lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                 float3 sh;
                #endif
                 float4 fogFactorAndVertexLight;
                 float4 shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float3 TangentSpaceNormal;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float3 interp1 : INTERP1;
                 float4 interp2 : INTERP2;
                 float4 interp3 : INTERP3;
                 float3 interp4 : INTERP4;
                 float2 interp5 : INTERP5;
                 float3 interp6 : INTERP6;
                 float4 interp7 : INTERP7;
                 float4 interp8 : INTERP8;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz = input.positionWS;
                output.interp1.xyz = input.normalWS;
                output.interp2.xyzw = input.tangentWS;
                output.interp3.xyzw = input.texCoord0;
                output.interp4.xyz = input.viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                output.interp5.xy = input.lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.interp6.xyz = input.sh;
                #endif
                output.interp7.xyzw = input.fogFactorAndVertexLight;
                output.interp8.xyzw = input.shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp0.xyz;
                output.normalWS = input.interp1.xyz;
                output.tangentWS = input.interp2.xyzw;
                output.texCoord0 = input.interp3.xyzw;
                output.viewDirectionWS = input.interp4.xyz;
                #if defined(LIGHTMAP_ON)
                output.lightmapUV = input.interp5.xy;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.interp6.xyz;
                #endif
                output.fogFactorAndVertexLight = input.interp7.xyzw;
                output.shadowCoord = input.interp8.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }


            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseColor;
            float _RippleSpeed;
            float _RippleDensity;
            float _RipplePower;
            float4 _RippleColor;
            float _WaveSpeed;
            CBUFFER_END

                // Object and Global properties

                // -- Property used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Includes
            // GraphIncludes: <None>

            // Graph Functions

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }


            inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
            {
                float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                UV = frac(sin(mul(UV, m)));
                return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
            }

            void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
            {
                float2 g = floor(UV * CellDensity);
                float2 f = frac(UV * CellDensity);
                float t = 8.0;
                float3 res = float3(8.0, 0.0, 0.0);

                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 lattice = float2(x,y);
                        float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                        float d = distance(lattice + offset, f);

                        if (d < res.x)
                        {
                            res = float3(d, offset.x, offset.y);
                            Out = res.x;
                            Cells = res.y;
                        }
                    }
                }
            }

            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A + B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _Property_8621dfa301704db7bbde7355c312c130_Out_0 = _BaseColor;
                float4 _Property_5e7dbe3484e04d8e9641efbad610fceb_Out_0 = _RippleColor;
                float _Property_097fd7fd07f243d7a8ac877e1fe6f02a_Out_0 = _RippleSpeed;
                float _Multiply_9fb8a098e320416aac47090f7007565d_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_097fd7fd07f243d7a8ac877e1fe6f02a_Out_0, _Multiply_9fb8a098e320416aac47090f7007565d_Out_2);
                float _Property_6669dc7aeaf24b79a7e62166c0b64a34_Out_0 = _RippleDensity;
                float _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Out_3;
                float _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Cells_4;
                Unity_Voronoi_float(IN.uv0.xy, _Multiply_9fb8a098e320416aac47090f7007565d_Out_2, _Property_6669dc7aeaf24b79a7e62166c0b64a34_Out_0, _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Out_3, _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Cells_4);
                float _Property_c5010c9feb18420e866699165ecd3028_Out_0 = _RipplePower;
                float _Power_4bd71a9692d7403f8aaa66633c25403a_Out_2;
                Unity_Power_float(_Voronoi_da73fc8471c7472ab8db3ff4780873a8_Out_3, _Property_c5010c9feb18420e866699165ecd3028_Out_0, _Power_4bd71a9692d7403f8aaa66633c25403a_Out_2);
                float4 _Multiply_52b50b11cdde4506a1ad42fd8d39a335_Out_2;
                Unity_Multiply_float4_float4(_Property_5e7dbe3484e04d8e9641efbad610fceb_Out_0, (_Power_4bd71a9692d7403f8aaa66633c25403a_Out_2.xxxx), _Multiply_52b50b11cdde4506a1ad42fd8d39a335_Out_2);
                float4 _Add_45a9a28fb1f242429167631ec284e16a_Out_2;
                Unity_Add_float4(_Property_8621dfa301704db7bbde7355c312c130_Out_0, _Multiply_52b50b11cdde4506a1ad42fd8d39a335_Out_2, _Add_45a9a28fb1f242429167631ec284e16a_Out_2);
                surface.BaseColor = (_Add_45a9a28fb1f242429167631ec284e16a_Out_2.xyz);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = float3(0, 0, 0);
                surface.Metallic = 0;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                surface.Alpha = 0.4;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.uv0 = input.texCoord0;
                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
            {
                result.vertex = float4(attributes.positionOS, 1);
                result.tangent = attributes.tangentOS;
                result.normal = attributes.normalOS;
                result.texcoord = attributes.uv0;
                result.texcoord1 = attributes.uv1;
                result.vertex = float4(vertexDescription.Position, 1);
                result.normal = vertexDescription.Normal;
                result.tangent = float4(vertexDescription.Tangent, 0);
                #if UNITY_ANY_INSTANCING_ENABLED
                #endif
            }

            void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
            {
                result.pos = varyings.positionCS;
                result.worldPos = varyings.positionWS;
                result.worldNormal = varyings.normalWS;
                result.viewDir = varyings.viewDirectionWS;
                // World Tangent isn't an available input on v2f_surf

                result._ShadowCoord = varyings.shadowCoord;

                #if UNITY_ANY_INSTANCING_ENABLED
                #endif
                #if !defined(LIGHTMAP_ON)
                #if UNITY_SHOULD_SAMPLE_SH
                result.sh = varyings.sh;
                #endif
                #endif
                #if defined(LIGHTMAP_ON)
                result.lmap.xy = varyings.lightmapUV;
                #endif
                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                    result.fogCoord = varyings.fogFactorAndVertexLight.x;
                    COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                #endif

                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
            }

            void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
            {
                result.positionCS = surfVertex.pos;
                result.positionWS = surfVertex.worldPos;
                result.normalWS = surfVertex.worldNormal;
                // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                // World Tangent isn't an available input on v2f_surf
                result.shadowCoord = surfVertex._ShadowCoord;

                #if UNITY_ANY_INSTANCING_ENABLED
                #endif
                #if !defined(LIGHTMAP_ON)
                #if UNITY_SHOULD_SAMPLE_SH
                result.sh = surfVertex.sh;
                #endif
                #endif
                #if defined(LIGHTMAP_ON)
                result.lightmapUV = surfVertex.lmap.xy;
                #endif
                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                    result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                    COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                #endif

                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardAddPass.hlsl"

            ENDHLSL
            }
            Pass
            {
                Name "BuiltIn Deferred"
                Tags
                {
                    "LightMode" = "Deferred"
                }

                // Render State
                Cull Back
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
                ColorMask RGB

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma multi_compile_instancing
                #pragma exclude_renderers nomrt
                #pragma multi_compile_prepassfinal
                #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
                #pragma vertex vert
                #pragma fragment frag

                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _ _GBUFFER_NORMALS_OCT
                // GraphKeywords: <None>

                // Defines
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEFERRED
                #define BUILTIN_TARGET_API 1
                #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                #endif
                #ifdef _BUILTIN_ALPHATEST_ON
                #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                #endif
                #ifdef _BUILTIN_AlphaClip
                #define _AlphaClip _BUILTIN_AlphaClip
                #endif
                #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                #endif


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                     float4 shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float4 uv0;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float4 interp3 : INTERP3;
                     float3 interp4 : INTERP4;
                     float2 interp5 : INTERP5;
                     float3 interp6 : INTERP6;
                     float4 interp7 : INTERP7;
                     float4 interp8 : INTERP8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz = input.positionWS;
                    output.interp1.xyz = input.normalWS;
                    output.interp2.xyzw = input.tangentWS;
                    output.interp3.xyzw = input.texCoord0;
                    output.interp4.xyz = input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy = input.lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp6.xyz = input.sh;
                    #endif
                    output.interp7.xyzw = input.fogFactorAndVertexLight;
                    output.interp8.xyzw = input.shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.lightmapUV = input.interp5.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp6.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                    output.shadowCoord = input.interp8.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float _RippleSpeed;
                float _RippleDensity;
                float _RipplePower;
                float4 _RippleColor;
                float _WaveSpeed;
                CBUFFER_END

                    // Object and Global properties

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                // -- Properties used by SceneSelectionPass
                #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
                #endif

                // Graph Includes
                // GraphIncludes: <None>

                // Graph Functions

                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }


                inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
                {
                    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                    UV = frac(sin(mul(UV, m)));
                    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
                }

                void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                {
                    float2 g = floor(UV * CellDensity);
                    float2 f = frac(UV * CellDensity);
                    float t = 8.0;
                    float3 res = float3(8.0, 0.0, 0.0);

                    for (int y = -1; y <= 1; y++)
                    {
                        for (int x = -1; x <= 1; x++)
                        {
                            float2 lattice = float2(x,y);
                            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                            float d = distance(lattice + offset, f);

                            if (d < res.x)
                            {
                                res = float3(d, offset.x, offset.y);
                                Out = res.x;
                                Cells = res.y;
                            }
                        }
                    }
                }

                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }

                void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }

                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }

                // Custom interpolators pre vertex
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };

                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }

                // Custom interpolators, pre surface
                #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                #endif

                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                    float Alpha;
                };

                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_8621dfa301704db7bbde7355c312c130_Out_0 = _BaseColor;
                    float4 _Property_5e7dbe3484e04d8e9641efbad610fceb_Out_0 = _RippleColor;
                    float _Property_097fd7fd07f243d7a8ac877e1fe6f02a_Out_0 = _RippleSpeed;
                    float _Multiply_9fb8a098e320416aac47090f7007565d_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_097fd7fd07f243d7a8ac877e1fe6f02a_Out_0, _Multiply_9fb8a098e320416aac47090f7007565d_Out_2);
                    float _Property_6669dc7aeaf24b79a7e62166c0b64a34_Out_0 = _RippleDensity;
                    float _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Out_3;
                    float _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Cells_4;
                    Unity_Voronoi_float(IN.uv0.xy, _Multiply_9fb8a098e320416aac47090f7007565d_Out_2, _Property_6669dc7aeaf24b79a7e62166c0b64a34_Out_0, _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Out_3, _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Cells_4);
                    float _Property_c5010c9feb18420e866699165ecd3028_Out_0 = _RipplePower;
                    float _Power_4bd71a9692d7403f8aaa66633c25403a_Out_2;
                    Unity_Power_float(_Voronoi_da73fc8471c7472ab8db3ff4780873a8_Out_3, _Property_c5010c9feb18420e866699165ecd3028_Out_0, _Power_4bd71a9692d7403f8aaa66633c25403a_Out_2);
                    float4 _Multiply_52b50b11cdde4506a1ad42fd8d39a335_Out_2;
                    Unity_Multiply_float4_float4(_Property_5e7dbe3484e04d8e9641efbad610fceb_Out_0, (_Power_4bd71a9692d7403f8aaa66633c25403a_Out_2.xxxx), _Multiply_52b50b11cdde4506a1ad42fd8d39a335_Out_2);
                    float4 _Add_45a9a28fb1f242429167631ec284e16a_Out_2;
                    Unity_Add_float4(_Property_8621dfa301704db7bbde7355c312c130_Out_0, _Multiply_52b50b11cdde4506a1ad42fd8d39a335_Out_2, _Add_45a9a28fb1f242429167631ec284e16a_Out_2);
                    surface.BaseColor = (_Add_45a9a28fb1f242429167631ec284e16a_Out_2.xyz);
                    surface.NormalTS = IN.TangentSpaceNormal;
                    surface.Emission = float3(0, 0, 0);
                    surface.Metallic = 0;
                    surface.Smoothness = 0.5;
                    surface.Occlusion = 1;
                    surface.Alpha = 0.4;
                    return surface;
                }

                // --------------------------------------------------
                // Build Graph Inputs

                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                    output.ObjectSpaceNormal = input.normalOS;
                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                    output.ObjectSpacePosition = input.positionOS;

                    return output;
                }
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                    output.uv0 = input.texCoord0;
                    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                        return output;
                }

                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                {
                    result.vertex = float4(attributes.positionOS, 1);
                    result.tangent = attributes.tangentOS;
                    result.normal = attributes.normalOS;
                    result.texcoord = attributes.uv0;
                    result.texcoord1 = attributes.uv1;
                    result.vertex = float4(vertexDescription.Position, 1);
                    result.normal = vertexDescription.Normal;
                    result.tangent = float4(vertexDescription.Tangent, 0);
                    #if UNITY_ANY_INSTANCING_ENABLED
                    #endif
                }

                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                {
                    result.pos = varyings.positionCS;
                    result.worldPos = varyings.positionWS;
                    result.worldNormal = varyings.normalWS;
                    result.viewDir = varyings.viewDirectionWS;
                    // World Tangent isn't an available input on v2f_surf

                    result._ShadowCoord = varyings.shadowCoord;

                    #if UNITY_ANY_INSTANCING_ENABLED
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    #if UNITY_SHOULD_SAMPLE_SH
                    result.sh = varyings.sh;
                    #endif
                    #endif
                    #if defined(LIGHTMAP_ON)
                    result.lmap.xy = varyings.lightmapUV;
                    #endif
                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                    #endif

                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                }

                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                {
                    result.positionCS = surfVertex.pos;
                    result.positionWS = surfVertex.worldPos;
                    result.normalWS = surfVertex.worldNormal;
                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                    // World Tangent isn't an available input on v2f_surf
                    result.shadowCoord = surfVertex._ShadowCoord;

                    #if UNITY_ANY_INSTANCING_ENABLED
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    #if UNITY_SHOULD_SAMPLE_SH
                    result.sh = surfVertex.sh;
                    #endif
                    #endif
                    #if defined(LIGHTMAP_ON)
                    result.lightmapUV = surfVertex.lmap.xy;
                    #endif
                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                    #endif

                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                }

                // --------------------------------------------------
                // Main

                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRDeferredPass.hlsl"

                ENDHLSL
                }
                Pass
                {
                    Name "ShadowCaster"
                    Tags
                    {
                        "LightMode" = "ShadowCaster"
                    }

                    // Render State
                    Cull Back
                    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                    ZTest LEqual
                    ZWrite On
                    ColorMask 0

                    // Debug
                    // <None>

                    // --------------------------------------------------
                    // Pass

                    HLSLPROGRAM

                    // Pragmas
                    #pragma target 3.0
                    #pragma multi_compile_shadowcaster
                    #pragma vertex vert
                    #pragma fragment frag

                    // DotsInstancingOptions: <None>
                    // HybridV1InjectedBuiltinProperties: <None>

                    // Keywords
                    #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                    // GraphKeywords: <None>

                    // Defines
                    #define _NORMALMAP 1
                    #define _NORMAL_DROPOFF_TS 1
                    #define ATTRIBUTES_NEED_NORMAL
                    #define ATTRIBUTES_NEED_TANGENT
                    #define FEATURES_GRAPH_VERTEX
                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                    #define SHADERPASS SHADERPASS_SHADOWCASTER
                    #define BUILTIN_TARGET_API 1
                    #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                    #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                    #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                    #endif
                    #ifdef _BUILTIN_ALPHATEST_ON
                    #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                    #endif
                    #ifdef _BUILTIN_AlphaClip
                    #define _AlphaClip _BUILTIN_AlphaClip
                    #endif
                    #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                    #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                    #endif


                    // custom interpolator pre-include
                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                    // Includes
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                    // --------------------------------------------------
                    // Structs and Packing

                    // custom interpolators pre packing
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                    struct Attributes
                    {
                         float3 positionOS : POSITION;
                         float3 normalOS : NORMAL;
                         float4 tangentOS : TANGENT;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : INSTANCEID_SEMANTIC;
                        #endif
                    };
                    struct Varyings
                    {
                         float4 positionCS : SV_POSITION;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };
                    struct SurfaceDescriptionInputs
                    {
                    };
                    struct VertexDescriptionInputs
                    {
                         float3 ObjectSpaceNormal;
                         float3 ObjectSpaceTangent;
                         float3 ObjectSpacePosition;
                    };
                    struct PackedVaryings
                    {
                         float4 positionCS : SV_POSITION;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };

                    PackedVaryings PackVaryings(Varyings input)
                    {
                        PackedVaryings output;
                        ZERO_INITIALIZE(PackedVaryings, output);
                        output.positionCS = input.positionCS;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }

                    Varyings UnpackVaryings(PackedVaryings input)
                    {
                        Varyings output;
                        output.positionCS = input.positionCS;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }


                    // --------------------------------------------------
                    // Graph

                    // Graph Properties
                    CBUFFER_START(UnityPerMaterial)
                    float4 _BaseColor;
                    float _RippleSpeed;
                    float _RippleDensity;
                    float _RipplePower;
                    float4 _RippleColor;
                    float _WaveSpeed;
                    CBUFFER_END

                        // Object and Global properties

                        // -- Property used by ScenePickingPass
                        #ifdef SCENEPICKINGPASS
                        float4 _SelectionID;
                        #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Includes
                    // GraphIncludes: <None>

                    // Graph Functions
                    // GraphFunctions: <None>

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        description.Position = IN.ObjectSpacePosition;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float Alpha;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        surface.Alpha = 0.4;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs

                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                    {
                        result.vertex = float4(attributes.positionOS, 1);
                        result.tangent = attributes.tangentOS;
                        result.normal = attributes.normalOS;
                        result.vertex = float4(vertexDescription.Position, 1);
                        result.normal = vertexDescription.Normal;
                        result.tangent = float4(vertexDescription.Tangent, 0);
                        #if UNITY_ANY_INSTANCING_ENABLED
                        #endif
                    }

                    void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                    {
                        result.pos = varyings.positionCS;
                        // World Tangent isn't an available input on v2f_surf


                        #if UNITY_ANY_INSTANCING_ENABLED
                        #endif
                        #if !defined(LIGHTMAP_ON)
                        #if UNITY_SHOULD_SAMPLE_SH
                        #endif
                        #endif
                        #if defined(LIGHTMAP_ON)
                        #endif
                        #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                            result.fogCoord = varyings.fogFactorAndVertexLight.x;
                            COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                        #endif

                        DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                    }

                    void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                    {
                        result.positionCS = surfVertex.pos;
                        // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                        // World Tangent isn't an available input on v2f_surf

                        #if UNITY_ANY_INSTANCING_ENABLED
                        #endif
                        #if !defined(LIGHTMAP_ON)
                        #if UNITY_SHOULD_SAMPLE_SH
                        #endif
                        #endif
                        #if defined(LIGHTMAP_ON)
                        #endif
                        #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                            result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                            COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                        #endif

                        DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "Meta"
                        Tags
                        {
                            "LightMode" = "Meta"
                        }

                        // Render State
                        Cull Off

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 3.0
                        #pragma vertex vert
                        #pragma fragment frag

                        // DotsInstancingOptions: <None>
                        // HybridV1InjectedBuiltinProperties: <None>

                        // Keywords
                        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                        // GraphKeywords: <None>

                        // Defines
                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define ATTRIBUTES_NEED_TEXCOORD1
                        #define ATTRIBUTES_NEED_TEXCOORD2
                        #define VARYINGS_NEED_TEXCOORD0
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_META
                        #define BUILTIN_TARGET_API 1
                        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                        #endif
                        #ifdef _BUILTIN_ALPHATEST_ON
                        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                        #endif
                        #ifdef _BUILTIN_AlphaClip
                        #define _AlphaClip _BUILTIN_AlphaClip
                        #endif
                        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                        #endif


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                             float4 uv0 : TEXCOORD0;
                             float4 uv1 : TEXCOORD1;
                             float4 uv2 : TEXCOORD2;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float4 texCoord0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                             float4 uv0;
                             float3 TimeParameters;
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float4 interp0 : INTERP0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.interp0.xyzw = input.texCoord0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.texCoord0 = input.interp0.xyzw;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float4 _BaseColor;
                        float _RippleSpeed;
                        float _RippleDensity;
                        float _RipplePower;
                        float4 _RippleColor;
                        float _WaveSpeed;
                        CBUFFER_END

                            // Object and Global properties

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                        // -- Properties used by SceneSelectionPass
                        #ifdef SCENESELECTIONPASS
                        int _ObjectId;
                        int _PassValue;
                        #endif

                        // Graph Includes
                        // GraphIncludes: <None>

                        // Graph Functions

                        void Unity_Multiply_float_float(float A, float B, out float Out)
                        {
                            Out = A * B;
                        }


                        inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
                        {
                            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                            UV = frac(sin(mul(UV, m)));
                            return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
                        }

                        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                        {
                            float2 g = floor(UV * CellDensity);
                            float2 f = frac(UV * CellDensity);
                            float t = 8.0;
                            float3 res = float3(8.0, 0.0, 0.0);

                            for (int y = -1; y <= 1; y++)
                            {
                                for (int x = -1; x <= 1; x++)
                                {
                                    float2 lattice = float2(x,y);
                                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                                    float d = distance(lattice + offset, f);

                                    if (d < res.x)
                                    {
                                        res = float3(d, offset.x, offset.y);
                                        Out = res.x;
                                        Cells = res.y;
                                    }
                                }
                            }
                        }

                        void Unity_Power_float(float A, float B, out float Out)
                        {
                            Out = pow(A, B);
                        }

                        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                        {
                            Out = A * B;
                        }

                        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                        {
                            Out = A + B;
                        }

                        // Custom interpolators pre vertex
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                        // Graph Vertex
                        struct VertexDescription
                        {
                            float3 Position;
                            float3 Normal;
                            float3 Tangent;
                        };

                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                        {
                            VertexDescription description = (VertexDescription)0;
                            description.Position = IN.ObjectSpacePosition;
                            description.Normal = IN.ObjectSpaceNormal;
                            description.Tangent = IN.ObjectSpaceTangent;
                            return description;
                        }

                        // Custom interpolators, pre surface
                        #ifdef FEATURES_GRAPH_VERTEX
                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                        {
                        return output;
                        }
                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                        #endif

                        // Graph Pixel
                        struct SurfaceDescription
                        {
                            float3 BaseColor;
                            float3 Emission;
                            float Alpha;
                        };

                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                        {
                            SurfaceDescription surface = (SurfaceDescription)0;
                            float4 _Property_8621dfa301704db7bbde7355c312c130_Out_0 = _BaseColor;
                            float4 _Property_5e7dbe3484e04d8e9641efbad610fceb_Out_0 = _RippleColor;
                            float _Property_097fd7fd07f243d7a8ac877e1fe6f02a_Out_0 = _RippleSpeed;
                            float _Multiply_9fb8a098e320416aac47090f7007565d_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_097fd7fd07f243d7a8ac877e1fe6f02a_Out_0, _Multiply_9fb8a098e320416aac47090f7007565d_Out_2);
                            float _Property_6669dc7aeaf24b79a7e62166c0b64a34_Out_0 = _RippleDensity;
                            float _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Out_3;
                            float _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Cells_4;
                            Unity_Voronoi_float(IN.uv0.xy, _Multiply_9fb8a098e320416aac47090f7007565d_Out_2, _Property_6669dc7aeaf24b79a7e62166c0b64a34_Out_0, _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Out_3, _Voronoi_da73fc8471c7472ab8db3ff4780873a8_Cells_4);
                            float _Property_c5010c9feb18420e866699165ecd3028_Out_0 = _RipplePower;
                            float _Power_4bd71a9692d7403f8aaa66633c25403a_Out_2;
                            Unity_Power_float(_Voronoi_da73fc8471c7472ab8db3ff4780873a8_Out_3, _Property_c5010c9feb18420e866699165ecd3028_Out_0, _Power_4bd71a9692d7403f8aaa66633c25403a_Out_2);
                            float4 _Multiply_52b50b11cdde4506a1ad42fd8d39a335_Out_2;
                            Unity_Multiply_float4_float4(_Property_5e7dbe3484e04d8e9641efbad610fceb_Out_0, (_Power_4bd71a9692d7403f8aaa66633c25403a_Out_2.xxxx), _Multiply_52b50b11cdde4506a1ad42fd8d39a335_Out_2);
                            float4 _Add_45a9a28fb1f242429167631ec284e16a_Out_2;
                            Unity_Add_float4(_Property_8621dfa301704db7bbde7355c312c130_Out_0, _Multiply_52b50b11cdde4506a1ad42fd8d39a335_Out_2, _Add_45a9a28fb1f242429167631ec284e16a_Out_2);
                            surface.BaseColor = (_Add_45a9a28fb1f242429167631ec284e16a_Out_2.xyz);
                            surface.Emission = float3(0, 0, 0);
                            surface.Alpha = 0.4;
                            return surface;
                        }

                        // --------------------------------------------------
                        // Build Graph Inputs

                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                        {
                            VertexDescriptionInputs output;
                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                            output.ObjectSpaceNormal = input.normalOS;
                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                            output.ObjectSpacePosition = input.positionOS;

                            return output;
                        }
                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                        {
                            SurfaceDescriptionInputs output;
                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                            output.uv0 = input.texCoord0;
                            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                        #else
                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                        #endif
                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                return output;
                        }

                        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                        {
                            result.vertex = float4(attributes.positionOS, 1);
                            result.tangent = attributes.tangentOS;
                            result.normal = attributes.normalOS;
                            result.texcoord = attributes.uv0;
                            result.texcoord1 = attributes.uv1;
                            result.texcoord2 = attributes.uv2;
                            result.vertex = float4(vertexDescription.Position, 1);
                            result.normal = vertexDescription.Normal;
                            result.tangent = float4(vertexDescription.Tangent, 0);
                            #if UNITY_ANY_INSTANCING_ENABLED
                            #endif
                        }

                        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                        {
                            result.pos = varyings.positionCS;
                            // World Tangent isn't an available input on v2f_surf


                            #if UNITY_ANY_INSTANCING_ENABLED
                            #endif
                            #if !defined(LIGHTMAP_ON)
                            #if UNITY_SHOULD_SAMPLE_SH
                            #endif
                            #endif
                            #if defined(LIGHTMAP_ON)
                            #endif
                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                            #endif

                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                        }

                        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                        {
                            result.positionCS = surfVertex.pos;
                            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                            // World Tangent isn't an available input on v2f_surf

                            #if UNITY_ANY_INSTANCING_ENABLED
                            #endif
                            #if !defined(LIGHTMAP_ON)
                            #if UNITY_SHOULD_SAMPLE_SH
                            #endif
                            #endif
                            #if defined(LIGHTMAP_ON)
                            #endif
                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                            #endif

                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                        }

                        // --------------------------------------------------
                        // Main

                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                        ENDHLSL
                        }
                        Pass
                        {
                            Name "SceneSelectionPass"
                            Tags
                            {
                                "LightMode" = "SceneSelectionPass"
                            }

                            // Render State
                            Cull Off

                            // Debug
                            // <None>

                            // --------------------------------------------------
                            // Pass

                            HLSLPROGRAM

                            // Pragmas
                            #pragma target 3.0
                            #pragma multi_compile_instancing
                            #pragma vertex vert
                            #pragma fragment frag

                            // DotsInstancingOptions: <None>
                            // HybridV1InjectedBuiltinProperties: <None>

                            // Keywords
                            // PassKeywords: <None>
                            // GraphKeywords: <None>

                            // Defines
                            #define _NORMALMAP 1
                            #define _NORMAL_DROPOFF_TS 1
                            #define ATTRIBUTES_NEED_NORMAL
                            #define ATTRIBUTES_NEED_TANGENT
                            #define FEATURES_GRAPH_VERTEX
                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                            #define SHADERPASS SceneSelectionPass
                            #define BUILTIN_TARGET_API 1
                            #define SCENESELECTIONPASS 1
                            #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                            #endif
                            #ifdef _BUILTIN_ALPHATEST_ON
                            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                            #endif
                            #ifdef _BUILTIN_AlphaClip
                            #define _AlphaClip _BUILTIN_AlphaClip
                            #endif
                            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                            #endif


                            // custom interpolator pre-include
                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                            // Includes
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                            // --------------------------------------------------
                            // Structs and Packing

                            // custom interpolators pre packing
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                            struct Attributes
                            {
                                 float3 positionOS : POSITION;
                                 float3 normalOS : NORMAL;
                                 float4 tangentOS : TANGENT;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : INSTANCEID_SEMANTIC;
                                #endif
                            };
                            struct Varyings
                            {
                                 float4 positionCS : SV_POSITION;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };
                            struct SurfaceDescriptionInputs
                            {
                            };
                            struct VertexDescriptionInputs
                            {
                                 float3 ObjectSpaceNormal;
                                 float3 ObjectSpaceTangent;
                                 float3 ObjectSpacePosition;
                            };
                            struct PackedVaryings
                            {
                                 float4 positionCS : SV_POSITION;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };

                            PackedVaryings PackVaryings(Varyings input)
                            {
                                PackedVaryings output;
                                ZERO_INITIALIZE(PackedVaryings, output);
                                output.positionCS = input.positionCS;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }

                            Varyings UnpackVaryings(PackedVaryings input)
                            {
                                Varyings output;
                                output.positionCS = input.positionCS;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }


                            // --------------------------------------------------
                            // Graph

                            // Graph Properties
                            CBUFFER_START(UnityPerMaterial)
                            float4 _BaseColor;
                            float _RippleSpeed;
                            float _RippleDensity;
                            float _RipplePower;
                            float4 _RippleColor;
                            float _WaveSpeed;
                            CBUFFER_END

                                // Object and Global properties

                                // -- Property used by ScenePickingPass
                                #ifdef SCENEPICKINGPASS
                                float4 _SelectionID;
                                #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Includes
                            // GraphIncludes: <None>

                            // Graph Functions
                            // GraphFunctions: <None>

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                description.Position = IN.ObjectSpacePosition;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float Alpha;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                surface.Alpha = 0.4;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs

                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                            {
                                result.vertex = float4(attributes.positionOS, 1);
                                result.tangent = attributes.tangentOS;
                                result.normal = attributes.normalOS;
                                result.vertex = float4(vertexDescription.Position, 1);
                                result.normal = vertexDescription.Normal;
                                result.tangent = float4(vertexDescription.Tangent, 0);
                                #if UNITY_ANY_INSTANCING_ENABLED
                                #endif
                            }

                            void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                            {
                                result.pos = varyings.positionCS;
                                // World Tangent isn't an available input on v2f_surf


                                #if UNITY_ANY_INSTANCING_ENABLED
                                #endif
                                #if !defined(LIGHTMAP_ON)
                                #if UNITY_SHOULD_SAMPLE_SH
                                #endif
                                #endif
                                #if defined(LIGHTMAP_ON)
                                #endif
                                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                    result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                    COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                #endif

                                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                            }

                            void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                            {
                                result.positionCS = surfVertex.pos;
                                // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                // World Tangent isn't an available input on v2f_surf

                                #if UNITY_ANY_INSTANCING_ENABLED
                                #endif
                                #if !defined(LIGHTMAP_ON)
                                #if UNITY_SHOULD_SAMPLE_SH
                                #endif
                                #endif
                                #if defined(LIGHTMAP_ON)
                                #endif
                                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                    result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                    COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                #endif

                                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "ScenePickingPass"
                                Tags
                                {
                                    "LightMode" = "Picking"
                                }

                                // Render State
                                Cull Back

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 3.0
                                #pragma multi_compile_instancing
                                #pragma vertex vert
                                #pragma fragment frag

                                // DotsInstancingOptions: <None>
                                // HybridV1InjectedBuiltinProperties: <None>

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines
                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS ScenePickingPass
                                #define BUILTIN_TARGET_API 1
                                #define SCENEPICKINGPASS 1
                                #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                #endif
                                #ifdef _BUILTIN_ALPHATEST_ON
                                #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                #endif
                                #ifdef _BUILTIN_AlphaClip
                                #define _AlphaClip _BUILTIN_AlphaClip
                                #endif
                                #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                #endif


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float4 _BaseColor;
                                float _RippleSpeed;
                                float _RippleDensity;
                                float _RipplePower;
                                float4 _RippleColor;
                                float _WaveSpeed;
                                CBUFFER_END

                                    // Object and Global properties

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                // -- Properties used by SceneSelectionPass
                                #ifdef SCENESELECTIONPASS
                                int _ObjectId;
                                int _PassValue;
                                #endif

                                // Graph Includes
                                // GraphIncludes: <None>

                                // Graph Functions
                                // GraphFunctions: <None>

                                // Custom interpolators pre vertex
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                // Graph Vertex
                                struct VertexDescription
                                {
                                    float3 Position;
                                    float3 Normal;
                                    float3 Tangent;
                                };

                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                {
                                    VertexDescription description = (VertexDescription)0;
                                    description.Position = IN.ObjectSpacePosition;
                                    description.Normal = IN.ObjectSpaceNormal;
                                    description.Tangent = IN.ObjectSpaceTangent;
                                    return description;
                                }

                                // Custom interpolators, pre surface
                                #ifdef FEATURES_GRAPH_VERTEX
                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                {
                                return output;
                                }
                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                #endif

                                // Graph Pixel
                                struct SurfaceDescription
                                {
                                    float Alpha;
                                };

                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                {
                                    SurfaceDescription surface = (SurfaceDescription)0;
                                    surface.Alpha = 0.4;
                                    return surface;
                                }

                                // --------------------------------------------------
                                // Build Graph Inputs

                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                {
                                    VertexDescriptionInputs output;
                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                    output.ObjectSpaceNormal = input.normalOS;
                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                    output.ObjectSpacePosition = input.positionOS;

                                    return output;
                                }
                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                {
                                    SurfaceDescriptionInputs output;
                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                #else
                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                #endif
                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                        return output;
                                }

                                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                {
                                    result.vertex = float4(attributes.positionOS, 1);
                                    result.tangent = attributes.tangentOS;
                                    result.normal = attributes.normalOS;
                                    result.vertex = float4(vertexDescription.Position, 1);
                                    result.normal = vertexDescription.Normal;
                                    result.tangent = float4(vertexDescription.Tangent, 0);
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    #endif
                                }

                                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                {
                                    result.pos = varyings.positionCS;
                                    // World Tangent isn't an available input on v2f_surf


                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    #endif
                                    #if !defined(LIGHTMAP_ON)
                                    #if UNITY_SHOULD_SAMPLE_SH
                                    #endif
                                    #endif
                                    #if defined(LIGHTMAP_ON)
                                    #endif
                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                    #endif

                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                }

                                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                {
                                    result.positionCS = surfVertex.pos;
                                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                    // World Tangent isn't an available input on v2f_surf

                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    #endif
                                    #if !defined(LIGHTMAP_ON)
                                    #if UNITY_SHOULD_SAMPLE_SH
                                    #endif
                                    #endif
                                    #if defined(LIGHTMAP_ON)
                                    #endif
                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                    #endif

                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                }

                                // --------------------------------------------------
                                // Main

                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                ENDHLSL
                                }
}
CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInLitGUI" ""
CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
FallBack "Hidden/Shader Graph/FallbackError"
}