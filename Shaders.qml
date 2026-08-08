import QtQuick 2.15

import "Components/Settings"

Item {

    //property real screenCurvature: appSettings.screenCurvature * appSettings.screenCurvatureSize
    // property real curvatureX: 0.10
    // property real curvatureY: 0.15
    property real curvatureX: 0.10 * (themeSettings.shaderCurvatureAmount/100)
    property real curvatureY: 0.20 * (themeSettings.shaderCurvatureAmount/100)

    property vector2d screenScale: Qt.vector2d(1.0, 1.0)
    property var source;

    // required property RootWindow rootWindow;

    ShaderEffect {
        id: shaderEffects

        blending: false
        anchors.fill: parent

        property variant source: effectSource

        property real curvatureX: parent.curvatureX
        property real curvatureY: parent.curvatureY
        property vector2d screenScale: parent.screenScale
        property vector4d sourceSize: Qt.vector4d(effectSource.textureSize.width, effectSource.textureSize.height, 1.0 / effectSource.textureSize.width, 1.0 / effectSource.textureSize.height) 
        property vector4d originalSize: Qt.vector4d(effectSource.sourceItem.width, effectSource.sourceItem.height, 1.0 / effectSource.sourceItem.width, 1.0 / effectSource.sourceItem.height)
        property vector4d outputSize: Qt.vector4d(effectSource.width, effectSource.height, 1.0 / effectSource.width, 1.0 / effectSource.height)


        property real amp: 1.25
        property real phase: 0.5
        property real lines_black: 0.3
        property real lines_white: 1.0
        property real scanlinesOpacity: themeSettings.shaderScanlinesOpacity/10
        property real scanlineGlow: themeSettings.shaderScanlinesGlow/100
        property real mask: 0.0
        property real mask_weight: 0.5
        //property real imageSize: 180.0
        property real imageSize: themeSettings.shaderScanlinesImageSize

        property real autoscale: 0

        property real curvature: 0.03

        // CRT chromatic aberration: splits R/G/B apart radially from center,
        // strongest toward the edges.
        property bool aberrationEnable: themeSettings.shaderAberrationEnable
        property real aberrationAmount: themeSettings.shaderAberrationAmount/100000
        //0.0001

        // CRT glow: chromatic-aberration bloom + film grain.
        property bool glowEnable: themeSettings.shaderGlowEnable
        property real glowAmount: themeSettings.shaderGlowAmount/10 //0.6
        property real glowRadius: 10.0
        property real glowAberration: 0.4



        fragmentShader: themeSettings.shaderEnable ? fragmentShaderString : ""

        property string fragmentShaderString: "
            // uniform highp float screenCurvature;
            uniform sampler2D source;
            uniform mediump vec4 qt_SubRect_source;
            varying highp vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;
            varying mediump vec2 texCoord;

            uniform mediump vec4 sourceSize;
            uniform mediump vec4 originalSize;
            uniform mediump vec4 outputSize;

            // varying mediump float omega;

            uniform lowp float amp;
            uniform lowp float phase;
            uniform lowp float lines_black;
            uniform lowp float lines_white;
            uniform lowp float scanlinesOpacity;
            uniform lowp float scanlineGlow;
            uniform lowp float mask;
            uniform lowp float mask_weight;
            uniform lowp float imageSize;
            uniform lowp float autoscale;\n" +

            (themeSettings.shaderCurvatureEnable ? "
            uniform lowp float curvature;
            uniform lowp float curvatureX;
            uniform lowp float curvatureY;
            " : "") +

            (glowEnable ? "
            uniform lowp float glowAmount;
            uniform lowp float glowRadius;
            uniform lowp float glowAberration;
            " : "") +

            (aberrationEnable ? "
            uniform lowp float aberrationAmount;
            " : "") +

            "
            #ifdef GL_ES
                 precision mediump float;
            #endif

            #define freq             0.500000
            #define offset           0.000000
            #define pi               3.141592654
            " +

            (themeSettings.shaderCurvatureEnable ? "
            vec2 Warp(vec2 pos)
            {
                pos = -1.0 + 2.0 * pos;
                vec2 p = pos * pos;
                
                pos *= vec2(1.0 + 1.3333 * curvature * p.y, 1.0 + curvature * p.x);
                return clamp(pos * 0.5 + 0.5, 0.0, 1.0);
            }


            vec2 Distort(vec2 coord)
            {
                vec2 CURVATURE_DISTORTION = vec2(curvatureX, curvatureY);
                vec2 barrelScale = 1.0 - (0.23 * CURVATURE_DISTORTION);

                coord -= vec2(0.5);
                float rsq = coord.x * coord.x + coord.y * coord.y;
                coord += coord * (CURVATURE_DISTORTION * rsq);
                coord *= barrelScale;
                if (abs(coord.x) >= 0.5 || abs(coord.y) >= 0.5)
                    coord = vec2(-1.0);
                else
                    coord += vec2(0.5);

                return coord;
            }
            " : "")  +

            (glowEnable ? "
            // Samples one color channel (via a one-hot mask, since GLSL ES 1.00
            // can't index a vector by a non-constant int) across 3 concentric,
            // rotated rings so glow has continuous radial coverage instead of
            // a hollow ring at one fixed distance.
            float sampleGlowChannel(vec2 uv, vec2 texel, float radius, vec3 channelMask)
            {
                float total = 0.0;
                float weightSum = 0.0;

                float w1 = 0.8;
                vec2 r1 = texel * radius * 0.35;
                total += dot(texture2D(source, uv + vec2( r1.x,  0.0)).rgb, channelMask) * w1;
                total += dot(texture2D(source, uv + vec2(-r1.x,  0.0)).rgb, channelMask) * w1;
                total += dot(texture2D(source, uv + vec2( 0.0,  r1.y)).rgb, channelMask) * w1;
                total += dot(texture2D(source, uv + vec2( 0.0, -r1.y)).rgb, channelMask) * w1;
                weightSum += 4.0 * w1;

                float w2 = 0.5;
                vec2 r2 = texel * radius * 0.7;
                total += dot(texture2D(source, uv + vec2( r2.x * 0.707,  r2.y * 0.707)).rgb, channelMask) * w2;
                total += dot(texture2D(source, uv + vec2(-r2.x * 0.707,  r2.y * 0.707)).rgb, channelMask) * w2;
                total += dot(texture2D(source, uv + vec2(-r2.x * 0.707, -r2.y * 0.707)).rgb, channelMask) * w2;
                total += dot(texture2D(source, uv + vec2( r2.x * 0.707, -r2.y * 0.707)).rgb, channelMask) * w2;
                weightSum += 4.0 * w2;

                float w3 = 0.25;
                vec2 r3 = texel * radius;
                total += dot(texture2D(source, uv + vec2( r3.x * 0.924,  r3.y * 0.383)).rgb, channelMask) * w3;
                total += dot(texture2D(source, uv + vec2(-r3.x * 0.383,  r3.y * 0.924)).rgb, channelMask) * w3;
                total += dot(texture2D(source, uv + vec2(-r3.x * 0.924, -r3.y * 0.383)).rgb, channelMask) * w3;
                total += dot(texture2D(source, uv + vec2( r3.x * 0.383, -r3.y * 0.924)).rgb, channelMask) * w3;
                weightSum += 4.0 * w3;

                return total / weightSum;
            }
            " : "") +

            "
            void main()
            {
                float omega = 2.0 * pi * freq;
                vec2 texCoord = qt_TexCoord0;

                // Curve
                //vec2 curved_coords = warp(texCoord);
                // texCoord = Warp(texCoord);
                " +
                (themeSettings.shaderCurvatureEnable ? "
                texCoord = Distort(texCoord);
                if (texCoord.x < 0.0)
                {
                    gl_FragColor = vec4(0.0);
                    return;
                }
                " : "") +

                "
                " +

                (aberrationEnable ? "
                // Chromatic aberration driven by local brightness gradient:
                // fringes color at bright/dark boundaries (text edges, icon
                // outlines) rather than by distance from screen center.
                vec2 caTexel = sourceSize.zw;
                vec3 lumaMask = vec3(0.299, 0.587, 0.114);
                float lumaR_ = dot(texture2D(source, texCoord + vec2(caTexel.x, 0.0)).rgb, lumaMask);
                float lumaL_ = dot(texture2D(source, texCoord - vec2(caTexel.x, 0.0)).rgb, lumaMask);
                float lumaU_ = dot(texture2D(source, texCoord + vec2(0.0, caTexel.y)).rgb, lumaMask);
                float lumaD_ = dot(texture2D(source, texCoord - vec2(0.0, caTexel.y)).rgb, lumaMask);

                vec2 lumaGradient = vec2(lumaR_ - lumaL_, lumaU_ - lumaD_);
                float gradientMag = length(lumaGradient);
                vec2 gradientDir = gradientMag > 0.0001 ? lumaGradient / gradientMag : vec2(0.0, 0.0);

                // Offset scales with edge contrast, points from bright toward dark
                vec2 caOffset = gradientDir * gradientMag * aberrationAmount * 4.0;

                vec3 color;
                color.r = texture2D(source, texCoord - caOffset).r;
                color.g = texture2D(source, texCoord).g;
                color.b = texture2D(source, texCoord + caOffset).b;
                " : "
                vec3 color = texture2D(source, texCoord).rgb;
                ") +

                "
                " +

                (themeSettings.shaderScanlinesEnable ? "
                // Generate scanlines
                float scale = imageSize;
                //float angle = (qt_TexCoord0.y * originalSize.w) * omega * scale + phase;
                float angle = (" + (themeSettings.shaderScanlinesCurve ? "texCoord.y" : "qt_TexCoord0.y") + ") * omega * scale + phase;
                float lines;
                lines = sin(angle);
                lines *= amp;
                lines += offset;
                lines = abs(lines);
                lines *= lines_white - lines_black;
                lines += lines_black;

                //color += color - clamp(blurHoriz(source, texCoord), 0.0, 0.5);
                //color += color - clamp(blurVert(source, texCoord), 0.0, 0.5);

                color += clamp(color * 0.4, 0.0, 0.5);

                // Normalized 0..1: 0 at the dark troughs between scan rows,
                // 1 at the bright scan rows themselves.
                float linesNorm = clamp((lines - lines_black) / max(lines_white - lines_black, 0.0001), 0.0, 1.0);

                // Multiplicative part darkens/lightens existing content as before;
                // additive part is a small lift on bright rows only, so scanlines
                // stay visible even where the underlying pixel is pure black.
                vec3 scanlineResult = color * lines + vec3(scanlineGlow) * linesNorm;

                color = mix(color, scanlineResult, scanlinesOpacity);
                " : "") +
                "

                //color += clamp(color * 0.4, 0.0, 0.5);
                //color *= vec3(1.3333);
                //color = clamp(color * )
                " +

                (glowEnable ? "
                // CRT glow: each color channel blooms at a slightly different
                // radius, producing the rainbow-fringed halo you see around
                // bright edges on a real tube.
                vec2 glowTexel = sourceSize.zw;
                float rR = glowRadius * (1.0 + glowAberration);
                float rG = glowRadius;
                float rB = glowRadius * (1.0 + glowAberration * 0.5);

                float glowR = sampleGlowChannel(texCoord, glowTexel, rR, vec3(1.0, 0.0, 0.0));
                float glowG = sampleGlowChannel(texCoord, glowTexel, rG, vec3(0.0, 1.0, 0.0));
                float glowB = sampleGlowChannel(texCoord, glowTexel, rB, vec3(0.0, 0.0, 1.0));

                vec3 glow = vec3(glowR, glowG, glowB);
                float glowLuma = dot(glow, vec3(0.299, 0.587, 0.114));
                float pixelLuma = dot(color, vec3(0.299, 0.587, 0.114));

                float spillGate = smoothstep(0.0, 0.6, glowLuma);
                float darkGate = 1.0 - smoothstep(-0.1, 0.8, pixelLuma);

                color += glow * glowAmount * spillGate * darkGate;
                " : "") +

                "
                gl_FragColor = vec4(color.rgb, 1.0);

            }"

        

        RootWindow {
            id: rootWindow
            // width: Math.floor(parent.width/8)*8
            // //width: (parent.height * 3) / 4
            // //height: Math.floor(parent.height/8)*8
            // height: parent.width * 0.75
            // anchors.horizontalCenter: parent.horizontalCenter
            anchors.fill: parent

            Component.onCompleted: {
                // effectSource.textureSize = Qt.size(width, height)
                console.log("RootWindow loaded")
            }

            onWidthChanged: {
                console.log("RootWindow: " + rootWindow.width + ", " + rootWindow.height)
            }
            onHeightChanged: {
                console.log("RootWindow: " + rootWindow.width + ", " + rootWindow.height)
            }

        }

        ShaderEffectSource {
            id: effectSource

            // width: rootWindow.width
            // height: rootWindow.height
            // //width: Math.floor(parent.width / 8) * 8
            // //height: Math.floor(parent.height / 8) * 8
            // anchors.centerIn: parent

            sourceItem: rootWindow
            hideSource: true
            format: ShaderEffectSource.RGBA
            //textureSize: Qt.size(Math.floor(rootWindow.width / 8) * 8, Math.floor(rootWindow.height / 8) * 8)
            // textureSize: Qt.size(960, 540)
            textureSize: Qt.size(rootWindow.width, rootWindow.height)

            live: true



            Component.onCompleted: {
                console.log("Shader Texture Size: " + textureSize)
            }

        }
        
        onStatusChanged: {
             // Print warning messages
             if (log) console.log(log);
         }

         Component.onCompleted: {
            if (GraphicsInfo.shaderType === GraphicsInfo.GLSL)
                console.log("Shader Type: GLSL")
            if (GraphicsInfo.shaderType === GraphicsInfo.HSLS)
                console.log("Shader Type: HLSL")

            console.log("Source Size: " + sourceSize)
            console.log("Texture Size: " + originalSize)
            console.log("Output Size: " + outputSize)
         }

    }

}