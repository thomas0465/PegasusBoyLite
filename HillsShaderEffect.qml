import QtQuick 2.15

Item {
    id: rootItem
    anchors.fill: parent

    property real time: 0

    property color bottomColor: "#ffffff"
    property color topColor: "#ffffff"

    property real waveOpacity1: 0.8
    property real waveOpacity2: 0.8
    property real waveOpacity3: 1

    Timer {
        interval: 32
        running: true
        repeat: true
        onTriggered: rootItem.time += 0.2
    }

    ShaderEffect {
        anchors.fill: parent

        property real u_time: rootItem.time
        property color u_bottomColor: rootItem.bottomColor
        property color u_topColor: rootItem.topColor
        property real u_waveOpacity1: rootItem.waveOpacity1
        property real u_waveOpacity2: rootItem.waveOpacity2
        property real u_waveOpacity3: rootItem.waveOpacity3

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
                float y3 = 0.68 + w3;
                float edge = 0.002;
                float m1 = smoothstep(y1 - edge, y1 + edge, uv.y);
                float m2 = smoothstep(y2 - edge, y2 + edge, uv.y);
                float m3 = smoothstep(y3 - edge, y3 + edge, uv.y);

                // Background vertical gradient
                vec3 bg = u_topColor.rgb;
                vec4 color = vec4(bg, 1.0);

                // Calculate solid colors for wave 1 and wave 2 from top and bottom colors
                vec3 solidWave1 = mix(u_topColor.rgb, u_bottomColor.rgb, 0.32);
                vec3 solidWave2 = mix(u_topColor.rgb, u_bottomColor.rgb, 0.50);
                vec3 solidWave3 = u_bottomColor.rgb;

                vec4 layer1 = vec4(solidWave1, u_waveOpacity1 * m1);
                vec4 layer2 = vec4(solidWave2, u_waveOpacity2 * m2);
                vec4 layer3 = vec4(solidWave3, u_waveOpacity3 * m3);

                color = alphaBlend(layer1, color);
                color = alphaBlend(layer2, color);
                color = alphaBlend(layer3, color);

                gl_FragColor = color;
            }
        "
    }
}