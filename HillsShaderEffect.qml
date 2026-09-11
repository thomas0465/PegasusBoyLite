import QtQuick 2.15

Item {
    id: rootItem
    anchors.fill: parent

    property real time: 0

    property color bottomColor: "#ffffff"
    property color topColor: "#ffffff"

    property real waveOpacity1: 1
    property real waveOpacity2: 1
    property real waveOpacity3: 1

    property real gradientAmount: 0

    //gradient from top to bottom
    property real highlightAmount: 0.0

    //amount of the fade between waves
    property real bottomFade: themeSettings.shaderHillsFade / 100

    //height of the fade
    property real bottomFadeHeight: themeSettings.shaderHillsFadeHeight / 100

    //color of the fade
    property color fadeColor: themeSettings.shaderHillsFadeColor

    Timer {
        interval: 8
        running: true
        repeat: true
        onTriggered: rootItem.time = Math.fmod(rootItem.time + 0.2, 628.3)
    }

    ShaderEffect {
        anchors.fill: parent

        property real u_time: rootItem.time
        property color u_bottomColor: rootItem.bottomColor
        property color u_topColor: rootItem.topColor
        property real u_waveOpacity1: rootItem.waveOpacity1
        property real u_waveOpacity2: rootItem.waveOpacity2
        property real u_waveOpacity3: rootItem.waveOpacity3
        property real u_gradientAmount: rootItem.gradientAmount
        property real u_highlightAmount: rootItem.highlightAmount
        property real u_bottomFade: rootItem.bottomFade
        property real u_bottomFadeHeight: rootItem.bottomFadeHeight
        property color u_fadeColor: rootItem.fadeColor

        fragmentShader: "
            #ifdef GL_ES
                precision mediump float;
            #endif

            varying highp vec2 qt_TexCoord0;
            uniform lowp float u_time;
            uniform lowp vec4 u_bottomColor;
            uniform lowp vec4 u_topColor;
            uniform lowp float u_waveOpacity1;
            uniform lowp float u_waveOpacity2;
            uniform lowp float u_waveOpacity3;
            uniform lowp float u_gradientAmount;
            uniform lowp float u_highlightAmount;
            uniform lowp float u_bottomFade;
            uniform lowp float u_bottomFadeHeight;
            uniform lowp vec4 u_fadeColor;

            vec4 alphaBlend(vec4 top, vec4 bottom) {
                vec4 result;
                result.a = top.a + bottom.a * (1.0 - top.a);
                if (result.a > 0.0) {
                    result.rgb = (top.rgb * top.a + bottom.rgb * bottom.a * (1.0 - top.a)) / result.a;
                } else {
                    result.rgb = vec3(0.0);
                }
                return result;
            }

            vec3 horizonGlow(
                vec3 baseColor,
                float edgeY,
                float uvY,
                float fadeHeight,
                float fadeAmount,
                vec3 fadeColor
            ) {
                // Distance below the wave edge
                float d = uvY - edgeY;

                // Only affect pixels within fadeHeight below the edge
                float t = 1.0 - smoothstep(0.0, fadeHeight, d);

                // Fade amount
                t *= fadeAmount;

                return mix(baseColor, fadeColor, t);

            }

            void main()
            {
                vec2 uv = qt_TexCoord0;
                float x = uv.x * 6.28318;

                float w1 = sin(x * 0.6  + u_time * 0.03) * 0.055 +
                           cos(x * 1.1  + u_time * 0.02) * 0.025;

                float w2 = sin(x * 1.3  - u_time * 0.05 + 1.0) * 0.045 +
                           sin(x * 0.5  - u_time * 0.03 + 2.5) * 0.030;

                float w3 = cos(x * 0.8  + u_time * 0.07 + 0.5) * 0.050 +
                           sin(x * 1.7  + u_time * 0.04 + 3.8) * 0.020;

                float y1 = 0.32 + w1;
                float y2 = 0.5 + w2;
                float y3 = 0.72 + w3;
                float edge = 0.002;
                float m1 = smoothstep(y1 - edge, y1 + edge, uv.y);
                float m2 = smoothstep(y2 - edge, y2 + edge, uv.y);
                float m3 = smoothstep(y3 - edge, y3 + edge, uv.y);

                float grad = clamp(uv.y * u_gradientAmount, 0.0, 1.0);
                float highlight = (1.0 - uv.y) * u_highlightAmount;

                vec3 bg = mix(u_topColor.rgb, u_bottomColor.rgb, grad);
                bg = clamp(bg + vec3(highlight), 0.0, 1.0);

                vec3 solidWave1 = mix(mix(u_topColor.rgb, u_bottomColor.rgb, 0.3), u_bottomColor.rgb, grad);
                vec3 solidWave2 = mix(mix(u_topColor.rgb, u_bottomColor.rgb, 0.6), u_bottomColor.rgb, grad);
                vec3 solidWave3 = mix(mix(u_topColor.rgb, u_bottomColor.rgb, .99), u_bottomColor.rgb, grad);

                solidWave1 = clamp(solidWave1 + vec3(highlight), 0.0, 1.0);
                solidWave2 = clamp(solidWave2 + vec3(highlight), 0.0, 1.0);
                solidWave3 = clamp(solidWave3 + vec3(highlight), 0.0, 1.0);

                float fadeHeight = max(u_bottomFadeHeight, 0.001);
                vec3 fadeColor = u_fadeColor.rgb;

                // Background
                vec4 color = vec4(bg, 1.0);

                // Wave 1
                float fade1 = 1.0 - smoothstep(0.0, fadeHeight, uv.y - y1);
                fade1 *= u_bottomFade;

                vec3 waveColor1 = mix(solidWave1, fadeColor, fade1);
                vec4 layer1 = vec4(waveColor1, u_waveOpacity1 * m1);
                color = alphaBlend(layer1, color);

                // Wave 2
                float fade2 = 1.0 - smoothstep(0.0, fadeHeight, uv.y - y2);
                fade2 *= u_bottomFade;

                vec3 waveColor2 = mix(solidWave2, fadeColor, fade2);
                vec4 layer2 = vec4(waveColor2, u_waveOpacity2 * m2);
                color = alphaBlend(layer2, color);

                // Wave 3
                float fade3 = 1.0 - smoothstep(0.0, fadeHeight, uv.y - y3);
                fade3 *= u_bottomFade;

                vec3 waveColor3 = mix(solidWave3, fadeColor, fade3);
                vec4 layer3 = vec4(waveColor3, u_waveOpacity3 * m3);
                color = alphaBlend(layer3, color);

                gl_FragColor = color;
            }
        "
    }
}